class_name Tile
extends Sprite2D


@export var invalid_color := Color.RED
@export var locked_color := Color.GRAY
@export var invalid_locked_color := Color.DARK_RED

@onready var sun: Sprite2D = $Sun
@onready var moon: Sprite2D = $Moon
@onready var invalid_sprite: Sprite2D = $Invalid
@onready var click_detector: Area2D = $ClickDetector

@onready var north_constraint_label: Label = $NorthConstraint
@onready var south_constraint_label: Label = $SouthConstraint
@onready var east_constraint_label: Label = $EastConstraint
@onready var west_constraint_label: Label = $WestConstraint


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
    for direction in Cell.Direction.values():
        _on_cell_constraint_changed(cell, direction)


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


func _on_cell_constraint_changed(_cell: Cell, direction: Cell.Direction):
    var constraint := cell.get_constraint(direction)
    match direction:
        Cell.Direction.NORTH:
            _update_constraint_label(north_constraint_label, constraint)
        Cell.Direction.SOUTH:
            _update_constraint_label(south_constraint_label, constraint)
        Cell.Direction.EAST:
            _update_constraint_label(east_constraint_label, constraint)
        Cell.Direction.WEST:
            _update_constraint_label(west_constraint_label, constraint)
