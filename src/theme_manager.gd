extends Node


@export var themes: Array[GameTheme] = []

var current_theme: GameTheme:
	get:
		if current_theme_idx < 0 or current_theme_idx >= themes.size():
			return null
		return themes[current_theme_idx]

var current_theme_idx := -1:
	set(value):
		if current_theme_idx != value and value >= 0 and value < themes.size():
			current_theme_idx = value
			RenderingServer.set_default_clear_color(current_theme.default_clear_color)
			DataPersistence.current_theme = current_theme.name
			DataPersistence.save()
			theme_changed.emit(themes[value])

signal theme_changed(game_theme: GameTheme)


func _ready() -> void:
	var new_theme_idx := 0
	var saved_theme := DataPersistence.current_theme
	for i in range(len(themes)):
		if themes[i].name == saved_theme:
			new_theme_idx = i
			break
	current_theme_idx = new_theme_idx
