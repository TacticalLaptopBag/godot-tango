extends Control


const DESELECTED_SLOT := Vector2i(-1, -1)

@export var ui_up: Control
@export var ui_left: Control
@export var ui_right: Control
@export var ui_down: Control

@export var unfocus_on_win: Array[Control] = []

@onready var board: Board = get_tree().get_first_node_in_group("board")

var selected_slot := DESELECTED_SLOT


func _ready() -> void:
	board.puzzle_completed.connect(_on_puzzle_completed)
	board.puzzle_changed.connect(_on_puzzle_changed)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)


var _held_actions: Dictionary = {}

func _input(event: InputEvent) -> void:
	if not has_focus():
		return

	for action in ["up", "down", "left", "right"]:
		if not event.is_action(action, true):
			continue

		var is_pressed = event.is_action_pressed(action, true)
		if is_pressed and not _held_actions.get(action, false):
			_held_actions[action] = true
			get_viewport().set_input_as_handled()
			match action:
				"up":    move(0, -1)
				"down":  move(0, 1)
				"left":  move(-1, 0)
				"right": move(1, 0)
		elif not is_pressed:
			_held_actions[action] = false

# func _input(event: InputEvent) -> void:
# 	if has_focus() and event.is_pressed():
# 		if event is InputEventJoypadMotion:
# 			pass
# 		if Input.is_action_just_pressed("up", true):
# 			move(0, -1)
# 			get_viewport().set_input_as_handled()
# 		if Input.is_action_just_pressed("down", true):
# 			print("down")
# 			move(0, 1)
# 			get_viewport().set_input_as_handled()
# 		if Input.is_action_just_pressed("left", true):
# 			move(-1, 0)
# 			get_viewport().set_input_as_handled()
# 		if Input.is_action_just_pressed("right", true):
# 			move(1, 0)
# 			get_viewport().set_input_as_handled()


func _unhandled_input(event: InputEvent) -> void:
	if has_focus() and event.is_pressed():
		var tile := board.get_tile(selected_slot)
		if tile == null:
			return
		if Input.is_action_just_pressed("toggle"):
			tile.toggle_tile_type()
			tile.tap_haptics.vibrate()
		elif Input.is_action_just_pressed("moon_toggle"):
			tile.toggle_moon_tile()
			tile.tap_haptics.vibrate()
		elif Input.is_action_just_pressed("clear"):
			tile.clear_tile()
			tile.tap_haptics.vibrate()


func _on_focus_entered():
	if selected_slot != DESELECTED_SLOT:
		board.get_tile(selected_slot).selected = false
	selected_slot = Vector2(0, 0)
	board.get_tile(selected_slot).selected = true


func _on_focus_exited():
	for tile in board.tiles:
		if tile.selected:
			tile.selected = false
			break
	selected_slot = DESELECTED_SLOT


func move(x: int, y: int):
	var old_slot = selected_slot
	if selected_slot == DESELECTED_SLOT:
		if x > 0 or y > 0:
			selected_slot = Vector2i(0, 0)
		elif x < 0:
			selected_slot = Vector2i(board.grid_size - 1, 0)
		elif y < 0:
			selected_slot = Vector2i(0, board.grid_size - 1)
	else:
		selected_slot += Vector2i(x, y)

	if selected_slot.x >= board.grid_size and ui_right != null:
		ui_right.grab_focus()
	elif selected_slot.x < 0 and ui_left != null:
		ui_left.grab_focus()
	elif selected_slot.y >= board.grid_size and ui_down != null:
		ui_down.grab_focus()
	elif selected_slot.y < 0 and ui_up != null:
		ui_up.grab_focus()
	else:
		# Source: https://medium.com/@lnandanapalli/efficient-array-wrapping-the-modulo-trick-every-developer-should-know-7ee614272100
		selected_slot = ((selected_slot % board.grid_size) + Vector2i(board.grid_size, board.grid_size)) % board.grid_size

	if old_slot != DESELECTED_SLOT:
		board.get_tile(old_slot).selected = false
	if selected_slot != DESELECTED_SLOT:
		board.get_tile(selected_slot).selected = true


func _on_puzzle_completed(_start_ticks: int, _end_ticks: int):
	for control in unfocus_on_win:
		control.focus_mode = Control.FOCUS_NONE


func _on_puzzle_changed():
	for control in unfocus_on_win:
		control.focus_mode = Control.FOCUS_ALL
	grab_focus()
