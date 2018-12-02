import os
import strutils
import sets

proc swizzleFrequencies(file: string): int =
    var acc = 0
    var history = initSet[int]()

    while true:
        for line in file.lines:
            acc = acc + parseInt(line)

            if history.contains(acc):
                return acc
            else:
                history.incl(acc)

            echo "$1 = $2" % [line, $acc]


let input = os.commandLineParams()[0]
let firstDup = swizzleFrequencies(input)

echo "\nfirst duplicate:"
echo firstDup
