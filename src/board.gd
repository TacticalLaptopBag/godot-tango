class_name Board
extends Node


# TODO: Victory animation/screen
# TODO: Title screen
# TODO: Art


@export var size := 6
@export var padding := 12
@export var grid_padding := Vector2(50, 50)
@export var tile_scene: PackedScene

@onready var puzzle := Puzzle.new(size):
	set(value):
		puzzle = value
		update_board()

var tiles: Array[Tile] = []
var changes: Array[Change] = []
var undoing := false


signal cell_type_changed(cell: Cell, old_type: Cell.Type)


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
	tile.cell_type_changed.connect(_on_cell_type_changed)
	tile.update_transform(size, padding, grid_padding)
	return tile


func update_board():
	if tiles.size() != puzzle.cells.size():
		clear_board()
		create_board()
	else:
		for tile in tiles:
			tile.cell = puzzle.get_cell(tile.cell.position)
	changes.clear()


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


func _on_cell_type_changed(cell: Cell, old_type: Cell.Type):
	print("Cell changed: "+str(cell.position)+": "+str(cell.type))
	_update_state()
	if not undoing:
		var change := Change.new(cell, old_type, cell.type)
		changes.push_back(change)
	else:
		undoing = false
	cell_type_changed.emit(cell, old_type)


func _on_viewport_size_changed():
	for tile in tiles:
		tile.update_transform(size, padding, grid_padding)


func undo():
	var change: Change = changes.pop_back()
	if change == null:
		return
	
	undoing = true
	change.cell.type = change.old_type
