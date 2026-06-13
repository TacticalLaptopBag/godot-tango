class_name Change
extends Resource


var cell: Cell
var old_type: Cell.Type
var new_type: Cell.Type


func _init(cell: Cell, old_type: Cell.Type, new_type: Cell.Type):
	self.cell = cell
	self.old_type = old_type
	self.new_type = new_type
