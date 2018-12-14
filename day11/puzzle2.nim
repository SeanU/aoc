import strutils

const serNum = 1723

type Grid = array[1..300, array[1..300, int]]

func hundreds(x: int): int = parseInt($(("000" & $x)[^3]))

func getPower(x, y, size: int, grid: Grid): int =
    for xx in x..x+(size - 1):
        for yy in y..y+(size - 1):
            inc(result, grid[xx][yy])

var grid: Grid
for x in 1..300:
    for y in 1..300:
        let rackId = x + 10
        grid[x][y] = hundreds((rackId * y + serNum) * rackId) - 5

var maxX, maxY, maxSize, maxPower: int
maxPower = int.low()

for size in 1..300:
    echo "checking size: $1" % [$size]
    for x in 1..((300 - size)+1):
        for y in 1..((300 - size)+1):
            let power = getPower(x, y, size, grid)
            if power > maxPower:
                echo "New best: $1 @ ($2, $3, $4)" % [$power, $x, $y, $size]
                maxPower = power
                maxX = x
                maxY = y
                maxSize = size

echo "max power is at ($1, $2) size $3, level is $4" % [$maxX, $maxY, $maxSize, $maxPower]
