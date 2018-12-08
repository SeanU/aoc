import algorithm, os, sequtils, sets, strscans, strutils, tables

type
    DependencyMap = Table[string, seq[string]]
    Tasks = HashSet[string]
    Manual = tuple[deps: DependencyMap, steps: Tasks]
    Work = tuple[task: string, start: int]

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

func duration(task: string, minTime: int): int =
    minTime + 1 + (int(task[0]) - int('A'))

func finishTime(work: Work, minTime: int): int =
    work.start + work.task.duration(minTime)

func isCompleted(work: Work, time, minTime: int): bool =
    return time >= work.finishTime(minTime)

proc completeTasks(time, minTime: int, workers: var HashSet[Work], completedTasks: var Tasks): void =
    for work in workers:
        if work.isCompleted(time, minTime):
            echo "Task $1 is done" % [work.task]
            completedTasks.incl(work.task)
            workers.excl(work)

proc findAvailableTasks(tasks, completedTasks: Tasks, deps: DependencyMap): seq[string] =
    result = newSeq[string]()
    for task in tasks:
        let taskDeps = deps.getOrDefault(task, @[])
        if (taskDeps.all do (x: string) -> bool: completedTasks.contains(x)):
            result.add(task)
    sort(result, cmp[string])

proc tryAssign(task: string, workers: var HashSet[Work], maxWorkers, time: int): bool =
    if len(workers) >= maxWorkers:
        echo "    Everyone's busy"
        return false
    else:
        echo "    Starting work on $1 at second $2" % [task, $time]
        workers.incl((task, time))
        return true

let inputFile = commandLineParams()[0]
let numWorkers = parseInt(commandLineParams()[1])
let minWorkTime = parseInt(commandLineParams()[2])
var (dependencies, tasks) = loadDependencies(inputFile)
let numTasks = len(tasks)

var workers = initSet[Work]()
var completedTasks = initSet[string]()
var currentTime = -1


while len(completedTasks) < numTasks:
    inc(currentTime)
    echo "second $1 - $2 tasks in progress" % [$currentTime, $len(workers)]

    completeTasks(currentTime, minWorkTime, workers, completedTasks)
    for task in findAvailableTasks(tasks, completedTasks, dependencies):
        echo "Trying to find a worker for $1" % [task]
        if tryAssign(task, workers, numWorkers, currentTime):
            tasks.excl(task)


echo "Time to complete: " & $currentTime
