extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ThemeManager.theme_changed.connect(_update_theme)
	_update_theme(ThemeManager.current_theme)


func _update_theme(game_theme: GameTheme):
	self.theme = game_theme.ui_theme
