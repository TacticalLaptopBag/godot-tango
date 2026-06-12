extends Button


func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("new_game"):
		_on_pressed()


func _on_pressed() -> void:
	var board: Board = get_tree().get_first_node_in_group("board")
	var puzzle: Puzzle = PuzzleProvider.generate_puzzle(board.size)
	board.puzzle = puzzle
