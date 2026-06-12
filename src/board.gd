class_name Board
extends Node


@export var size := 6
@export var padding := 12
@export var grid_padding := Vector2(50, 50)
@export var tile_scene: PackedScene

@export var invalid_haptics := HapticConfig.new()


@onready var puzzle := Puzzle.new(size):
	set(value):
		puzzle = value
		update_board()

var tiles: Array[Tile] = []


func _ready():
	puzzle = PuzzleProvider.generate_puzzle(size)
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func get_tile(grid_position: Vector2i) -> Tile:
	return Util.get_item_from_2d(grid_position, tiles, puzzle.grid_size(), puzzle.grid_size())


func create_tile(cell: Cell) -> Tile:
	var tile: Tile = tile_scene.instantiate()
	add_child(tile)
	#var tile_size := Vector2(tile.texture.get_width() * tile.scale.x, tile.texture.get_height() * tile.scale.y)
	#var position := (cell.position - Vector2(size / 2.0, size / 2.0)) * (tile_size + Vector2(padding, padding))
	#tile.position = position + tile_size / 2.0
	tile.cell = cell
	tile.cell.type_changed.connect(_on_cell_type_changed)
	tile.update_transform(size, padding, grid_padding)
	return tile


func update_board():
	if tiles.size() != puzzle.cells.size():
		clear_board()
		create_board()
	else:
		for tile in tiles:
			tile.cell = puzzle.get_cell(tile.cell.position)


func clear_board():
	for tile in tiles:
		tile.queue_free()
	tiles = []


func create_board():
	for cell in puzzle.cells:
		var tile := create_tile(cell)
		tiles.append(tile)


func _update_state():
	var is_valid := puzzle.validate()
	if is_valid and puzzle.is_filled():
		print("win!")
		for cell in puzzle.cells:
			cell.locked = true
	elif not is_valid:
		invalid_haptics.vibrate()


func _on_cell_type_changed(cell: Cell):
	print("Cell changed: "+str(cell.position)+": "+str(cell.type))
	_update_state()


func _on_viewport_size_changed():
	for tile in tiles:
		tile.update_transform(size, padding, grid_padding)
