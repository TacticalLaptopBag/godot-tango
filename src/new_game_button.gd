extends Button


func _on_pressed() -> void:
	var board: Board = get_tree().get_first_node_in_group("board")
	var puzzle: Puzzle = PuzzleProvider.generate_puzzle(board.size)
	board.puzzle = puzzle
