import os, lists, math, strutils

const capDiff: int = int('a') - int('A')

type
    Polymer = DoublyLinkedList[char]
    Monomer = DoublyLinkedNode[char]

proc newPolymer(input: string): Polymer = 
    result = initDoublyLinkedList[char]()
    for character in input:
        result.append(character)

proc canReact(x, y: char): bool =
    return abs(int(x) - int(y)) == capDiff

proc count(polymer: Polymer): int =
    for node in polymer.nodes:
        inc(result)

proc shrink(polymer: var Polymer): int =
    var shrank = true
    while shrank:
        shrank = false
        for node in polymer.nodes:
            if node.prev == nil:
                continue
    
            if canReact(node.prev.value, node.value):
                polymer.remove(node.prev)
                polymer.remove(node)
    polymer.count()

proc removeAll(polymer: var Polymer, unitType: char): void =
    let complement = chr(int(unitType) + capDiff)
    for node in polymer.nodes:
        if node.value == unitType or node.value == complement:
            polymer.remove(node)
        
let file = commandLineParams()[0]
let input = file.readFile()

var shortest: int = input.len()
for unitType in 'A'..'Z':
    var polymer = newPolymer(input)
    polymer.removeAll(unitType)
    let shrinkSize = polymer.shrink()
    echo "Removing $1 gets us to $2" % [$unitType, $shrinkSize]
    if shrinkSize < shortest:
        shortest = shrinkSize

echo "shortest length: " & $shortest