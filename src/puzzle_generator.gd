class_name PuzzleGenerator
extends Resource

const TYPES := [Cell.Type.SUN, Cell.Type.MOON]
const ATTEMPT_TIMEOUT_MS := 30000
const CONSTRAINT_CHANCE := 0.05


@export var debug := false
@export var pool_size := 10
@export var grid_size := 6

var _puzzles: Array[Puzzle] = []
var _puzzles_lock := Mutex.new()
var puzzle_generated_sem := Semaphore.new()

var _exiting := false
var _exiting_lock := Mutex.new()
var _generator_sem := Semaphore.new()
var _generator_thread: Thread = null

signal puzzle_generated(generator: PuzzleGenerator)


# TODO: WorkerThreadPool


func queue_generation():
	if _generator_thread == null:
		_generator_thread = Thread.new()
		_generator_thread.start(_generator)
	_generator_sem.post()


func is_puzzle_ready():
	_puzzles_lock.lock()
	var size := _puzzles.size()
	_puzzles_lock.unlock()
	return size


func get_puzzle() -> Puzzle:
	_puzzles_lock.lock()
	var puzzle: Puzzle = _puzzles.pop_front()
	_puzzles_lock.unlock()

	_generator_sem.post()
	if puzzle == null:
		puzzle_generated_sem.wait()
		return get_puzzle()
	
	return puzzle


func start_cleanup():
	_exiting_lock.lock()
	_exiting = true
	_exiting_lock.unlock()
	_generator_sem.post()


func wait_for_cleanup_finish():
	_generator_thread.wait_to_finish()


func _generator():
	while true:
		_generator_sem.wait()

		_exiting_lock.lock()
		var should_exit := _exiting
		_exiting_lock.unlock()

		if should_exit:
			break

		_puzzles_lock.lock()
		var puzzles_size := _puzzles.size()
		_puzzles_lock.unlock()
		for _i in range(pool_size - puzzles_size):
			var puzzle := _generate_puzzle(grid_size)
			_puzzles_lock.lock()
			_puzzles.push_back(puzzle)
			DataPersistence.data["puzzles_%d" % grid_size] = _puzzles.duplicate()
			_puzzles_lock.unlock()
			puzzle_generated_sem.post()
			puzzle_generated.emit.call_deferred(self)
		DataPersistence.save()


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


func _generate_puzzle(size: int) -> Puzzle:
	# TODO: Generating an 8x8 puzzle takes far too long
	print("Generating %dx%d puzzle..." % [grid_size, grid_size])
	var puzzle := Puzzle.new(size)

	var start_ticks := Time.get_ticks_msec()
	_fill_grid(puzzle, 0)
	var end_ticks := Time.get_ticks_msec()
	print("Generation for %dx%d took %dms" % [grid_size, grid_size, end_ticks - start_ticks])

	for cell in puzzle.cells:
		if cell.type == Cell.Type.EMPTY:
			continue
		for direction in Cell.Direction.values():
			if cell.get_constraint(direction) != Cell.Constraint.NONE:
				# Direction already constrained previously, check others
				continue
			if randf() > CONSTRAINT_CHANCE:
				continue
			cell.constrain_direction(direction)
			var neighbor := cell.get_neighbor(direction)
			if neighbor != null:
				neighbor.constrain_direction(Cell.invert_direction(direction))

	# Removing one cell will always remain solvable
	puzzle.cells.pick_random().type = Cell.Type.EMPTY

	if not OS.has_feature("editor") or not debug:
		start_ticks = Time.get_ticks_msec()
		var remove_attempt := 0
		while remove_attempt < size * size:
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
