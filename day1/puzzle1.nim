import os
from strutils import parseInt

var acc = 0

let inputFile = os.commandLineParams()[0]
for line in inputFile.lines:
    let addend = parseInt(line)
    acc = acc + addend

echo acc
