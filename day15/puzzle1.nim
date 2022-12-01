import os, strutils, sequtils, terminal, algorithm, math

type 
    Map = seq[string]
    DistanceMap = seq[seq[int]]
    Vector = tuple[x, y: int]
    Species = enum elf, goblin
    Unit = tuple[species: Species, position: Vector, attackPower, hitPoints: int, alive: bool]
    Units = seq[Unit]

proc readMap(file: string): Map =
    for line in file.lines:
        var row = line
        for i, c in row:
            if c != '#':
                row[i] = ' '
        result.add(row)

func newUnit(species: Species, x, y: int): Unit =
    (species, (x, y), 3, 200, true)
    
proc readUnits(file: string): Units =
    for y, line in file.readFile().splitLines().pairs():
        for x, c in line:
            if c == 'E':
                result.add(newUnit(elf, x, y))
            elif c == 'G':
                result.add(newUnit(goblin, x, y))

var steps = 0
proc notDone(units: Units): bool =
    inc(steps)
    return steps < 2

proc sort(units: var Units): void =
    units.sort do (a, b: Unit) -> int:
        result = cmp(a.position.y, b.position.y)
        if result == 0:
            result = cmp(a.position.x, b.position.x)

func manhattanDistance(a, b: Vector): int =
    abs(a.x - b.x) + abs(a.y - b.y)

func adjacentTo(units: Units, target: Unit): Units =
    units.filterIt(manhattanDistance(target.position, it.position) == 1)

func withUnitsAsWalls(map: Map, units: Units): Map =
    result = map
    for unit in units:
        result[unit.position.y][unit.position.x] = '#'

func dimensions(map: Map): Vector =
    (map[0].len, map.len)

func newDistanceMap(dim: Vector): DistanceMap =
    repeat(repeat(high(int), dim.x), dim.y)

iterator adjacentSpaces(spot: Vector): Vector =
    yield (spot.x, spot.y - 1)
    yield (spot.x + 1, spot.y)
    yield (spot.x, spot.y + 1)
    yield (spot.x - 1, spot.y)

func isPassable(map: Map, space: Vector): bool =
    let dim = map.dimensions
    space.x >= 0 and 
        space.y >= 0 and 
        space.x < dim.x and 
        space.y < dim.y and 
        map[space.y][space.x] != '#'

proc `[]=`(dmap: var DistanceMap, space: Vector, value: int) =
    dmap[space.y][space.x] = value

iterator passableSpaces(map: Map): Vector =
    discard

func makeDistanceMap(enemies: Units, map: Map): DistanceMap =
    result = newDistanceMap(map.dimensions)
    for enemy in enemies:
        for space in adjacentSpaces(enemy.position):
            if map.isPassable(space):
                result[space] = 0
    var updated = true
    while(updated):
        updated = false
        for space in map.passableSpaces:
            for adj in adjacentSpaces(space):
                if map.isPassable(adj):
                    

    

proc followBestPath(unit: Unit, dmap: DistanceMap): void =
    discard

proc draw(map: Map, title: string): void =
    echo title & ":"
    for row in map:
        echo "\t" & row

proc draw(dmap: DistanceMap): void =
    echo "distances:"
    for row in dmap:
        echo "\t" & $row

proc moveToEnemy(unit: Unit, allUnits, enemies: Units, map: Map): void =
    let obstructionMap = map.withUnitsAsWalls(allUnits)
    draw(obstructionMap, "obstructions")
    let dmap = makeDistanceMap(enemies, obstructionMap)
    draw(dmap)
    unit.followBestPath(dmap)

proc attack(unit: Unit, enemies: Units): void =
    discard

proc takeMove(units: var Units, i: int, map: Map): void =
    var unit = units[i]
    let allEnemies = units.filterIt(it.species != unit.species)
    var adjacentEnemies = allEnemies.adjacentTo(unit)
    if len(adjacentEnemies) == 0:
        echo "unit $1 has no adjancent enemies" % [$i]
        unit.moveToEnemy(units, allEnemies, map)
        adjacentEnemies = allEnemies.adjacentTo(unit)
    unit.attack(adjacentEnemies)

proc runBattle(map: Map, units: var Units): void =
    units.sort()
    for i in 0..<len(units):
        units.takeMove(i, map)

func toChar(unit: Unit): char =
    case unit.species
        of elf: 'E'
        of goblin: 'G'

func addUnits(row: string, units: Units): string =
    result = row
    for unit in units:
        result[unit.position.x] = unit.toChar()

func unitSummary(units: Units): string =
    join(
        units.mapIt("$1($2)" % [$it.toChar, $it.hitPoints]),
        ", "
    )

proc drawBattle(map: Map, units: Units, round: int): void =
    for y, row in map.pairs():
        let rowUnits = units.filterIt(it.position.y == y)
        let populatedRow = row.addUnits(rowUnits)
        let summary = unitSummary(rowUnits)
        echo "\t$1 $2" % [populatedRow, summary]
    echo "(round $1)" % [$round]

let inputFile = commandLineParams()[0]
let map = readMap(inputFile)
var units = readUnits(inputFile)

var round = 0
drawBattle(map, units, round)
while notDone(units):
    inc(round)
    runBattle(map, units)
    drawBattle(map, units, round)
    if getch() == 'q':
        echo "Quitting"
        quit(0)
