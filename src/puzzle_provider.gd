extends Node


@export var debug := false

const TYPES := [Cell.Type.SUN, Cell.Type.MOON]
const ATTEMPT_TIMEOUT_MS := 10000
const CONSTRAINT_CHANCE := 0.05

var _generator_exit := false
var _cached_puzzles: Dictionary[int, Puzzle] = {
	4: null,
	6: null,
	8: null,
}
@onready var _cached_puzzles_lock := Mutex.new()
@onready var _generator_exit_lock := Mutex.new()
@onready var _generator_sem := Semaphore.new()
@onready var _puzzle_generated_sem := Semaphore.new()
@onready var _generator_thread := Thread.new()

signal puzzle_generated(available_sizes: Array[int])


func _ready():
	_generator_thread.start(_generate_puzzles)
	_generator_sem.post()


func get_puzzle(size: int) -> Puzzle:
	if not _cached_puzzles.has(size):
		push_error("Attempt to get puzzle of invalid size: %d" % size)
		return null

	_cached_puzzles_lock.lock()
	var puzzle := _cached_puzzles[size]
	_cached_puzzles[size] = null
	_cached_puzzles_lock.unlock()

	_generator_sem.post()
	if puzzle == null:
		_puzzle_generated_sem.wait()
		return get_puzzle(size)
	
	return puzzle


func _get_available_sizes() -> Array[int]:
	var available_sizes: Array[int] = []
	for grid_size in _cached_puzzles:
		if _cached_puzzles[grid_size] != null:
			available_sizes.append(grid_size)
	return available_sizes


func get_available_sizes() -> Array[int]:
	_cached_puzzles_lock.lock()
	var available_sizes := _get_available_sizes()
	_cached_puzzles_lock.unlock()
	return available_sizes


func _generate_puzzles():
	while true:
		_generator_sem.wait()

		_generator_exit_lock.lock()
		var should_exit := _generator_exit
		_generator_exit_lock.unlock()

		if should_exit:
			break

		var sizes_to_generate: Array[int] = []
		_cached_puzzles_lock.lock()
		for grid_size in _cached_puzzles:
			if _cached_puzzles[grid_size] == null:
				sizes_to_generate.append(grid_size)
		_cached_puzzles_lock.unlock()

		for grid_size in sizes_to_generate:
			var puzzle := _generate_puzzle(grid_size)
			_cached_puzzles_lock.lock()
			_cached_puzzles[grid_size] = puzzle
			var available_sizes := _get_available_sizes()
			_cached_puzzles_lock.unlock()
			_puzzle_generated_sem.post()
			puzzle_generated.emit.call_deferred(available_sizes)


func _generate_puzzle(size: int) -> Puzzle:
	var puzzle := Puzzle.new(size)

	var start_ticks := Time.get_ticks_msec()
	for cell in puzzle.cells:
		cell.type = TYPES.pick_random()
		var problem_cells := puzzle.get_problem_cells()
		while problem_cells.size() > 0:
			problem_cells.pick_random().invert()
			problem_cells = puzzle.get_problem_cells()
			if Time.get_ticks_msec() - start_ticks >= ATTEMPT_TIMEOUT_MS:
				# This is taking too long... try again
				return _generate_puzzle(size)
	var end_ticks := Time.get_ticks_msec()
	print("Generation took "+str(end_ticks - start_ticks)+"ms")

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
		print("Removal took "+str(end_ticks - start_ticks)+"ms")

	for filled_cell in puzzle.get_filled_cells():
		filled_cell.locked = true

	return puzzle
