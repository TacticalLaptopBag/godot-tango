extends Button


@onready var on_btn: Button = $"../Vibrate Toggle On"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	visible = not DataPersistence.vibrate


func _on_pressed():
	DataPersistence.vibrate = true
	DataPersistence.save()
	visible = false
	on_btn.visible = true
