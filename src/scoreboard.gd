extends VBoxContainer


@export var panel_scene: PackedScene
@export var panel_default_style: StyleBox
@export var panel_accent_style: StyleBox


var latest_score: Score = null


func _on_board_puzzle_completed(start_ticks: int, end_ticks: int) -> void:
	# Create Score
	var score_time_ms := end_ticks - start_ticks
	var score_timestamp := roundi(Time.get_unix_time_from_system())
	latest_score = Score.new(score_time_ms, score_timestamp)

	# Store score into persistence
	DataPersistence.store_score(latest_score, DataPersistence.grid_size)
	DataPersistence.save()

	_update_scoreboard()


func _update_scoreboard():
	# Delete all child rows
	for child in get_children():
		child.queue_free()

	# Get top five scores
	var scores := DataPersistence.fetch_scores(DataPersistence.grid_size)

	# Instantiate up to 5 row scenes for each
	var score_count := 0
	for score in scores:
		if score_count >= 5:
			break
		_create_scoreboard_row(score)
		score_count += 1


func _create_scoreboard_row(score: Score):
	var new_row: ScoreboardRow = panel_scene.instantiate()
	add_child(new_row)
	new_row.set_score(score)
