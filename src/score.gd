class_name Score
extends Resource

var time_ms: int;
var timestamp: int;


func _init(arg_time_ms: int, arg_timestamp: int) -> void:
	time_ms = arg_time_ms
	timestamp = arg_timestamp


func equals(other) -> bool:
	if other == null:
		return false
	if other is not Score:
		return false
	return other.time_ms == time_ms && other.timestamp == timestamp
