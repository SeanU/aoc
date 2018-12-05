import algorithm
import math
import os
import sequtils
import strscans
import strutils
import tables

type 
    Sleep = array[60, int]
    Nap = tuple[id: int, doze: int, wake: int]

iterator parseNaps(lines: seq[string]): Nap =
    var date: string
    var time, id, currentGuard, start: int

    for line in lines:
        if scanf(line, "[$+:$i] Guard #$i", date, time, id):
            currentGuard = id
        elif scanf(line, "[$+:$i] falls asleep", date, time):
            start = time
        elif scanf(line, "[$+:$i] wakes up", date, time):
            yield (id: currentGuard, doze: start, wake: time)

proc compileNapStats(file: string): TableRef[int, Sleep] =
    result = newTable[int, Sleep]()
    for nap in file.readFile().splitLines().sorted(cmp[string]).parseNaps():
        if not result.hasKey(nap.id):
            var sleep: Sleep
            result[nap.id] = sleep
        for min in nap.doze ..< nap.wake:
            inc(result[nap.id][min])

proc findSleepyGuard(stats: TableRef[int, Sleep]): int =
    var sleepiness: int
    for pair in stats.pairs():
        let (id, sleep) = pair
        let sleepTime = sleep.sum()
        if sleepTime > sleepiness:
            result = id
            sleepiness = sleepTime
    echo "Sleepy guard #$1 slept $2 minutes" % [$result, $sleepiness]

proc findSleepiestMinute(sleep: Sleep): int =
    var maxSlept = 0
    for minute, slept in sleep:
        if slept > maxSlept:
            result = minute
            maxSlept = slept
    echo "Sleepiest minute was $1 at $2 naps" % [$result, $maxSlept]

proc findSneakyTime(file: string): int =
    let stats = compileNapStats(file)
    let sleepyGuard = findSleepyGuard(stats)
    let sleepyTime = findSleepiestMinute(stats[sleepyGuard])
    sleepyTime * sleepyGuard

let input = commandLineParams()[0]
echo "reading from " & input
echo "answer: " & $findSneakyTime(input)
