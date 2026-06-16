extends Button


func _ready() -> void:
	pressed.connect(_on_pressed)
	PuzzleProvider.puzzle_generated.connect(_on_puzzle_generated)
	_on_puzzle_generated(PuzzleProvider.get_available_sizes())


func _on_pressed():
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_puzzle_generated(available_sizes: Array[int]):
	disabled = DataPersistence.grid_size not in available_sizes
