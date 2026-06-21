extends Button


@export var vibrate_off_icon: Texture2D
@onready var vibrate_on_icon := icon


func _ready() -> void:
	pressed.connect(_on_pressed)
	_update_icon()


func _on_pressed():
	DataPersistence.vibrate = not DataPersistence.vibrate
	_update_icon()


func _update_icon():
	icon = vibrate_on_icon if DataPersistence.vibrate else vibrate_off_icon
