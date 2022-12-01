import math, os, sequtils, strscans, strutils

type 
    Coordinate = tuple[x, y: int]

proc parseCoordinate(text: string): Coordinate =
    discard scanf(text, "$i, $i", result.x, result.y)

let file = commandLineParams()[0]
let limit = parseInt(commandLineParams()[1])
let coords = file.readFile().splitLines().map(parseCoordinate)

let xs = coords.mapIt(it.x)
let ys = coords.mapIt(it.y)

var safePlaces = 0
for x in 0..xs.max():
    let sumX = xs.mapIt(abs(it - x)).sum()
    for y in 0..ys.max():
        let sumY = ys.mapIt(abs(it - y)).sum()
        if (sumX + sumY) < limit:
            inc(safePlaces)

echo "safe area: " & $safePlaces

