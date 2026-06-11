class_name Cell
extends Resource


var type := Type.EMPTY:
    set(value):
        if type != value:
            type = value
            type_changed.emit(self)
var position := Vector2.ZERO

var locked := false:
    set(value):
        if locked != value:
            locked = value
            locked_changed.emit(self)
var invalid := false:
    set(value):
        if invalid != value:
            invalid = value
            invalid_changed.emit(self)

var north: Cell = null
var south: Cell = null
var east: Cell = null
var west: Cell = null


signal type_changed(cell: Cell)
signal invalid_changed(cell: Cell)
signal locked_changed(cell: Cell)


func _init(grid_position: Vector2):
    position = grid_position


enum Type {
    EMPTY,
    SUN,
    MOON,
}

enum Direction {
    NORTH,
    EAST,
    SOUTH,
    WEST,
}


func invert():
    if type == Type.EMPTY:
        return null
    type = Type.SUN if type == Type.MOON else Type.MOON


func get_neighbor(direction: Direction) -> Cell:
    match direction:
        Direction.NORTH:
            return north
        Direction.EAST:
            return east
        Direction.SOUTH:
            return south
        Direction.WEST:
            return west
    return null


func has_three_in_a_row() -> Array[Cell]:
    if type == Type.EMPTY:
        return []
    
    var problem_cells: Array[Cell] = []
    # Check vertical
    if north != null and south != null:
        if north.type == south.type && north.type == type:
            problem_cells.append_array([north, self, south])
    
    # Check horizontal
    if east != null and west != null:
        if east.type == west.type && east.type == type:
            problem_cells.append_array([east, self, west])
    
    return problem_cells
