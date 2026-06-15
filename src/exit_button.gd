extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if OS.has_feature("mobile"):
		queue_free()
		return
	pressed.connect(_on_pressed)


func _on_pressed():
	get_tree().quit()
