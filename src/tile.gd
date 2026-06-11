class_name Tile
extends Sprite2D


@export var invalid_color := Color.RED
@export var locked_color := Color.GRAY
@export var invalid_locked_color := Color.DARK_RED

@onready var sun: Sprite2D = $Sun
@onready var moon: Sprite2D = $Moon
@onready var invalid_sprite: Sprite2D = $Invalid
@onready var click_detector: Area2D = $ClickDetector
@onready var north_constraint_equals: Sprite2D = $NorthConstraintEquals
@onready var north_constraint_opposite: Sprite2D = $NorthConstraintOpposite
@onready var east_constraint_equals: Sprite2D = $EastConstraintEquals
@onready var east_constraint_opposite: Sprite2D = $EastConstraintOpposite


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
    _on_cell_type_changed(cell)
    _on_cell_invalid_changed(cell)
    _on_cell_locked_changed(cell)
    _on_cell_constraint_changed(cell, Cell.Direction.NORTH)


func _on_click_detector_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    if cell.locked:
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
    var new_type := Cell.Type.EMPTY if cell.type == Cell.Type.MOON else Cell.Type.MOON
    cell.type = new_type


func clear_tile():
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


func _on_cell_type_changed(_cell: Cell):
    # print("Cell at "+str(cell.position)+" changed type to "+str(cell.type))
    sun.visible = cell.type == Cell.Type.SUN
    moon.visible = cell.type == Cell.Type.MOON


func _on_cell_invalid_changed(_cell: Cell):
    # print("Cell at "+str(cell.position)+" changed invalid to "+str(cell.invalid))
    invalid_sprite.visible = cell.invalid
    _update_color()


func _on_cell_locked_changed(_cell: Cell):
    # print("Cell at "+str(cell.position)+" changed locked to "+str(cell.locked))
    click_detector.monitorable = not cell.locked
    click_detector.monitoring = not cell.locked
    _update_color()


func _update_constraint_label(label: Label, constraint: Cell.Constraint):
    match constraint:
        Cell.Constraint.NONE:
            label.text = ""
        Cell.Constraint.EQUAL:
            label.text = "="
        Cell.Constraint.OPPOSITE:
            label.text = "X"


func _on_cell_constraint_changed(_cell: Cell, _direction: Cell.Direction):
    north_constraint_equals.visible = cell.north_constraint == Cell.Constraint.EQUAL
    north_constraint_opposite.visible = cell.north_constraint == Cell.Constraint.OPPOSITE
    east_constraint_equals.visible = cell.east_constraint == Cell.Constraint.EQUAL
    east_constraint_opposite.visible = cell.east_constraint == Cell.Constraint.OPPOSITE
