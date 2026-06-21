extends Node


@onready var parent: Control = get_parent()


func _ready() -> void:
	parent.visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed():
	if parent.is_visible_in_tree():
		parent.grab_focus()
