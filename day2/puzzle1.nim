import os
import strutils

proc calcTally(line: string): array[26, int] =
    var tally: array[26, int]
    for i in 0..<line.len:
        let letterIndex = ((int) line[i]) - (int) 'a'
        inc(tally[letterIndex])
    tally

proc checksum(file: string): int =
    var pairs = 0
    var triples = 0

    for line in file.lines:
        let tally = calcTally(line)
        if 2 in tally:
            inc(pairs)
        if 3 in tally:
            inc(triples)
    
    pairs * triples

let input = commandLineParams()[0]
echo "checksum:"
echo checksum(input)
