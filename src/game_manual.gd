extends PanelContainer


@export var hide_on_visible: Control


func _ready() -> void:
	visibility_changed.connect(_on_visibility_changed)
	visible = false


func _on_visibility_changed():
	hide_on_visible.visible = not visible
