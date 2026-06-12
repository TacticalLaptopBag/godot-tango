extends Node


const TYPES := [Cell.Type.SUN, Cell.Type.MOON]
const ATTEMPT_TIMEOUT_MS := 1000
const CONSTRAINT_CHANCE := 0.05


func generate_puzzle(size: int) -> Puzzle:
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
				return generate_puzzle(size)
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

	start_ticks = Time.get_ticks_msec()
	var remove_attempt := 0
	while remove_attempt < size:
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

	return puzzle
