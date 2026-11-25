extends PanelContainer


@export var time_label: Label

@onready var time_label_fmt := time_label.text


func _ready():
	visible = false


func _on_board_puzzle_completed(timer: float) -> void:
	visible = true
	
	var formatted_time := Util.format_sec(timer)
	time_label.text = time_label_fmt % formatted_time


func _on_board_puzzle_changed() -> void:
	visible = false
