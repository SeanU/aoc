import strutils

const serNum = 1723

type Grid = array[1..300, array[1..300, int]]

func hundreds(x: int): int = parseInt($(("000" & $x)[^3]))

func getPower(x, y: int, grid: Grid): int =
    for xx in x..x+2:
        for yy in y..y+2:
            inc(result, grid[xx][yy])

var grid: Grid
for x in 1..300:
    for y in 1..300:
        let rackId = x + 10
        grid[x][y] = hundreds((rackId * y + serNum) * rackId) - 5

var maxX, maxY, maxSize, maxPower: int
maxPower = int.low()

for x in 1..298:
    for y in 1..298:
        let power = getPower(x, y, grid)
        if power > maxPower:
            maxPower = power
            maxX = x
            maxY = y

echo "max power is at ($1, $2), level is $3" % [$maxX, $maxY, $maxPower]
