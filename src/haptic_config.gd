class_name HapticConfig
extends Resource

@export_flags("Gamepad:1", "Handheld:2") var haptic_devices := 0

@export_group("Handheld Config")
@export var duration_ms := 500
@export var amplitude := -1.0

@export_group("Gamepad Config")
@export var gamepad_duration_sec := 0.5
## Strength of the weak rumble motor
@export var weak_magnitude := 0.5
## Strength of the strong rumble motor
@export var strong_magnitude := 0.5


func vibrate():
	if not DataPersistence.vibrate:
		return

	if haptic_devices & 1:
		for joypad_id in Input.get_connected_joypads():
			Input.start_joy_vibration(joypad_id, weak_magnitude, strong_magnitude, gamepad_duration_sec)
		
	# https://docs.godotengine.org/en/latest/classes/class_input.html#class-input-method-vibrate-handheld
	if haptic_devices & 2:
		Input.vibrate_handheld(duration_ms, amplitude)
	
