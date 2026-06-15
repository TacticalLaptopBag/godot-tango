extends Label

@onready var board: Board = $"../../../../../Board"


func start():
	set_process(true)


func stop():
	set_process(false)


func _process(_delta: float) -> void:
	var time_ms := Time.get_ticks_msec() - board.start_ticks
	text = Util.format_ms(time_ms)
