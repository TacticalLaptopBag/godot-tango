extends HBoxContainer


@onready var x4: Button = $"4x4"
@onready var x6: Button = $"6x6"
@onready var x8: Button = $"8x8"


func _ready() -> void:
	x4.toggled.connect(_on_x4_toggled)
	x6.toggled.connect(_on_x6_toggled)
	x8.toggled.connect(_on_x8_toggled)
	var grid_size = DataPersistence.data.get_or_add("grid_size", 6)
	x4.button_pressed = grid_size == 4
	x6.button_pressed = grid_size == 6
	x8.button_pressed = grid_size == 8


func _set_grid_size(grid_size: int):
	DataPersistence.data["grid_size"] = grid_size
	DataPersistence.save()


func _on_x4_toggled(toggled_on: bool):
	if not toggled_on: return
	_set_grid_size(4)


func _on_x6_toggled(toggled_on: bool):
	if not toggled_on: return
	_set_grid_size(6)


func _on_x8_toggled(toggled_on: bool):
	if not toggled_on: return
	_set_grid_size(8)
