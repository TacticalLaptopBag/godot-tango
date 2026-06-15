extends Button


@onready var board: Board = get_tree().get_first_node_in_group("board")


func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_pressed()


func _ready() -> void:
	board.cell_type_changed.connect(_on_cell_type_changed)
	pressed.connect(_on_pressed)
	_update_disabled()


func _update_disabled():
	disabled = board.changes.is_empty()


func _on_pressed() -> void:
	board.undo()


func _on_cell_type_changed(_cell: Cell, _old_type: Cell.Type):
	_update_disabled()
