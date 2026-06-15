extends Control

@onready var board: Board = get_tree().get_first_node_in_group("board")


func _ready():
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()


func _on_viewport_size_changed():
	size = board.bounding_box + board.grid_padding * 2
	position = get_viewport().get_visible_rect().size / 2 - size / 2
