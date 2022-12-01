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

proc findSleepiestMinuteFrequency(sleep: Sleep): (int, int) =
    var slots: array[60, int]
    var sleepiestMinute, maxSleepTime: int
    for minute, slept in sleep:
        if slept > maxSleepTime:
            sleepiestMinute = minute
            maxSleepTime = slept
    echo "Sleepiest minute was $1 at $2 naps" % [$sleepiestMinute, $maxSleepTime]
    (sleepiestMinute, maxSleepTime)

proc findSneakyTime(file: string): int =
    let stats = compileNapStats(file)
    var guardId, sleepiestTime, maxSleepiness: int
    for id in stats.keys:
        echo "Checking guard $1..." % [$id]
        let (sleepyTime, sleepiness) = findSleepiestMinuteFrequency(stats[id])
        if sleepiness > maxSleepiness:
            maxSleepiness = sleepiness
            sleepiestTime = sleepyTime
            guardId = id
            echo "New record: guard $1 at minute $2 for $3 minutes" % [$guardId, $sleepiestTime, $maxSleepiness]
    guardId * sleepiestTime

let input = commandLineParams()[0]
echo "reading from " & input
echo "answer: " & $findSneakyTime(input)
