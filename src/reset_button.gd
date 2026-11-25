extends Button


@onready var board: Board = get_tree().get_first_node_in_group("board")

func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	board.clear()
