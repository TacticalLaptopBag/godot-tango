extends Node


@onready var _persistence: Persistence = $Persistence

var grid_size: int:
	get:
		return _persistence.data.get_or_add("grid_size", 6)
	set(value):
		_persistence.data["grid_size"] = value
var vibrate: bool:
	get:
		return _persistence.data.get_or_add("vibrate", true)
	set(value):
		_persistence.data["vibrate"] = value


func save():
	_persistence.save()


func serialize_puzzle(puzzle: Puzzle) -> String:
	var serialized_puzzle := "%d\n" % puzzle.grid_size()
	for cell in puzzle.cells:
		serialized_puzzle += "%s,%s:%d:%d,%d,%d,%d\n" % [
			cell.position.x,
			cell.position.y,
			cell.type,
			cell.north_constraint,
			cell.east_constraint,
			cell.south_constraint,
			cell.west_constraint,
		]
	return serialized_puzzle


func deserialize_puzzle(data: String) -> Puzzle:
	# grid_size
	# x,y:type:n,e,s,w
	var data_split := data.split("\n")
	var puzzle_grid_size := int(data_split[0])
	var puzzle := Puzzle.new(puzzle_grid_size)
	for cell_data in data_split.slice(1):
		if cell_data.is_empty():
			continue
		var cell_split := cell_data.split(":")

		var grid_position_str := cell_split[0]
		var grid_pos_split := grid_position_str.split(",")
		var grid_position := Vector2(int(grid_pos_split[0]), int(grid_pos_split[1]))

		var cell_type := int(cell_split[1]) as Cell.Type

		var constraints_str := cell_split[2]
		var constraints_split = constraints_str.split(",")
		var constraint_north := int(constraints_split[0]) as Cell.Constraint
		var constraint_east := int(constraints_split[1]) as Cell.Constraint
		var constraint_south := int(constraints_split[2]) as Cell.Constraint
		var constraint_west := int(constraints_split[3]) as Cell.Constraint

		var cell := puzzle.get_cell(grid_position)
		cell.type = cell_type
		cell.north_constraint = constraint_north
		cell.east_constraint = constraint_east
		cell.south_constraint = constraint_south
		cell.west_constraint = constraint_west
	return puzzle


func store_puzzle(puzzle: Puzzle):
	var puzzle_key := "puzzles_%d" % puzzle.grid_size()
	var puzzle_data := serialize_puzzle(puzzle)
	var stored_puzzles: Array = _persistence.data.get_or_add(puzzle_key, [])
	stored_puzzles.append(puzzle_data)
	_persistence.data[puzzle_key] = stored_puzzles


func remove_first_puzzle(puzzle_grid_size: int):
	var puzzle_key := "puzzles_%d" % puzzle_grid_size
	var stored_puzzles: Array = _persistence.data.get_or_add(puzzle_key, [])
	stored_puzzles.pop_front()
	_persistence.data[puzzle_key] = stored_puzzles


func fetch_puzzles(puzzle_grid_size: int) -> Array[Puzzle]:
	var puzzle_key := "puzzles_%d" % puzzle_grid_size
	var stored_puzzle_data: Array = _persistence.data.get_or_add(puzzle_key, [])
	var puzzles: Array[Puzzle] = []

	for puzzle_data in stored_puzzle_data:
		puzzles.append(deserialize_puzzle(puzzle_data))

	return puzzles
