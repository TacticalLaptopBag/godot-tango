extends Node2D


var emitters: Array[CPUParticles2D] = []


func _ready() -> void:
	for child in get_children():
		if child is CPUParticles2D:
			emitters.append(child)


func emit():
	for emitter in emitters:
		emitter.emitting = true
