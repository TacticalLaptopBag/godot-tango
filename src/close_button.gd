extends Button


@export var hide_control: Control


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	hide_control.visible = false
