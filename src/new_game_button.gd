extends Button


@export var hide_on_pressed: Array[Control] = []


func _ready() -> void:
	pressed.connect(_on_pressed)


func _unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("new_game"):
		_on_pressed()


func _on_pressed() -> void:
	var board: Board = get_tree().get_first_node_in_group("board")
	var puzzle: Puzzle = PuzzleProvider.get_puzzle(board.grid_size)
	board.puzzle = puzzle
	for node in hide_on_pressed:
		node.visible = false
