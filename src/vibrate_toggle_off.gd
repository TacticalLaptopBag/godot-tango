extends Button


@onready var on_btn: Button = $"../Vibrate Toggle On"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pressed.connect(_on_pressed)
	visible = DataPersistence.data.get_or_add("vibrate", true) == false


func _on_pressed():
	DataPersistence.data["vibrate"] = true
	DataPersistence.save()
	visible = false
	on_btn.visible = true
