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
var current_theme: String:
	get:
		return _persistence.data.get_or_add("theme", "Purple (Dark)")
	set(value):
		_persistence.data["theme"] = value


const PUZZLE_FMT := "puzzles_%d"
const SCORE_FMT := "score_%d"

var latest_score: Score = null


func save():
	_persistence.save()


func serialize_puzzle(puzzle: Puzzle) -> String:
	var serialized_puzzle := "v2:%d\n" % puzzle.grid_size()
	for cell in puzzle.cells:
		serialized_puzzle += "%s,%s:%d:%d:%d:%d,%d,%d,%d\n" % [
			cell.position.x,
			cell.position.y,
			cell.type,
			1 if cell.locked else 0,
			1 if cell.invalid else 0,
			cell.north_constraint,
			cell.east_constraint,
			cell.south_constraint,
			cell.west_constraint,
		]
	return serialized_puzzle


func deserialize_puzzle(data: String) -> Puzzle:
	var puzzle := deserialize_puzzle_v1(data)
	if puzzle == null:
		puzzle = deserialize_puzzle_v2(data)
	return puzzle


func deserialize_puzzle_v2(data: String) -> Puzzle:
	# v2:grid_size
	# x,y:type:locked:invalid:n,e,s,w
	var data_split := data.split("\n")
	var puzzle_header := data_split[0].split(":")
	var puzzle_version = puzzle_header[0]
	if puzzle_version != "v2":
		return null

	var puzzle_grid_size := int(puzzle_header[1])
	var puzzle := Puzzle.new(puzzle_grid_size)
	for cell_data in data_split.slice(1):
		if cell_data.is_empty():
			continue
		var cell_split := cell_data.split(":")

		var grid_position_str := cell_split[0]
		var grid_pos_split := grid_position_str.split(",")
		var grid_position := Vector2(int(grid_pos_split[0]), int(grid_pos_split[1]))

		var cell_type := int(cell_split[1]) as Cell.Type
		var cell_locked := int(cell_split[2]) != 0
		var cell_invalid := int(cell_split[3]) != 0

		var constraints_str := cell_split[4]
		var constraints_split = constraints_str.split(",")
		var constraint_north := int(constraints_split[0]) as Cell.Constraint
		var constraint_east := int(constraints_split[1]) as Cell.Constraint
		var constraint_south := int(constraints_split[2]) as Cell.Constraint
		var constraint_west := int(constraints_split[3]) as Cell.Constraint

		var cell := puzzle.get_cell(grid_position)
		cell.type = cell_type
		cell.locked = cell_locked
		cell.invalid = cell_invalid
		cell.north_constraint = constraint_north
		cell.east_constraint = constraint_east
		cell.south_constraint = constraint_south
		cell.west_constraint = constraint_west
	return puzzle


func deserialize_puzzle_v1(data: String) -> Puzzle:
	# grid_size
	# x,y:type:n,e,s,w
	var data_split := data.split("\n")
	if data_split[0].split(":").size() > 1:
		# Header contains puzzle data, which is not v1 spec
		return null

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
	var puzzle_key := PUZZLE_FMT % puzzle.grid_size()
	var puzzle_data := serialize_puzzle(puzzle)
	var stored_puzzles: Array = _persistence.data.get_or_add(puzzle_key, [])
	stored_puzzles.append(puzzle_data)
	_persistence.data[puzzle_key] = stored_puzzles


func remove_first_puzzle(puzzle_grid_size: int):
	var puzzle_key := PUZZLE_FMT % puzzle_grid_size
	var stored_puzzles: Array = _persistence.data.get_or_add(puzzle_key, [])
	stored_puzzles.pop_front()
	_persistence.data[puzzle_key] = stored_puzzles


func fetch_puzzles(puzzle_grid_size: int) -> Array[Puzzle]:
	var puzzle_key := PUZZLE_FMT % puzzle_grid_size
	var stored_puzzle_data: Array = _persistence.data.get_or_add(puzzle_key, [])
	var puzzles: Array[Puzzle] = []

	for puzzle_data in stored_puzzle_data:
		puzzles.append(deserialize_puzzle(puzzle_data))

	return puzzles


func serialize_score(score: Score) -> String:
	var serialized_score := "v1:%d\t%d" % [score.time_ms, score.timestamp]
	return serialized_score


func deserialize_score(data: String) -> Score:
	var score := deserialize_score_v1(data)
	return score


func deserialize_score_v1(data: String) -> Score:
	# v1:123	123
	var data_split := data.split(":")
	var score_version = data_split[0]
	if score_version != "v1":
		return null
	
	var score_data := data_split[1]
	var score_data_split := score_data.split("\t")
	var score_time_ms := int(score_data_split[0])
	var score_timestamp := int(score_data_split[1])
	return Score.new(score_time_ms, score_timestamp)


func store_score(score: Score, puzzle_grid_size: int):
	var score_data := serialize_score(score)
	var score_key := SCORE_FMT % puzzle_grid_size
	var stored_scores: Array = _persistence.data.get_or_add(score_key, [])

	# Insert s.t. faster times are at the front of the score array
	var insert_idx := 0
	for i in stored_scores.size():
		var stored_score_data: String = stored_scores[i]
		var stored_score := deserialize_score(stored_score_data)
		if score.time_ms > stored_score.time_ms:
			insert_idx += 1
		else:
			break

	stored_scores.insert(insert_idx, score_data)
	_persistence.data[score_key] = stored_scores
	latest_score = score


func fetch_scores(puzzle_grid_size: int) -> Array[Score]:
	var score_key := SCORE_FMT % puzzle_grid_size
	var stored_scores: Array = _persistence.data.get_or_add(score_key, [])
	var scores: Array[Score] = []

	for score_data in stored_scores:
		scores.append(deserialize_score(score_data))

	return scores
