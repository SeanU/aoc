import os, sequtils, sets, strscans, strutils, tables

type
    DependencyMap = Table[string, seq[string]]
    Tasks = HashSet[string]
    Manual = tuple[deps: DependencyMap, steps: Tasks]

proc loadDependencies(path: string): Manual =
    const pattern = "Step $w must be finished before step $w"
    var deps = initTable[string, seq[string]]()
    var steps = initSet[string]()
    var task, dependency: string

    for line in path.lines():
        if scanf(line, pattern, dependency, task):
            steps.incl(dependency)
            steps.incl(task)

            if not deps.hasKey(task):
                deps[task] = newSeq[string]()
            deps[task].add(dependency)

    (deps, steps)

func findNextStep(tasks: Tasks, deps: DependencyMap): string =
    result = "ZZZZZ"
    for task in tasks:
        if cmp(task, result) < 0:
            let taskDeps = deps.getOrDefault(task, @[])
            if not (taskDeps.any do (x: string) -> bool: tasks.contains(x)):
                result = task

let inputFile = commandLineParams()[0]
var (dependencies, tasks) = loadDependencies(inputFile)

var steps = ""

while len(tasks) > 0:
    let nextStep = findNextStep(tasks, dependencies)
    steps = steps & nextStep
    tasks.excl(nextStep)

echo "steps: " & steps