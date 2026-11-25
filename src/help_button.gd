extends Button


@export var show_control: Control


func _ready() -> void:
	pressed.connect(_on_pressed)


func _on_pressed():
	show_control.visible = true
	visible = false
