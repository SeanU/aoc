import os
import strutils
import sequtils

proc hammingDistance(a, b: string): int =
    var acc = 0
    for i in 0..<a.len:
        if a[i] == b[i]:
            inc(acc)
    a.len - acc

proc matchingChars(a: string, b: string): string =
    var acc = newseq[char](a.len)
    for i in 0..<a.len:
        if a[i] == b[i]:
            acc.add(a[i])
    join(acc, "")

proc findAnswer(file: string): string =
    let ids = toSeq(file.lines)

    for i in 0..<ids.len:
        for j in i+1..<ids.len:
            if hammingDistance(ids[i], ids[j]) == 1:
                let expectedLength = ids[i].len - 1
                return matchingChars(ids[i], ids[j])
    ""

let input = os.commandLineParams()[0]
echo "answer:"
echo findanswer(input)