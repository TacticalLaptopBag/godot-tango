extends HBoxContainer


func _on_board_puzzle_completed(_timer: float) -> void:
	visible = false


func _on_board_puzzle_changed() -> void:
	visible = true
