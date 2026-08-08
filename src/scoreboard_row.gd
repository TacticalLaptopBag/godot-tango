class_name ScoreboardRow
extends PanelContainer


@export var _timestamp: Label
@export var _completion_time: Label

var _score: Score = null

func set_score(score: Score):
	_score = score
	if not is_node_ready():
		return

	_set_score(score)


func _set_score(score: Score):
	var local_time_zone := Time.get_time_zone_from_system()
	var local_timestamp = score.timestamp + (local_time_zone["bias"] * 60)
	var formatted_timestamp := Time.get_datetime_string_from_unix_time(local_timestamp, true)
	var formatted_completion := Util.format_ms(score.time_ms)

	_timestamp.text = formatted_timestamp
	_completion_time.text = formatted_completion

	var game_theme = ThemeManager.current_theme
	var style: StyleBox = game_theme.panel_accent_style if score.equals(DataPersistence.latest_score) else game_theme.panel_raised_style
	add_theme_stylebox_override("panel", style)


func _ready() -> void:
	if _score != null:
		_set_score(_score)
	
	ThemeManager.theme_changed.connect(_on_theme_changed)


func _on_theme_changed(_theme: GameTheme):
	if _score != null:
		_set_score(_score)
