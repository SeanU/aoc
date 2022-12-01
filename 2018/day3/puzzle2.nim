import os
import strutils
import parseutils

type 
    Fabric = tuple[ size: int, slots: seq[seq[int]] ]
    Claim = tuple[id: int, x: int, y: int, width: int, height: int]

proc makeSlots(size: int): seq[seq[int]] =
    newSeq(result, size)
    for i in 0..<size:
        result[i] = newSeq[int](size)

proc newFabric(size: int): Fabric = (size: size, slots: makeSlots(size))

proc grow(fabric: var Fabric): void =
    let oldSize = fabric.size
    fabric.size = oldSize * 2
    echo "Growing fabric from $1 to $2" % [$oldSize, $fabric.size]
    setlen(fabric.slots, fabric.size)

    for i in 0..<oldSize:
        setlen(fabric.slots[i], fabric.size)
    
    for i in oldSize..<fabric.size:
        fabric.slots[i] = newSeq[int](fabric.size)

proc parseClaim(line: string): Claim =
    var id, cursor: int
    var x, y, width, height: Natural

    cursor = cursor + skipWhile(line, {'#'}, cursor)
    cursor = cursor + parseInt(line, id, cursor)
    cursor = cursor + skipWhile(line, {' ', '@'} , cursor)
    cursor = cursor + parseInt(line, x, cursor)
    cursor = cursor + skipWhile(line, {','}, cursor)
    cursor = cursor + parseInt(line, y, cursor)
    cursor = cursor + skipWhile(line, {':', ' '}, cursor)
    cursor = cursor + parseInt(line, width, cursor)
    cursor = cursor + skipWhile(line, {'x'}, cursor)
    cursor = cursor + parseInt(line, height, cursor)

    (id, x, y, width, height)

proc size(claim: Claim): int =
    max(claim.x + claim.width, claim.y + claim.height)

proc makeFit(fabric: var Fabric, claim: Claim): void =
    while(claim.size >= fabric.size):
        fabric.grow()

proc layClaim(claim: Claim, fabric: var Fabric): bool =
    result = true
    for x in claim.x..<(claim.x + claim.width):
        for y in claim.y..<(claim.y + claim.height):
            inc(fabric.slots[x][y])
            if fabric.slots[x][y] > 1:
                result = false

proc noOverlaps(claim: Claim, fabric: Fabric): bool =
    for x in claim.x..<(claim.x + claim.width):
        for y in claim.y..<(claim.y + claim.height):
            if fabric.slots[x][y] > 1:
                return false
    true

proc findUniqueClaim(candidates: seq[Claim], fabric: Fabric): int =
    echo "Examining $1 possible unique claims" % [$candidates.len]
    for claim in candidates:
        if claim.noOverlaps(fabric):
            return claim.id
        
proc findUniqueClaim(file: string): int =
    var fabric = newFabric(1024)
    var possibleUniques: seq[Claim]

    for line in file.lines:
        let claim = parseClaim(line)
        makeFit(fabric, claim)
        if claim.layClaim(fabric):
            possibleUniques.add(claim)

    findUniqueClaim(possibleUniques, fabric)

let input = commandLineParams()[0]
echo "unique claim: $1" % [$findUniqueClaim(input)]