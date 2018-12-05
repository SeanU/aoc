import os, lists, math, strutils

const capDiff: int = int('a') - int('A')

type
    Polymer = DoublyLinkedList[char]
    Monomer = DoublyLinkedNode[char]

proc canReact(x, y: char): bool =
    return abs(int(x) - int(y)) == int('a') - int('A')

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

let file = commandLineParams()[0]
let input = file.readFile()

var polymer: Polymer = initDoublyLinkedList[char]()

for character in input:
    polymer.append(character)

var n1, n2: Monomer

while findReaction(polymer, n1, n2):
    echo "removing $1 and $2" % [$n1.value, $n2.value]
    polymer.remove(n1)
    polymer.remove(n2)

echo $polymer
echo "length: " & $polymer.count()