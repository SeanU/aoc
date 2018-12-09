import os, strutils, sequtils

type
    Stack[T] = ref object
        head: T
        tail: Stack[T]

    Node = object 
        metadata: seq[int]
        children: seq[Node]

func empty[T](): Stack[T] = nil

func push[T](stack: var Stack[T], value: T) =
    stack = Stack[T](head: value, tail: stack)

func pop[T](stack: var Stack[T]): T =
    result = stack.head
    stack = stack.tail

func `$`[T](stack: Stack[T]): string =
    result = "["
    var node = stack
    while node != nil:
        if result.len > 1: result.add(", ")
        result.add($node.head)
        node = node.tail
    result.add("]")

func toStack(input: seq[int]): Stack[int] =
    result = empty[int]()
    for i in countdown(high(input), low(input)):
        result.push(input[i])

proc readTree(input: var Stack[int]): Node =
    var nchildren, nmetadata: int
    
    nchildren = input.pop()
    nmetadata = input.pop()

    var children = newSeqOfCap[Node](nchildren)
    while len(children) < nchildren and input != nil:
        children.add(readTree(input))

    var metadata = newSeqOfCap[int](nmetadata)
    while len(metadata) < nmetadata and input != nil:
        metadata.add(input.pop)
    
    echo "$1 children and metadata: $2" % [$len(children), $metadata]
    Node(metadata: metadata, children: children)

iterator traverseMetadata(tree: Node): int =
    var todo = empty[Node]()
    todo.push(tree)
    
    while todo != nil:
        let node = todo.pop()
        for md in node.metadata:
            yield md
        for child in node.children:
            todo.push(child)
        


let infile = commandLineParams()[0]
var input = infile.readFile().split(' ').map(parseInt).toStack()

let tree = readTree(input)

var acc = 0
for md in traverseMetadata(tree):
    acc = acc + md
echo ""
echo "metadata sum: " & $acc
