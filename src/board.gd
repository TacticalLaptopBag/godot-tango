class_name Board
extends Node2D


# TODO: Title screen
	# TODO: Return to title screen from game
# TODO: Fix constraints not being rendered in certain unknown cases
# TODO: Art


@export var padding := 12
@export var grid_padding := Vector2(50, 50)
@export var tile_scene: PackedScene

var bounding_box := Vector2.ZERO
var grid_size := 6:
	get:
		return DataPersistence.grid_size

@onready var puzzle := Puzzle.new(grid_size):
	set(value):
		puzzle = value
		update_board()
		start_ticks = Time.get_ticks_msec()
		end_ticks = -1
		puzzle_changed.emit()

var tiles: Array[Tile] = []
var changes: Array[Change] = []
var undoing := false
var start_ticks := -1
var end_ticks := -1

signal puzzle_changed()
signal cell_type_changed(cell: Cell, old_type: Cell.Type)
signal puzzle_completed(start_ticks: int, end_ticks: int)


func _ready():
	puzzle = PuzzleProvider.get_puzzle(grid_size)
	get_viewport().size_changed.connect(_on_viewport_size_changed)


func get_tile(grid_position: Vector2i) -> Tile:
	return Util.get_item_from_2d(grid_position, tiles, puzzle.grid_size(), puzzle.grid_size())


func create_tile(cell: Cell) -> Tile:
	var tile: Tile = tile_scene.instantiate()
	add_child(tile)
	tile.cell = cell
	tile.cell_type_changed.connect(_on_cell_type_changed)
	tile.update_transform(grid_size, padding, grid_padding)
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
	_update_bounding_box()


func _update_state():
	var is_valid := puzzle.validate()
	if is_valid and puzzle.is_filled():
		print("you're winner!")
		for cell in puzzle.cells:
			cell.locked = true
			
		end_ticks = Time.get_ticks_msec()
		puzzle_completed.emit(start_ticks, end_ticks)


func _update_bounding_box():
	var top_left := tiles[0].position - (tiles[0].texture.get_size() * tiles[0].scale) / 2
	var bottom_right := tiles[-1].position + (tiles[-1].texture.get_size() * tiles[-1].scale) / 2
	bounding_box = bottom_right - top_left


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
		tile.update_transform(grid_size, padding, grid_padding)
	_update_bounding_box()


func undo():
	var change: Change = changes.pop_back()
	if change == null:
		return
	
	undoing = true
	change.cell.type = change.old_type
