extends Node


@export var size := 6
@export var padding := 12

@export var tile_scene: PackedScene


func _ready():
	create_board()


func create_tile(grid_position: Vector2):
	var tile: Sprite2D = tile_scene.instantiate()
	add_child(tile)
	var size := Vector2(tile.texture.get_width() * tile.scale.x, tile.texture.get_height() * tile.scale.y)
	var position := grid_position * (size + Vector2(padding, padding))
	tile.position = position


func create_board():
	for x in range(size):
		for y in range(size):
			create_tile(Vector2(x, y))
