extends Node


const DESELECTED_SLOT := Vector2i(-1, -1)

@onready var board: Board = $".."

var selected_slot := DESELECTED_SLOT


func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		if Input.is_action_just_pressed("up"):
			move(0, -1)
		if Input.is_action_just_pressed("down"):
			move(0, 1)
		if Input.is_action_just_pressed("left"):
			move(-1, 0)
		if Input.is_action_just_pressed("right"):
			move(1, 0)
	
		var tile := board.get_tile(selected_slot)
		if Input.is_action_just_pressed("toggle"):
			tile.toggle_tile_type()
		elif Input.is_action_just_pressed("moon_toggle"):
			tile.toggle_moon_tile()
		elif Input.is_action_just_pressed("clear"):
			tile.clear_tile()


func move(x: int, y: int):
	var old_slot = selected_slot
	if selected_slot == DESELECTED_SLOT:
		if x > 0 or y > 0:
			selected_slot = Vector2i(0, 0)
		elif x < 0:
			selected_slot = Vector2i(board.size - 1, 0)
		elif y < 0:
			selected_slot = Vector2i(0, board.size - 1)
	else:
		selected_slot += Vector2i(x, y)
	# Source: https://medium.com/@lnandanapalli/efficient-array-wrapping-the-modulo-trick-every-developer-should-know-7ee614272100
	selected_slot = ((selected_slot % board.size) + Vector2i(board.size, board.size)) % board.size
	
	if old_slot != DESELECTED_SLOT:
		board.get_tile(old_slot).selected = false
	board.get_tile(selected_slot).selected = true
