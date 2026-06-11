extends Node


const TYPES := [Cell.Type.SUN, Cell.Type.MOON]
const ATTEMPT_TIMEOUT_MS := 1000
const CONSTRAINT_CHANCE := 0.1


func generate_puzzle(size: int) -> Puzzle:
    var puzzle := Puzzle.new(size)

    var start_ticks := Time.get_ticks_msec()
    for cell in puzzle.cells:
        cell.type = TYPES.pick_random()
        var problem_cells := puzzle.get_problem_cells()
        while problem_cells.size() > 0:
            problem_cells.pick_random().invert()
            problem_cells = puzzle.get_problem_cells()
            if start_ticks >= ATTEMPT_TIMEOUT_MS:
                # This is taking too long... try again
                return generate_puzzle(size)
    var end_ticks := Time.get_ticks_msec()
    print("Generation took "+str(end_ticks - start_ticks)+"ms")

    for cell in puzzle.cells:
        if cell.type == Cell.Type.EMPTY:
            continue
        for direction in Cell.Direction.values():
            if randf() > CONSTRAINT_CHANCE:
                continue
            cell.constrain_direction(direction)
            print("constrain")

    return puzzle
