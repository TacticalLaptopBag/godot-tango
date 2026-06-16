class_name Tile
extends Sprite2D


@export var invalid_color := Color.RED
@export var locked_color := Color.GRAY
@export var invalid_locked_color := Color.DARK_RED
@export var tap_haptics := HapticConfig.new()
@export var long_press_haptics := HapticConfig.new()
@export var invalid_haptics := HapticConfig.new()

@onready var sun: Sprite2D = $Sun
@onready var moon: Sprite2D = $Moon
@onready var locked_sprite: Sprite2D = $Locked
@onready var invalid_sprite: Sprite2D = $Invalid
@onready var click_detector: Area2D = $ClickDetector
@onready var north_constraint_equals: Sprite2D = $NorthConstraintEquals
@onready var north_constraint_opposite: Sprite2D = $NorthConstraintOpposite
@onready var east_constraint_equals: Sprite2D = $EastConstraintEquals
@onready var east_constraint_opposite: Sprite2D = $EastConstraintOpposite
@onready var long_press_timer: Timer = $LongPressTimer
@onready var invalid_timer: Timer = $InvalidTimer
@onready var selection_indicator: Sprite2D = $SelectionIndicator

signal cell_type_changed(cell: Cell, old_type: Cell.Type)


var selected := false:
	set(value):
		selected = value
		_update_selected_appearance()


var cell: Cell = null:
	set(value):
		if cell != null:
			cell.type_changed.disconnect(_on_cell_type_changed)
			cell.invalid_changed.disconnect(_on_cell_invalid_changed)
			cell.locked_changed.disconnect(_on_cell_locked_changed)
			cell.constraint_changed.disconnect(_on_cell_constraint_changed)
		cell = value
		cell.type_changed.connect(_on_cell_type_changed)
		cell.invalid_changed.connect(_on_cell_invalid_changed)
		cell.locked_changed.connect(_on_cell_locked_changed)
		cell.constraint_changed.connect(_on_cell_constraint_changed)
		_update_appearance()


func _update_appearance():
	_update_type_appearance()
	_on_cell_locked_changed(cell, cell.locked)
	_on_cell_constraint_changed(cell, Cell.Direction.NORTH, Cell.Constraint.NONE)
	_update_selected_appearance()
	_update_invalid_appearance()


func _update_selected_appearance():
	selection_indicator.visible = selected


func _on_click_detector_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if cell.locked:
		return

	if event is InputEventMouseButton:
		if event.is_pressed():
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
				long_press_timer.start()
		elif event.is_released():
			if event.button_index == MouseButton.MOUSE_BUTTON_LEFT and not long_press_timer.is_stopped():
				long_press_timer.stop()
				toggle_tile_type()
				tap_haptics.vibrate()
			elif event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
				toggle_moon_tile()
			elif event.button_index == MouseButton.MOUSE_BUTTON_MIDDLE:
				clear_tile()


func _on_long_press_timer_timeout():
	toggle_moon_tile()
	long_press_haptics.vibrate()


func toggle_tile_type():
	if cell.locked:
		return

	var new_type: Cell.Type
	match cell.type:
		Cell.Type.EMPTY:
			new_type = Cell.Type.SUN
		Cell.Type.SUN:
			new_type = Cell.Type.MOON
		_:
			new_type = Cell.Type.EMPTY
	cell.type = new_type


func toggle_moon_tile():
	if cell.locked:
		return

	var new_type := Cell.Type.EMPTY if cell.type == Cell.Type.MOON else Cell.Type.MOON
	cell.type = new_type


func clear_tile():
	if cell.locked:
		return

	cell.type = Cell.Type.EMPTY


func _update_color():
	if cell.invalid and cell.locked:
		self_modulate = invalid_locked_color
		return

	if cell.invalid:
		self_modulate = invalid_color
		return

	if cell.locked:
		self_modulate = locked_color
		return
	
	self_modulate = Color.WHITE


func _update_type_appearance():
	sun.visible = cell.type == Cell.Type.SUN
	moon.visible = cell.type == Cell.Type.MOON


func _update_invalid_appearance():
	invalid_sprite.visible = cell.invalid
	_update_color()
	if cell.invalid:
		invalid_haptics.vibrate()


func _on_cell_type_changed(_cell: Cell, old_type: Cell.Type):
	# print("Cell at "+str(cell.position)+" changed type to "+str(cell.type))
	_update_type_appearance()
	cell_type_changed.emit(cell, old_type)


func _on_cell_invalid_changed(_cell: Cell, _old_invalid: bool):
	# print("Cell at "+str(cell.position)+" changed invalid to "+str(cell.invalid))
	if cell.invalid:
		invalid_timer.start()
	else:
		invalid_timer.stop()
		_update_invalid_appearance()


func _on_cell_locked_changed(_cell: Cell, _old_locked: bool):
	# print("Cell at "+str(cell.position)+" changed locked to "+str(cell.locked))
	click_detector.monitorable = not cell.locked
	click_detector.monitoring = not cell.locked
	locked_sprite.visible = cell.locked
	_update_color()


func _on_cell_constraint_changed(_cell: Cell, _direction: Cell.Direction, _old_constraint: Cell.Constraint):
	north_constraint_equals.visible = cell.north_constraint == Cell.Constraint.EQUAL
	north_constraint_opposite.visible = cell.north_constraint == Cell.Constraint.OPPOSITE
	east_constraint_equals.visible = cell.east_constraint == Cell.Constraint.EQUAL
	east_constraint_opposite.visible = cell.east_constraint == Cell.Constraint.OPPOSITE


func update_transform(grid_size: int, tile_padding: int, grid_padding: Vector2):
	var viewport_size := get_viewport().get_visible_rect().size - (grid_padding * 2)
	var cell_size: float = min(viewport_size.x / grid_size, viewport_size.y / grid_size)
	var texture_size := Vector2(texture.get_width(), texture.get_height())
	
	var scale_factor := Vector2(cell_size, cell_size) / texture_size
	var tile_size := texture_size * scale_factor
	var tile_position := (cell.position - Vector2(grid_size / 2.0, grid_size / 2.0)) * (tile_size + Vector2(tile_padding, tile_padding))
	tile_position += tile_size / 2.0
	
	position = tile_position
	scale = scale_factor


func _on_invalid_timer_timeout() -> void:
	_update_invalid_appearance()
