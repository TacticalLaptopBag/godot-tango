extends Label

@onready var board: Board = get_tree().get_first_node_in_group("board")


func start():
	set_process(true)


func stop():
	set_process(false)


func _process(_delta: float) -> void:
	if board.puzzle != null and board.puzzle.timer >= 0:
		text = Util.format_sec(board.puzzle.timer)
