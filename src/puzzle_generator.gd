class_name PuzzleGenerator
extends Resource

const TYPES := [Cell.Type.SUN, Cell.Type.MOON]
const CONSTRAINT_CHANCE := 0.05

@export var debug := false
@export var pool_size := 10
@export var grid_size := 6

var _puzzles: Array[Puzzle] = []
var _puzzles_lock := Mutex.new()
var puzzle_generated_sem := Semaphore.new()

# Tracks how many puzzles are currently being generated, so we don't
# over-schedule when multiple get_puzzle() calls come in at once.
var _in_flight := 0
var _in_flight_lock := Mutex.new()
var _task_ids: Array[int] = []

var _stop := false
var _stop_lock := Mutex.new()

signal puzzle_generated(generator: PuzzleGenerator)


func queue_generation():
	_puzzles = DataPersistence.fetch_puzzles(grid_size)
	_top_up_pool()


func is_puzzle_ready() -> bool:
	_puzzles_lock.lock()
	var size := _puzzles.size()
	_puzzles_lock.unlock()
	return size > 0


func get_puzzle() -> Puzzle:
	_puzzles_lock.lock()
	var puzzle: Puzzle = _puzzles.pop_front()
	_puzzles_lock.unlock()
	DataPersistence.remove_first_puzzle(puzzle.grid_size())
	DataPersistence.save()

	# A puzzle was consumed — schedule a replacement.
	_top_up_pool()

	if puzzle == null:
		puzzle_generated_sem.wait()
		return get_puzzle()

	return puzzle


# No thread ownership to clean up — WorkerThreadPool manages its own
# threads. Call this if you need to wait for all in-flight tasks before
# quitting, e.g. in _notification(NOTIFICATION_WM_CLOSE_REQUEST).
func wait_for_cleanup_finish():
	_stop_lock.lock()
	_stop = true
	_stop_lock.unlock()
	for task_id in _task_ids:
		WorkerThreadPool.wait_for_task_completion(task_id)


func _top_up_pool():
	_puzzles_lock.lock()
	var puzzles_ready := _puzzles.size()
	_puzzles_lock.unlock()

	_in_flight_lock.lock()
	var in_flight := _in_flight
	_in_flight_lock.unlock()

	var needed := pool_size - puzzles_ready - in_flight
	for _i in range(needed):
		_in_flight_lock.lock()
		_in_flight += 1
		_in_flight_lock.unlock()
		var task_id := WorkerThreadPool.add_task(_generate_and_store)
		_task_ids.append(task_id)


func _generate_and_store():
	var puzzle := _generate_puzzle(grid_size)
	if puzzle == null:
		return

	_puzzles_lock.lock()
	_puzzles.push_back(puzzle)
	DataPersistence.store_puzzle(puzzle)
	_puzzles_lock.unlock()

	_in_flight_lock.lock()
	_in_flight -= 1
	_in_flight_lock.unlock()

	DataPersistence.save()
	puzzle_generated_sem.post()
	puzzle_generated.emit.call_deferred(self)


func _fill_grid(puzzle: Puzzle, index: int) -> bool:
	if index >= puzzle.cells.size():
		return true

	var cell: Cell = puzzle.cells[index]
	var types := TYPES.duplicate()
	types.shuffle()

	for type in types:
		cell.type = type
		if puzzle.get_problem_cells().is_empty():
			if _fill_grid(puzzle, index + 1):
				return true

	cell.type = Cell.Type.EMPTY
	return false


func _should_stop() -> bool:
	_stop_lock.lock()
	var should_stop := _stop
	_stop_lock.unlock()
	if should_stop:
		_in_flight_lock.lock()
		_in_flight -= 1
		_in_flight_lock.unlock()
	return should_stop


func _generate_puzzle(size: int) -> Puzzle:
	print("Generating %dx%d puzzle..." % [grid_size, grid_size])
	var puzzle := Puzzle.new(size)

	var start_ticks := Time.get_ticks_msec()
	_fill_grid(puzzle, 0)
	var end_ticks := Time.get_ticks_msec()
	print("Generation for %dx%d took %dms" % [grid_size, grid_size, end_ticks - start_ticks])

	for cell in puzzle.cells:
		if _should_stop():
			return null
		if cell.type == Cell.Type.EMPTY:
			continue
		for direction in Cell.Direction.values():
			if cell.get_constraint(direction) != Cell.Constraint.NONE:
				continue
			if randf() > CONSTRAINT_CHANCE:
				continue
			cell.constrain_direction(direction)
			var neighbor := cell.get_neighbor(direction)
			if neighbor != null:
				neighbor.constrain_direction(Cell.invert_direction(direction))

	puzzle.cells.pick_random().type = Cell.Type.EMPTY

	if not OS.has_feature("editor") or not debug:
		start_ticks = Time.get_ticks_msec()
		var remove_attempt := 0
		while remove_attempt < size * size:
			if _should_stop():
				return null
			var filled_cells := puzzle.get_filled_cells()
			var cell: Cell = filled_cells.pick_random()
			var filled_type := cell.type
			cell.type = Cell.Type.EMPTY
			if PuzzleSolver.solve(puzzle):
				remove_attempt = 0
			else:
				cell.type = filled_type
				remove_attempt += 1
		end_ticks = Time.get_ticks_msec()
		print("Removal for %dx%d took %dms" % [grid_size, grid_size, end_ticks - start_ticks])

	for filled_cell in puzzle.get_filled_cells():
		filled_cell.locked = true

	return puzzle
