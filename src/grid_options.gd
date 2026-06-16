extends HBoxContainer


@onready var buttons: Dictionary[int, Button] = {
	4: $"4x4",
	6: $"6x6",
	8: $"8x8",
}


func _ready() -> void:
	PuzzleProvider.puzzle_generated.connect(_on_puzzle_generated)
	buttons[4].toggled.connect(_on_x4_toggled)
	buttons[6].toggled.connect(_on_x6_toggled)
	buttons[8].toggled.connect(_on_x8_toggled)
	var grid_size = DataPersistence.data.get_or_add("grid_size", 6)
	var available_sizes = PuzzleProvider.get_available_sizes()
	for button_grid_size in buttons:
		var button := buttons[button_grid_size]
		button.button_pressed = button_grid_size == grid_size
		button.disabled = button_grid_size not in available_sizes


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


func _on_puzzle_generated(available_sizes: Array[int]):
	for button_grid_size in buttons:
		buttons[button_grid_size].disabled = button_grid_size not in available_sizes
