import math, os, sequtils, strscans, strutils

type 
    Coordinate = tuple[x, y: int]
    Map = seq[seq[int]]

proc parseCoordinate(text: string): Coordinate =
    discard scanf(text, "$i, $i", result.x, result.y)

proc newMap(width, height: int): Map =
    result = newSeq[seq[int]](width)
    for i in 0..<width:
        result[i] = newSeq[int](height)

proc width(map: Map): int = map.len
proc height(map: Map): int = map[0].len

iterator coordinates(map: Map): Coordinate =
    for x in 0..<map.width:
        for y in 0..<map.height:
            yield (x, y)

proc manhattanDistance(a, b: Coordinate): int =
    abs(a.x - b.x) + abs(a.y - b.y)

proc findClosest(point: Coordinate, coords: openArray[Coordinate]): int =
    var minDistance = 65536
    for i, coord in coords:
        let distance = manhattanDistance(point, coord)
        if distance < minDistance:
            minDistance = distance
            result = i
        elif distance == minDistance:
            result = -1

proc fill(map: var Map, coords: openArray[Coordinate]): set[char] =
    for point in map.coordinates():
        let closest = findClosest(point, coords)
        map[point.x][point.y] = closest
        if(closest >= 0):
            result.incl(char(closest))

proc touchesEdge(area: int, map: Map): bool =
    for coord in map.coordinates:
        if map[coord.x][coord.y] == area:
            if coord.x == 0 or coord.y == 0 or 
                coord.x == map.width - 1 or 
                coord.y == map.height - 1:
                echo "$1 touches the edge at $2" % [$area, $coord]
                return true

proc survey(area: int, map: Map): int =
    for coord in map.coordinates:
        if map[coord.x][coord.y] == area:
            inc(result)

proc findBiggestArea(map: Map, areas: set[char]): int =
    for a in areas:
        let area = int(a)
        if not touchesEdge(area, map):
            let size = survey(area, map)
            echo "size of $1 is $2" % [$area, $size]
            if size > result:
                result = size

let file = commandLineParams()[0]
let coords = file.readFile().splitLines().map(parseCoordinate)
let w = coords.mapIt(it.x).max() + 1
let h = coords.mapIt(it.y).max() + 1
var map = newMap(w, h)
let areas = map.fill(coords)

let biggestArea = findBiggestArea(map, areas)

echo "$1x$2" % [$w, $h]
echo "map:"
for row in map:
    echo "   " & $row 

echo ""
echo "biggest area: " & $biggestArea

