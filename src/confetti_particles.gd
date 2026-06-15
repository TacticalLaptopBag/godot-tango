extends Node2D


var emitters: Array[CPUParticles2D] = []


func _ready() -> void:
	for child in get_children():
		if child is CPUParticles2D:
			emitters.append(child)


func _on_puzzle_completed(_start_ticks: int, _end_ticks: int):
	emit()


func emit():
	for emitter in emitters:
		emitter.emitting = true


func stop():
	# We could make the particles invisible, but it feels wrong
	for emitter in emitters:
		emitter.emitting = false
