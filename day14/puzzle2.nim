import os, strutils

const chunkSize = 10000

type
    Chunk = tuple[spots: string, cursor: int]
    Chalkboard = seq[Chunk]

func newChunk(): Chunk = (repeat(' ', chunkSize), 0)

func isFull(c: Chunk): bool =
    return c.cursor >= chunkSize

proc append(c: var Chunk, score: char): void =
    c.spots[c.cursor] = score
    inc(c.cursor)

func newChalkboard(): Chalkboard =
    result = newSeq[Chunk]()
    result.add(newChunk())

func getScore(cb: Chalkboard, i: int): int =
    const zero = int('0')
    let chunkId = i div chunkSize
    let chunkIndex = i mod chunkSize
    int(cb[chunkId].spots[chunkIndex]) - zero

proc append(cb: var Chalkboard, score: char): void =
    if cb[high(cb)].isFull():
        cb.add(newChunk())
    cb[high(cb)].append(score)
    
proc append(cb: var Chalkboard, scores: string): void =
    for c in scores:
        cb.append(c)

func length(cb: Chalkboard): int =
    for chunk in cb:
        inc(result, chunk.cursor)

proc findAtEnd(cb: Chalkboard, patt: string, padding: int): int =
    let neededLen = len(patt) + padding
    var target = cb[high(cb)].spots.strip
    var skippedChunks = high(cb)
    if len(target) < neededLen:
        target = cb[high(cb) - 1].spots & target
        dec(skippedChunks)
    result = target.find(patt, len(target) - neededLen)
    if result >= 0:  # adjust for rest of chunks
        inc(result, skippedChunks * chunkSize)

func newRecipes(cb: Chalkboard, elves: array[0..1, int]): string =
    var score = 0
    for elf in elves:
        score = score + cb.getScore(elf)
    $score

func cleanScoreMoveDown(cb: Chalkboard, elves: array[0..1, int]): array[0..1, int] =
    for i in 0..high(elves):
        let spaces = cb.getScore(elves[i]) + 1
        result[i] = (elves[i] + spaces) mod cb.length()

let targetString = commandLineParams()[0]
let padding = 2

var cb = newChalkboard()
cb.append("37")
var elves = [0, 1]
var location = -1

while cb.length() < (len(targetString) + padding):
    cb.append(newRecipes(cb, elves))
    elves = cleanScoreMoveDown(cb, elves)

while location < 0:
    cb.append(newRecipes(cb, elves))
    elves = cleanScoreMoveDown(cb, elves)

    location = cb.findAtEnd(targetString, padding)

echo "scores to left: " & $location