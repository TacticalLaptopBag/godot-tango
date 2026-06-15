class_name Util
extends Object


static func get_item_from_2d(position: Vector2i, array: Array, row_size: int, column_size: int) -> Variant:
	if position.x < 0 or position.y < 0:
		return null
	if position.x >= column_size or position.y >= row_size:
		return null

	var row_start := column_size * position.y
	var item_idx := row_start + position.x
	if item_idx >= array.size():
		return null

	return array[item_idx]


static func format_ms(time_ms: int) -> String:
	var seconds := time_ms / 1000
	var minutes := seconds / 60
	var hours := minutes / 60
	
	var displayed_seconds := str(seconds % 60).lpad(2, "0")
	var displayed_minutes := str(minutes % 60)
	var displayed_hours := str(hours).lpad(2, "0")
	
	var formatted_time: String
	if hours > 0:
		formatted_time = "%s:%s:%s" % [displayed_hours, displayed_minutes.lpad(2, "0"), displayed_seconds]
	else:
		formatted_time = "%s:%s" % [displayed_minutes, displayed_seconds]
	return formatted_time
