extends Button


@onready var off_btn: Button = $"../Vibrate Toggle Off"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	visible = DataPersistence.vibrate


func _on_pressed():
	DataPersistence.vibrate = false
	DataPersistence.save()
	visible = false
	off_btn.visible = true
