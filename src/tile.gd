class_name Tile
extends Sprite2D


enum TileType {
	Empty,
	Sun,
	Moon,
}

enum Direction {
	NORTH,
	EAST,
	SOUTH,
	WEST,
}


@onready var sun: Sprite2D = $Sun
@onready var moon: Sprite2D = $Moon
@onready var invalid_sprite: Sprite2D = $Invalid
@onready var click_detector: Area2D = $ClickDetector

var north: Tile = null
var east: Tile = null
var south: Tile = null
var west: Tile = null

var current_type := TileType.Empty
var locked := false
var invalid := false:
	set(value):
		invalid = value
		self_modulate = Color.RED if invalid else Color.WHITE
		invalid_sprite.visible = invalid
		
var grid_position := Vector2(-1, -1)

signal changed(tile: Tile)


func get_neighbor(direction: Direction) -> Tile:
	match direction:
		Direction.NORTH:
			return north
		Direction.EAST:
			return east
		Direction.SOUTH:
			return south
		Direction.WEST:
			return west
	return null


func _on_click_detector_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if locked:
		return

	if event is InputEventMouseButton and event.is_pressed():
		if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
			toggle_tile_type()
		elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			toggle_moon_tile()
			pass
		elif event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE:
			clear_tile()
			pass


func toggle_tile_type():
	var new_type: TileType
	match current_type:
		TileType.Empty:
			new_type = TileType.Sun
		TileType.Sun:
			new_type = TileType.Moon
		_:
			new_type = TileType.Empty
	set_tile_type(new_type)


func toggle_moon_tile():
	var new_type := TileType.Empty if current_type == TileType.Moon else TileType.Moon
	set_tile_type(new_type)


func clear_tile():
	set_tile_type(TileType.Empty)


func set_tile_type(tile_type: TileType):
	if current_type == tile_type:
		return
	current_type = tile_type
	sun.visible = current_type == TileType.Sun
	moon.visible = current_type == TileType.Moon
	changed.emit(self)
	

func has_three_in_a_row() -> Array[Tile]:
	if current_type == TileType.Empty:
		return []
	
	var problem_tiles: Array[Tile] = []
	# Check vertical
	if north != null and south != null:
		if north.current_type == south.current_type && north.current_type == current_type:
			problem_tiles.append_array([north, self, south])
	
	# Check horizontal
	if east != null and west != null:
		if east.current_type == west.current_type && east.current_type == current_type:
			problem_tiles.append_array([east, self, west])
	
	return problem_tiles
