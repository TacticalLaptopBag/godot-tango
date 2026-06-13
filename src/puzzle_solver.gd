class_name PuzzleSolver
extends Object


static func save_snapshot(puzzle: Puzzle) -> Dictionary[Cell, Cell.Type]:
	var cells_snapshot: Dictionary[Cell, Cell.Type] = {}
	for cell in puzzle.cells:
		cells_snapshot[cell] = cell.type
	return cells_snapshot


static func restore_snapshot(snapshot: Dictionary[Cell, Cell.Type]):
	for cell in snapshot:
		cell.type = snapshot[cell]


# Attempts to solve `puzzle` entirely through logical deduction.
# Returns true if the puzzle is fully solved, false if it got stuck
# (i.e. the puzzle is ambiguous or requires guessing with the current
# rule set — useful signal for the generator).
#
# The puzzle is modified in-place. Locked cells are never touched.
# Call this on a Puzzle that already has its clue cells filled + locked
# and its constraints placed.
static func solve(puzzle: Puzzle) -> bool:
	var snapshot := save_snapshot(puzzle)
	var progress := true
	while progress:
		progress = false
		progress = _apply_balance_rule(puzzle)    or progress
		progress = _apply_no_three_rule(puzzle)   or progress
		progress = _apply_constraint_rule(puzzle) or progress

	var is_solvable := puzzle.is_filled() and puzzle.validate()
	restore_snapshot(snapshot)
	return is_solvable


# ---------------------------------------------------------------------------
# Rule 1 — Balance
# If a row or column already has N/2 cells of one type, every remaining
# empty cell in that line must be the other type.
# ---------------------------------------------------------------------------
static func _apply_balance_rule(puzzle: Puzzle) -> bool:
	var changed := false
	var size := puzzle.grid_size()
	var half := size / 2

	for i in range(size):
		# --- ROW ---
		var row_cells := _get_row(puzzle, i)
		var row_result := _balance_line(row_cells, half)
		changed = row_result or changed

		# --- COLUMN ---
		var col_cells := _get_col(puzzle, i)
		var col_result := _balance_line(col_cells, half)
		changed = col_result or changed

	return changed


static func _balance_line(line: Array[Cell], half: int) -> bool:
	var sun_count := 0
	var moon_count := 0
	var empties: Array[Cell] = []

	for cell in line:
		if cell.type == Cell.Type.SUN:
			sun_count += 1
		elif cell.type == Cell.Type.MOON:
			moon_count += 1
		else:
			empties.append(cell)

	if empties.is_empty():
		return false

	var changed := false

	if sun_count == half:
		# All remaining empties must be MOON
		for cell in empties:
			if not cell.locked:
				cell.type = Cell.Type.MOON
				changed = true

	elif moon_count == half:
		# All remaining empties must be SUN
		for cell in empties:
			if not cell.locked:
				cell.type = Cell.Type.SUN
				changed = true

	return changed


# ---------------------------------------------------------------------------
# Rule 2 — No-three
# If two consecutive filled cells of the same type exist, the cells
# immediately before and after them (if empty) must be the opposite type.
# We check all four directions so every pair is caught.
# ---------------------------------------------------------------------------
static func _apply_no_three_rule(puzzle: Puzzle) -> bool:
	var changed := false

	for cell in puzzle.cells:
		if cell.type == Cell.Type.EMPTY:
			continue

		for direction in [Cell.Direction.EAST, Cell.Direction.SOUTH]:
			var neighbor := cell.get_neighbor(direction)
			if neighbor == null or neighbor.type != cell.type:
				continue

			# cell and neighbor are the same type side-by-side.
			# The cell before `cell` in this direction must be opposite.
			var before := cell.get_neighbor(Cell.invert_direction(direction))
			if before != null and before.type == Cell.Type.EMPTY and not before.locked:
				before.type = _opposite(cell.type)
				changed = true

			# The cell after `neighbor` in this direction must be opposite.
			var after := neighbor.get_neighbor(direction)
			if after != null and after.type == Cell.Type.EMPTY and not after.locked:
				after.type = _opposite(cell.type)
				changed = true

	return changed


# ---------------------------------------------------------------------------
# Rule 3 — Constraint propagation
# If a filled cell has an EQUAL or OPPOSITE constraint toward an empty
# neighbor, deduce that neighbor's type directly.
#
# Additionally: if an empty cell has constraints from *two* filled
# neighbors that together force a single type, apply it.
# ---------------------------------------------------------------------------
static func _apply_constraint_rule(puzzle: Puzzle) -> bool:
	var changed := false

	for cell in puzzle.cells:
		for direction in Cell.Direction.values():
			var constraint := cell.get_constraint(direction)
			if constraint == Cell.Constraint.NONE:
				continue

			var neighbor := cell.get_neighbor(direction)
			if neighbor == null or neighbor.locked:
				continue

			# Case A: this cell is filled, neighbor is empty → deduce neighbor
			if cell.type != Cell.Type.EMPTY and neighbor.type == Cell.Type.EMPTY:
				var deduced := _deduce_from_constraint(cell.type, constraint)
				neighbor.type = deduced
				changed = true

			# Case B: neighbor is filled, this cell is empty → deduce this cell
			elif neighbor.type != Cell.Type.EMPTY and cell.type == Cell.Type.EMPTY and not cell.locked:
				var deduced := _deduce_from_constraint(neighbor.type, constraint)
				cell.type = deduced
				changed = true

	return changed


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

static func _deduce_from_constraint(source_type: Cell.Type, constraint: Cell.Constraint) -> Cell.Type:
	if constraint == Cell.Constraint.EQUAL:
		return source_type
	# OPPOSITE
	return _opposite(source_type)


static func _opposite(t: Cell.Type) -> Cell.Type:
	return Cell.Type.SUN if t == Cell.Type.MOON else Cell.Type.MOON


static func _get_row(puzzle: Puzzle, row: int) -> Array[Cell]:
	var size := puzzle.grid_size()
	var result: Array[Cell] = []
	for x in range(size):
		result.append(puzzle.get_cell(Vector2i(x, row)))
	return result


static func _get_col(puzzle: Puzzle, col: int) -> Array[Cell]:
	var size := puzzle.grid_size()
	var result: Array[Cell] = []
	for y in range(size):
		result.append(puzzle.get_cell(Vector2i(col, y)))
	return result
