class_name HapticConfig
extends Resource

@export_flags("Gamepad:1", "Handheld:2") var haptic_devices := 0
@export var duration_ms := 500

@export_group("Handheld Config")
@export var amplitude := -1.0

@export_group("Gamepad Config")
## Strength of the weak rumble motor
@export var weak_magnitude := 0.5
## Strength of the strong rumble motor
@export var strong_magnitude := 0.5


func vibrate():
	if haptic_devices & 1:
		print("buzz gamepad")
		Input.start_joy_vibration(0, weak_magnitude, strong_magnitude, duration_ms / 1000.0)
		
	# TODO: Need to add the VIBRATE permission to the export preset
	# https://docs.godotengine.org/en/latest/classes/class_input.html#class-input-method-vibrate-handheld
	if haptic_devices & 2:
		print("buzz handheld")
		Input.vibrate_handheld(duration_ms, amplitude)
	
