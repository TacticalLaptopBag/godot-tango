# Tango.gd

The classic LinkedIn puzzle, [Tango][tango], reimplemented in Godot.
Select from 4x4, 6x6, or 8x8 grids.
Puzzles are randomly generated, and are validated with a rule-based solver.

No internet connection required.

Don't want to download? Play in your web browser on [itch.io][itch]


## How to play

 * Fill the grid so that each cell contains either a Sun or a Moon
 * No more than 2 Suns or Moons may be next to each other, either vertically or horizontally
 * Each row and column must contain the same number of Suns and Moons
 * Cells separated by an = must be of the same type
 * Cells separated by a X must be of opposite type
 * Each puzzle has one right answer and can be solved via deduction. You should never have to make a guess.


## Controls

### Mouse

 * Left click: Toggle Sun -> Moon -> Blank
 * Right click: Toggle Moon -> Blank
 * Middle click: Clear tile


### Keyboard

 * WASD / Arrow keys: Select tile
 * Space / E: Toggle Sun -> Moon -> Blank
 * Shift / Q: Toggle Moon -> Blank
 * CTRL / F: Clear tile
 * Z: Undo
 * Escape: New Game


### Gamepad

All face buttons assume XBox-style layout

 * Left stick / D-Pad: Select tile
 * (A): Toggle Sun -> Moon -> Blank
 * (X): Toggle Moon -> Blank
 * (Y): Clear tile
 * (B): Undo
 * Menu: New Game


## AI Usage Disclaimer

Claude was used to program the puzzle solver used to generate puzzles.


[tango]: https://www.linkedin.com/games/tango/
[itch]: https://tacticallaptopbag.itch.io/tango
