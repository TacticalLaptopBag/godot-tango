class_name ScoreboardRow
extends PanelContainer


@export var panel_default_style: StyleBox
@export var panel_accent_style: StyleBox

@export var _timestamp: Label
@export var _completion_time: Label

var _score: Score = null

func set_score(score: Score):
	_score = score
	if not is_node_ready():
		return

	_set_score(score)


func _set_score(score: Score):
	var formatted_timestamp := Time.get_datetime_string_from_unix_time(score.timestamp, true)
	var formatted_completion := Util.format_ms(score.time_ms)

	_timestamp.text = formatted_timestamp
	_completion_time.text = formatted_completion

	var style := panel_accent_style if score.equals(DataPersistence.latest_score) else panel_default_style
	# TODO: Theming...
	add_theme_stylebox_override("panel", style)


func _ready() -> void:
	if _score != null:
		_set_score(_score)
