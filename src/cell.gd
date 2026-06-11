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


var north_constraint := Constraint.NONE:
    set(value):
        north_constraint = value
        constraint_changed.emit(self, Direction.NORTH)
var south_constraint := Constraint.NONE:
    set(value):
        south_constraint = value
        constraint_changed.emit(self, Direction.SOUTH)
var east_constraint := Constraint.NONE:
    set(value):
        east_constraint = value
        constraint_changed.emit(self, Direction.EAST)
var west_constraint := Constraint.NONE:
    set(value):
        west_constraint = value
        constraint_changed.emit(self, Direction.WEST)


signal type_changed(cell: Cell)
signal invalid_changed(cell: Cell)
signal locked_changed(cell: Cell)
signal constraint_changed(cell: Cell, direction: Direction)


func _init(grid_position: Vector2):
    position = grid_position


enum Type {
    EMPTY,
    SUN,
    MOON,
}


enum Constraint {
    NONE,
    EQUAL,
    OPPOSITE,
}


enum Direction {
    NORTH,
    EAST,
    SOUTH,
    WEST,
}


static func invert_direction(direction: Direction) -> Direction:
    match direction:
        Direction.NORTH:
            return Direction.SOUTH
        Direction.EAST:
            return Direction.WEST
        Direction.SOUTH:
            return Direction.NORTH
        Direction.WEST:
            return Direction.EAST
    return direction


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


func get_constraint(direction: Direction) -> Constraint:
    match direction:
        Direction.NORTH:
            return north_constraint
        Direction.EAST:
            return east_constraint
        Direction.SOUTH:
            return south_constraint
        Direction.WEST:
            return west_constraint
    return Constraint.NONE


func set_constraint(direction: Direction, value: Constraint):
    match direction:
        Direction.NORTH:
            north_constraint = value
        Direction.EAST:
            east_constraint = value
        Direction.SOUTH:
            south_constraint = value
        Direction.WEST:
            west_constraint = value


func create_constraint(neighbor: Cell) -> Constraint:
    if neighbor == null or neighbor.type == Type.EMPTY or type == Type.EMPTY:
        return Constraint.NONE
    return Constraint.EQUAL if neighbor.type == type else Constraint.OPPOSITE


func constrain_direction(direction: Direction):
    match direction:
        Direction.NORTH:
            north_constraint = create_constraint(north)
        Direction.EAST:
            east_constraint = create_constraint(east)
        Direction.SOUTH:
            south_constraint = create_constraint(south)
        Direction.WEST:
            west_constraint = create_constraint(west)

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


func _is_neighbor_illegal(neighbor: Cell, constraint: Constraint) -> bool:
    if neighbor == null or neighbor.type == Type.EMPTY or constraint == Constraint.NONE:
        return false
    if constraint == Constraint.EQUAL and type != neighbor.type:
        return true
    if constraint == Constraint.OPPOSITE and type == neighbor.type:
        return true
    return false


func has_illegal_neighbors() -> Array[Cell]:
    if type == Type.EMPTY:
        return []

    var illegal_neighbors: Array[Cell] = []

    if _is_neighbor_illegal(north, north_constraint):
        illegal_neighbors.append(north)
    if _is_neighbor_illegal(south, south_constraint):
        illegal_neighbors.append(south)
    if _is_neighbor_illegal(east, east_constraint):
        illegal_neighbors.append(east)
    if _is_neighbor_illegal(west, west_constraint):
        illegal_neighbors.append(west)

    if not illegal_neighbors.is_empty():
        illegal_neighbors.append(self)
    return illegal_neighbors
