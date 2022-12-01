import os, strutils, sequtils, algorithm, terminal

type
    Map = seq[string]
    Vector = tuple[x, y: int]
    Cart = tuple[position: Vector, heading: char, turns: int]

proc parse(file: string): (Map, seq[Cart]) =
    var map = file.readFile().splitLines().filterIt(not it.isNilOrWhitespace())
    var carts = newSeq[Cart]()

    for y in 0..high(map):
        let line = map[y]
        for x in 0..high(line):
            case line[x]
                of '<':
                    carts.add((position: (x, y), heading: '<', turns: 0))
                    map[y][x] = '-'
                of '^':
                    carts.add((position: (x, y), heading: '^', turns: 0))
                    map[y][x] = '|'
                of '>':
                    carts.add((position: (x, y), heading: '>', turns: 0))
                    map[y][x] = '-'
                of 'v':
                    carts.add((position: (x, y), heading: 'v', turns: 0))
                    map[y][x] = '|'
                else:
                    discard
    (map, carts)

func forRank(carts: seq[Cart], rank: int): seq[Cart] =
    carts.filterIt(it.position.y == rank)

func addCarts(line: string, carts: seq[Cart]): string =
    result = line
    for cart in carts:
        result[cart.position.x] = cart.heading

proc draw(map: Map, carts: seq[Cart]): void =
    for y in 0..high(map):
        echo "\t" & addCarts(map[y], carts.forRank(y))

func toVector(heading: char): Vector =
    case heading:
        of '<': (-1,0)
        of '^': (0,-1)
        of '>': (1,0)
        of 'v': (0,1)
        else: (0,0)

func `+`(a, b: Vector): Vector =
    (a.x + b.x, a.y + b.y)

func turnLeft(heading: char): char =
    case heading:
        of '<': 'v'
        of '^': '<'
        of '>': '^'
        of 'v': '>'
        else: heading

func turnRight(heading: char): char =
    case heading:
        of '<': '^'
        of '^': '>'
        of '>': 'v'
        of 'v': '<'
        else: heading
    
func turn(map: Map, cart: var Cart): void =
    let track = map[cart.position.y][cart.position.x]
    cart.heading = 
        case track
            of '/':
                case cart.heading:
                    of '<': 'v'
                    of '^': '>'
                    of '>': '^'
                    of 'v': '<'
                    else: cart.heading
            of '\\':
                case cart.heading:
                    of '<': '^'
                    of '^': '<'
                    of '>': 'v'
                    of 'v': '>'
                    else: cart.heading
            of '+':
                case (cart.turns mod 3)
                    of 0: turnLeft(cart.heading)
                    of 2: turnRight(cart.heading)
                    else: cart.heading
            else:
                cart.heading
    if track == '+': inc(cart.turns)

proc move(map: Map, cart: var Cart): void =
    cart.position = cart.position + cart.heading.toVector()
    turn(map, cart)

proc detectCrash(carts: seq[Cart], crash: var Vector): bool =
    for i in 1..high(carts):
        let a = carts[i-1]
        let b = carts[i]
        if a.position == b.position:
            crash = a.position
            return true
    
proc move(map: Map, carts: var seq[Cart], crash: var Vector): bool =
    for i in 0..high(carts):
        move(map, carts[i])
        if detectCrash(carts, crash):
            return true

proc `$`(x: Vector): string =
    "($1, $2)" % [$x.x, $x.y]

proc waitForStep(step: var int): void =
    if getch() == 'q':
        echo "quitting"
        quit(0)
    inc(step)

proc runUntilCrash(map: Map, startCarts: seq[Cart]): Vector =
    var carts = startCarts
    var crash: Vector
    echo "start:"
    draw(map, carts)
    
    var step = 1
    while true:
        if move(map, carts, crash):
            return crash
        carts.sort(proc (a, b: Cart): int =
            result = cmp(a.position.y, b.position.y)
            if result == 0:
                result = cmp(a.position.x, b.position.x))

        draw(map, carts)
        echo "(step $1)" % [$step]
        waitForStep(step)
    
let infile = commandLineParams()[0]
let (map, carts) = parse(infile)
let crash = runUntilCrash(map, carts)
echo "crash: $1" % [$crash]


