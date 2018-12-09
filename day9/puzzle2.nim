import lists, math, os, parseutils, strutils

type
    Slot = ref object
        previous, next: Slot
        value: int

proc initRing(value: int): Slot =
    result = Slot(value: value)
    result.next = result
    result.previous = result

proc skip(slot: Slot, spaces: int): Slot =
    result = slot
    if spaces < 0:
        let spaces = abs(spaces)
        for i in 1..spaces:
            result = result.previous
    else:
        for i in 1..spaces:
            result = result.next

proc delete(slot: Slot): Slot =
    result = slot.next
    result.previous = slot.previous
    slot.previous.next = result

proc insertAfter(slot: Slot, value: int): Slot =
    result = Slot(previous: slot, next: slot.next, value: value)
    slot.next.previous = result
    slot.next = result

let numPlayers = parseInt(commandLineParams()[0])
let highMarble = parseInt(commandLineParams()[1])

echo "playing with $1 players, last marble is worth $2 points..\n\n" % [$numPlayers, $highMarble]

var game = initRing(0)
var players = newSeq[int](numPlayers)

for i in 1..highMarble:

    if (i mod 23) == 0:
        let curPlayer = (i - 1) mod numPlayers
        game = game.skip(-7)
        inc(players[curPlayer], i + game.value)
        game = game.delete()
        
    else:
        game = game.skip(1).insertAfter(i)

echo "Game over!"

var winningElf, winningScore = -1
for elf, score in players:
    if score > winningScore:
        winningElf = elf
        winningScore = score

echo "player $1 wins with $2 points" % [$winningElf, $winningScore]
