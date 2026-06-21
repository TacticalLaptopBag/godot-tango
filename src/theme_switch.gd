extends Button


@export var dark_theme_icon: Texture2D
@onready var light_theme_icon := icon

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	ThemeManager.theme_changed.connect(_on_theme_changed)
	_on_theme_changed(ThemeManager.current_theme)


func _on_pressed():
	ThemeManager.current_theme_idx = 0 if ThemeManager.current_theme_idx != 0 else 1


func _on_theme_changed(game_theme: GameTheme):
	icon = dark_theme_icon if game_theme.name.to_lower().contains("light") else light_theme_icon
