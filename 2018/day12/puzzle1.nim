import lists, os, sequtils, strscans, strutils

type
    Garden = tuple[firstId: int, pots: seq[char]]
    Pattern = array[-2..2, char]
    Rule = tuple[pattern: Pattern, outcome: char]

proc draw(x: Garden): string =
    "$1[$2]$3" % [$x.firstId, join(x.pots, ""), $(x.firstId + len(x.pots))]

proc `$`(x: Pattern): string =
    join(x, "")

func readGarden(spec: string): Garden =
    for i in 0..<len(spec):
        result.pots.add(spec[i])

func readInitialState(line: string, garden: var Garden): bool =
    if(line.startsWith("initial state: ")):
        garden = readGarden(line.substr(len("initial state: ")))
        return true

func readPattern(patt: string): Pattern =
    result[-2] = patt[0]
    result[-1] = patt[1]
    result[-0] = patt[2]
    result[1] = patt[3]
    result[2] = patt[4]

func readRule(line: string, rule: var Rule): bool =
    if line.contains("=>"):
        rule.pattern = readPattern(line.substr(0,5))
        rule.outcome = line[9]
        return true

proc read(inFile: string): (Garden, seq[Rule]) =
    var garden: Garden
    var rules = newSeq[Rule]()
    for line in inFile.lines:
        var curLineInitialState: Garden
        var curLineRule: Rule
        if readInitialState(line, curLineInitialState):
            garden = curLineInitialState
        elif readRule(line, curLineRule) and curLineRule.outcome == '#':
            rules.add(curLineRule)
    (garden, rules)

proc len(g: Garden): int = len(g.pots)

func getPot(garden: Garden, pot: int): char =
    if pot < 0 or pot >= len(garden):
        return '.'
    else:
        return garden.pots[pot]

func getPatternAt(pot: int, garden: Garden): Pattern =
    for i in -2..2:
        result[i] = garden.getPot(pot + i)

func shouldLive(pot: int, garden: Garden, rules: seq[Rule]): char =
    let pattern = getPatternAt(pot, garden)
    if rules.anyIt(it.pattern == pattern):
        return '#'
    else:
        return '.'

func findFirstPlant(garden: Garden): int =
    for i in 0..<len(garden):
        if garden.pots[i] == '#':
            return i

func findLastPlant(garden: Garden): int =
    for i in countdown(high(garden.pots), low(garden.pots)):
        if garden.pots[i] == '#':
            return i

func prune(garden: Garden): Garden =
    let firstPlantIndex = findFirstPlant(garden)
    result.firstId = garden.firstId + firstPlantIndex
    for i in firstPlantIndex..findLastPlant(garden):
        result.pots.add(garden.pots[i])

func evolve(garden: Garden, rules: seq[Rule]): Garden =
    result.firstId = garden.firstId - 1
    for i in -1..garden.len():
        result.pots.add(shouldLive(i, garden, rules))
    result = prune(result)

func sum(garden: Garden): int =
    for i in low(garden.pots)..high(garden.pots):
        if getPot(garden, i) == '#':
            inc(result, i + garden.firstId)

let inFile = commandLineParams()[0]
let (initialState, rules) = read(inFile)

var lastState, curState: Garden = initialState
echo "0: $1 (sum: $2)" % [draw(curState), $sum(curState)]

for i in 1..20:
    lastState = curState
    curState = evolve(curState, rules)
    echo "$1: $2 (sum: $3)" % [$i, draw(curState), $sum(curState)]
