import algorithm
import math
import os
import parseutils
import sequtils
import strutils
import system
import tables
import times

type 
    LogLine = tuple[time: DateTime, text: string]
    NapTime = range[0..59]
    EntryKind = enum newGuard, sleep, wake
    Entry = ref object
        case kind: EntryKind
        of newGuard: id: int
        of sleep, wake: time: NapTime
    Nap = tuple[id: int, doze: NapTime, wake: NapTime]

proc duration(nap: Nap): NapTime = nap.wake - nap.doze
proc `$`(nap: Nap): string = "nap($1: $2-$3)" % [$nap.id, $nap.doze, $nap.wake]

proc readLines(file: string): seq[LogLine] =
    for line in file.lines:
        let timeStr = line.substr(1, 16)
        let time = parse(timeStr, "yyyy-MM-dd hh:mm")
        let logline = (time: time, text: line)
        result.add(logline)

proc sortLines(file: string): seq[string] =
    var fileLines: seq[LogLine]
    fileLines = readLines(file)
    fileLines.sort(proc(x, y: LogLine): int = cmp(x.time, y.time))
    fileLines.mapIt(it.text)

proc parseTime(line: string, time: var NapTime, start: int): int =
    var offset = 0
    offset = offset + skipUntil(line, ':', start + offset)
    offset = offset + skip(line, ":", start + offset)
    offset = offset + parseInt(line, time, start + offset)
    offset + skip(line, "] ", start + offset)

proc parseKind(line: string, kind: var EntryKind, cursor: int): int =
    var token: string
    result = parseUntil(line, token, ' ', cursor)
    kind = case token:
        of "Guard": 
            newGuard
        of "falls": 
            sleep
        of "wakes": 
            wake
        else:
            raise newException(ValueError, "bad token: " & token)

proc parseId(line: string, id: var int, start: int): int =
    var offset = 0
    offset = offset + skipUntil(line, '#', start)
    offset = offset + skip(line, "#", start + offset)
    offset + parseInt(line, id, start + offset)

proc parseEntry(line: string): Entry =
    var cursor = 0
    var naptime: NapTime
    var kind: EntryKind
    var id: int

    cursor = cursor + parseTime(line, naptime, cursor)
    cursor = cursor + parseKind(line, kind, cursor)

    case kind:
        of newGuard:
            discard parseId(line, id, cursor)
            Entry(kind: newGuard, id: id)
        of sleep:
            Entry(kind: sleep, time: naptime)
        of wake:
            Entry(kind: wake, time: naptime)    

iterator parseNaps(lines: seq[string]): Nap =
    var currentGuard: int
    var start: NapTime
    for entry in lines.map(parseEntry):
        case entry.kind:
            of newGuard:
                currentGuard = entry.id
            of sleep:
                start = entry.time
            of wake:
                yield (id: currentGuard, doze: start, wake: entry.time)

proc compileNapStats(file: string): TableRef[int, seq[Nap]] =
    result = newTable[int, seq[Nap]]()
    for nap in file.sortLines().parseNaps():
        if not result.hasKey(nap.id):
            result.add(nap.id, newSeq[Nap]())
        result[nap.id].add(nap)

proc findSleepyGuard(stats: TableRef[int, seq[Nap]]): int =
    var sleepiness: int
    for pair in stats.pairs():
        let (id, naps) = pair
        let sleepTime = naps.map(duration).sum()
        if sleepTime > sleepiness:
            result = id
            sleepiness = sleepTime
    echo "Sleepy guard #$1 slept $2 minutes" % [$result, $sleepiness]

proc findSleepiestMinuteFrequency(naps: seq[Nap]): (int, int) =
    var slots: array[60, int]
    var sleepiestMinute, maxSleepTime: int
    for nap in naps:
        for minute in nap.doze..<nap.wake:
            inc(slots[minute])
    for i in 0..<60:
        if slots[i] > maxSleepTime:
            sleepiestMinute = i
            maxSleepTime = slots[i]
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
