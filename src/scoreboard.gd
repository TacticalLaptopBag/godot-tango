extends VBoxContainer


@export var panel_scene: PackedScene
@export var panel_default_style: StyleBox
@export var panel_accent_style: StyleBox


func _on_board_puzzle_completed(start_ticks: int, end_ticks: int) -> void:
	var time_ms := end_ticks - start_ticks
	var formatted_time := Util.format_ms(time_ms)

	# Format current time as YYYY-MM-DD HH:MM:SS
	# Store score into persistence

	_update_scoreboard()


func _update_scoreboard():
	pass
	# Delete all child rows
	# Get top five scores
	# Instantiate row scene for each
	# Check if latest score is on the board. If so, accent it
