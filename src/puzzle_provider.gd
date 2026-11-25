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

	# Return in-progress puzzle if it exists
	var in_progress := DataPersistence.load_in_progress_puzzle(size)
	if in_progress != null:
		return in_progress

	var generator := _generators_dict[size]
	var puzzle := generator.get_puzzle()
	if puzzle != null:
		# Establish ownership by saving as in-progress
		DataPersistence.save_in_progress_puzzle(puzzle)
	return puzzle


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
		generator.wait_for_cleanup_finish()
