import lists, os, parseutils, strutils

let numPlayers = parseInt(commandLineParams()[0])
let highMarble = parseInt(commandLineParams()[1])

echo "playing with $1 players, last marble is worth $2 points\n\n" % [$numPlayers, $highMarble]

var game = newSeqOfCap[int](highMarble)
var players = newSeq[int](numPlayers)
var cursor = 0

game.add(0)
for i in 1..highMarble:
    if (i mod 23) == 0:
        let curPlayer = (i - 1) mod numPlayers
        var nextCursor = (cursor - 7) mod len(game)
        if nextCursor < 0: nextCursor = len(game) + nextCursor
        let marbleToTake = game[nextCursor]
        inc(players[curPlayer], i)
        inc(players[curPlayer], marbleToTake)
        game.delete(nextCursor)
        cursor = nextCursor mod len(game)
        
    else:
        let nextCursor = (cursor + 2) mod len(game)
        game.insert(i, nextCursor)
        cursor = nextCursor

var winningElf, winningScore = -1
for elf, score in players:
    if score > winningScore:
        winningElf = elf
        winningScore = score

echo "elf $1 wins with $2 points" % [$winningElf, $winningScore]
