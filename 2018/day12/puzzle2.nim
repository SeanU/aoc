import lists, os, sequtils, strscans, strutils

type
    Garden = tuple[firstId: int, pots: string]
    Pattern = array[-2..2, char]
    Rule = tuple[pattern: Pattern, outcome: char]

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

func getPot(pots: string, pot: int): char =
    if pot < 0 or pot >= len(pots):
        return '.'
    else:
        return pots[pot]

func matchesAt(pattern: Pattern, pots: string, pot: int): bool =
    for i in -2..2:
        if pattern[i] != pots.getPot(i + pot):
            return false
    return true

func shouldLive(pot: int, garden: Garden, rules: seq[Rule]): char =
    if rules.anyIt(it.pattern.matchesAt(garden.pots, pot)):
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
    let firstPlant = findFirstPlant(garden)
    let lastPlant = findLastPlant(garden)
    result.firstId = garden.firstId + firstPlant
    result.pots = garden.pots.substr(firstPlant, lastPlant)

func evolve(garden: Garden, rules: seq[Rule]): Garden =
    result.firstId = garden.firstId - 1
    result.pots = repeat('.', garden.len + 2)
    for i in -1..garden.len():
        result.pots[i + 1] = shouldLive(i, garden, rules)
    result = prune(result)

func sum(garden: Garden): int =
    for i in 0..high(garden.pots):
        if getPot(garden.pots, i) == '#':
            inc(result, i + garden.firstId)

let inFile = commandLineParams()[0]
let (initialState, rules) = read(inFile)

var curState: Garden = initialState
# echo "$1: $2" % [$0, curState.pots]

for i in 1..50000000000:
    curState = evolve(curState, rules)
    if i mod 100000 == 0:
        echo "$1: $2 (sum: $3)" % [$i, curState.pots, $sum(curState)]

echo "sum: $1" % [$sum(curState)]