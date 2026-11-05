# RobotScript

A small domain-specific language for commanding a virtual robot, implemented
with Flex (lexer) and Bison (parser). The compiler validates the program and
simulates the robot's final position and heading.

## Language

| Command               | Meaning                          |
|-----------------------|----------------------------------|
| `robot`               | Declares the robot               |
| `move forward N`      | Move N units in current heading  |
| `move backward N`     | Move N units opposite to heading |
| `turn right N`        | Rotate clockwise by N degrees    |
| `turn left N`         | Rotate counter-clockwise by N    |
| `stop`                | Stop and print the final state   |

- Start: position (0, 0), facing NORTH
- Ground: X in [-100, 100], Y in [0, 100]; hitting a border turns the robot around
- Headings: NORTH (0), EAST (90), SOUTH (180), WEST (270)

## Example

    robot
    move forward 10
    turn right 90
    move forward 20
    stop

## Build & Run

    make
    ./robotscript < examples/sample.txt

Or just `make run`. Clean with `make clean`.

## Requirements
- flex
- bison
- gcc
- make

## Docs
Full project report: `docs/RobotScript_Project_Report.docx`


## Authors
- Mhamuda Shafiq Shamme
- Fariha Nowshin Barisha
