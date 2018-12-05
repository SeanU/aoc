import os, lists, math, strutils

const capDiff: int = int('a') - int('A')

type
    Polymer = DoublyLinkedList[char]
    Monomer = DoublyLinkedNode[char]

proc canReact(x, y: char): bool =
    return abs(int(x) - int(y)) == capDiff

proc findReaction(polymer: Polymer, n1, n2: var Monomer): bool =
    for node in polymer.nodes:
        if node.next == nil:
            return false
    
        if canReact(node.value, node.next.value):
            n1 = node
            n2 = node.next
            return true

    return false

proc count(polymer: Polymer): int =
    for node in polymer.nodes:
        inc(result)

proc newPolymer(input: string): Polymer =
    var polymer: Polymer = initDoublyLinkedList[char]()
    for character in input:
        polymer.append(character)
    polymer

proc shrink(polymer: var Polymer): int =
    var n1, n2: Monomer
    while findReaction(polymer, n1, n2):
        polymer.remove(n1)
        polymer.remove(n2)
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