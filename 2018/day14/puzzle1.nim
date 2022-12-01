import os, strutils

func get(scores: string, num: int): int =
    const zero = int('0')
    int(scores[num]) - zero

func newRecipes(scores: string, elves: array[0..1, int]): string =
    var score = 0
    for elf in elves:
        score = score + scores.get(elf)
    $score

func cleanScoreMoveDown(scores: string, elves: array[0..1, int]): array[0..1, int] =
    for i in 0..high(elves):
        let spaces = scores.get(elves[i]) + 1
        result[i] = (elves[i] + spaces) mod len(scores)

let elfRecipes = parseInt(commandLineParams()[0])
let stopLen = elfRecipes + 10

var scores = "37"
var elves = [0, 1]

while len(scores) < stopLen:
    scores = scores & newRecipes(scores, elves)
    elves = cleanScoreMoveDown(scores, elves)

echo "extra scores: " & scores.substr(elfRecipes, stopLen)