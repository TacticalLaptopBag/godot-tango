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
