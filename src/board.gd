extends Node


@export var size := 6
@export var padding := 12
@export var tile_scene: PackedScene

@onready var tiles: Array[Sprite2D] = []


enum LineType {
	COLUMN,
	ROW,
}


func _ready():
	create_board()


func get_tile(grid_position: Vector2i) -> Sprite2D:
	if grid_position.x < 0 or grid_position.y < 0:
		return null
	if grid_position.x >= size or grid_position.y >= size:
		return null
	
	var row_start := size * grid_position.y
	var tile_idx = row_start + grid_position.x
	if tile_idx >= tiles.size():
		return null
	
	return tiles[tile_idx]


func create_tile(grid_position: Vector2) -> Sprite2D:
	var tile: Tile = tile_scene.instantiate()
	add_child(tile)
	var tile_size := Vector2(tile.texture.get_width() * tile.scale.x, tile.texture.get_height() * tile.scale.y)
	var position := (grid_position - Vector2(size / 2.0, size / 2.0)) * (tile_size + Vector2(padding, padding))
	tile.position = position + tile_size / 2.0
	tile.grid_position = grid_position
	tile.changed.connect(_on_tile_changed)
	return tile


func create_board():
	for y in range(size):
		for x in range(size):
			var tile := create_tile(Vector2(x, y))
			tiles.append(tile)
	
	for tile in tiles:
		tile.north = get_tile(tile.grid_position - Vector2(0, 1))
		tile.south = get_tile(tile.grid_position + Vector2(0, 1))
		tile.west = get_tile(tile.grid_position - Vector2(1, 0))
		tile.east = get_tile(tile.grid_position + Vector2(1, 0))


func _find_invalid_lines(line_type: LineType) -> Array[Tile]:
	var direction := Tile.Direction.SOUTH if line_type == LineType.COLUMN else Tile.Direction.EAST
	var start_mask := Vector2i(1, 0) if line_type == LineType.COLUMN else Vector2i(0, 1)
	
	var problem_tiles: Array[Tile] = []
	for i in range(size):
		var current_tile = get_tile(i * start_mask)
		var moon_count := 0
		var sun_count := 0
		var line_tiles: Array[Tile] = []
		while current_tile != null and current_tile.current_type != Tile.TileType.Empty:
			if current_tile.current_type == Tile.TileType.Sun:
				sun_count += 1
			else:
				moon_count += 1
			line_tiles.append(current_tile)
			current_tile = current_tile.get_neighbor(direction)
		
		if line_tiles.size() == size && moon_count != sun_count:
			problem_tiles.append_array(line_tiles)
	
	return problem_tiles


func _get_problem_tiles() -> Array[Tile]:
	var problem_tiles: Array[Tile] = []
	for tile in tiles:
		tile.invalid = false
		problem_tiles.append_array(tile.has_three_in_a_row())
	
	problem_tiles.append_array(_find_invalid_lines(LineType.COLUMN))
	problem_tiles.append_array(_find_invalid_lines(LineType.ROW))
	return problem_tiles


func _is_filled() -> bool:
	for tile in tiles:
		if tile.current_type == Tile.TileType.Empty:
			return false
	return true


func _update_state():
	var problem_tiles := _get_problem_tiles()
	for problem_tile in problem_tiles:
		problem_tile.invalid = true
	
	if problem_tiles.is_empty():
		if _is_filled():
			print("win!")


func _on_tile_changed(tile: Tile):
	print("Tile changed: "+str(tile.grid_position)+": "+str(tile.current_type))
	_update_state()
