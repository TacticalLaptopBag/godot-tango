class_name Puzzle
extends Resource


@export var cells: Array[Cell] = []
var _size: int = -1


enum LineType {
    COLUMN,
    ROW,
}


func _init(size: int = 6):
    _populate(size)


func get_cell(grid_position: Vector2i) -> Cell:
    return Util.get_item_from_2d(grid_position, cells, _size, _size)


func _populate(size: int):
    for y in range(size):
        for x in range(size):
            var cell := Cell.new(Vector2(x, y))
            cells.append(cell)
    _size = floor(sqrt(cells.size()))
    
    for cell in cells:
        cell.north = get_cell(cell.position - Vector2(0, 1))
        cell.south = get_cell(cell.position + Vector2(0, 1))
        cell.west = get_cell(cell.position - Vector2(1, 0))
        cell.east = get_cell(cell.position + Vector2(1, 0))


func grid_size() -> int:
    return _size


func is_filled() -> bool:
    for cell in cells:
        if cell.type == Cell.Type.EMPTY:
            return false
    return true


func _find_invalid_lines(line_type: LineType) -> Array[Cell]:
    var direction := Cell.Direction.SOUTH if line_type == LineType.COLUMN else Cell.Direction.EAST
    var start_mask := Vector2i(1, 0) if line_type == LineType.COLUMN else Vector2i(0, 1)
    
    var problem_cells: Array[Cell] = []
    for i in range(_size):
        var current_cell = get_cell(i * start_mask)
        var moon_count := 0
        var sun_count := 0
        var line_cells: Array[Cell] = []
        while current_cell != null and current_cell.type != Cell.Type.EMPTY:
            if current_cell.type == Cell.Type.SUN:
                sun_count += 1
            else:
                moon_count += 1
            line_cells.append(current_cell)
            current_cell = current_cell.get_neighbor(direction)
        
        if line_cells.size() == _size && moon_count != sun_count:
            problem_cells.append_array(line_cells)
    
    return problem_cells


func _find_illegal_constraints() -> Array[Cell]:
    var problem_cells: Array[Cell] = []
    for cell in cells:
        problem_cells.append_array(cell.has_illegal_neighbors())
    return problem_cells


func get_problem_cells() -> Array[Cell]:
    var problem_cells: Array[Cell] = []
    for cell in cells:
        cell.invalid = false
        problem_cells.append_array(cell.has_three_in_a_row())

    problem_cells.append_array(_find_invalid_lines(LineType.COLUMN))
    problem_cells.append_array(_find_invalid_lines(LineType.ROW))

    problem_cells.append_array(_find_illegal_constraints())
    return problem_cells


func validate() -> bool:
    var problem_cells := get_problem_cells()
    for problem_cell in problem_cells:
        problem_cell.invalid = true
    return problem_cells.is_empty()


func get_filled_cells() -> Array[Cell]:
    var filled_cells: Array[Cell] = []
    for cell in cells:
        if cell.type == Cell.Type.EMPTY:
            continue
        filled_cells.append(cell)
    return filled_cells
