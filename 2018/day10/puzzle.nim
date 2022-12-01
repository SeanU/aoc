import algorithm, options, os, sequtils, strscans, strutils

type
    Vector = tuple[x, y: int]
    Point = tuple[position, velocity: Vector]
    Constellation = seq[Point]

func `+`(a, b: Vector): Vector =
    result.x = a.x + b.x
    result.y = a.y + b.y

func parseLine(line: string): Option[Point] =
    const format = "position=<$s$i,$s$i> velocity=<$s$i,$s$i>"
    var point: Point
    if not line.isNilOrWhitespace():
        if scanf(
                line, format, 
                point.position.x, point.position.y, 
                point.velocity.x, point.velocity.y
                ):
            return some(point)
    return none(Point)

proc getBounds(input: Constellation, topLeft, bottomRight: var Vector): void =
    topLeft.x = int.high()
    topLeft.y = int.high()
    bottomRight.x = int.low()
    bottomRight.y = int.low()
    for point in input:
        let pos = point.position
        topLeft.x = min(topLeft.x, pos.x)
        topLeft.y = min(topLeft.y, pos.y)
        bottomRight.x = max(bottomRight.x, pos.x)
        bottomRight.y = max(bottomRight.y, pos.y)

proc draw(input: Constellation): void =
    var topLeft, bottomRight: Vector
    getBounds(input, topLeft, bottomRight)
    let width = (bottomRight.x - topLeft.x) + 1
    let height = (bottomRight.y - topLeft.y) + 1
    var view = newSeq[string](height)
    view.fill(repeat(' ', width))

    for point in input:
        let x = point.position.x - topLeft.x
        let y = point.position.y - topLeft.y
        view[y][x] = '#'

    for line in view:
        echo "\t" & line

func evolve(point: Point): Point =
    (point.position + point.velocity, point.velocity)

func evolve(input: Constellation): Constellation =
    input.mapIt(it.evolve)

func getArea(input: Constellation): int =
    var topLeft, bottomRight: Vector
    getBounds(input, topLeft, bottomRight)
    let width = (bottomRight.x - topLeft.x) + 1
    let height = (bottomRight.y - topLeft.y) + 1
    width * height

let inputFile = commandLineParams()[0]
var stars = inputFile
    .readFile()
    .splitLines()
    .map(parseLine)
    .filterIt(it.isSome)
    .mapIt(it.get())

var area, lastArea = int.high()
var lastStars: Constellation

var step = 0
while area <= lastArea:
    lastStars = stars
    lastArea = area
    stars = evolve(stars)
    area = stars.getArea()
    inc(step)

echo "Step $1:" % [$(step - 1)]
draw(lastStars)