extends Node


@export var _generators: Array[PuzzleGenerator] = []

var _generators_dict: Dictionary[int, PuzzleGenerator] = {}

signal puzzle_generated(available_sizes: Array[int])


func _ready():
	for generator in _generators:
		_generators_dict[generator.grid_size] = generator
		generator.queue_generation()
		generator.puzzle_generated.connect(_on_puzzle_generated)


func get_puzzle(size: int) -> Puzzle:
	if size not in _generators_dict:
		push_error("Attempt to get puzzle of invalid size: %d" % size)
		return null

	var generator := _generators_dict[size]
	return generator.get_puzzle()


func get_available_sizes() -> Array[int]:
	var available_sizes: Array[int] = []
	for generator in _generators:
		if generator.is_puzzle_ready():
			available_sizes.append(generator.grid_size)
	return available_sizes


func _on_puzzle_generated(_generator: PuzzleGenerator):
	puzzle_generated.emit(get_available_sizes())


func _exit_tree() -> void:
	for generator in _generators:
		generator.start_cleanup()

	for generator in _generators:
		generator.wait_for_cleanup_finish()
