import math, os, strutils, sequtils

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
    
    Node(metadata: metadata, children: children)

func evaluate(node: Node): int =
    if len(node.children) == 0:
        return node.metadata.sum()
    else:
        return (
            node.metadata
                .mapIt(it - 1)
                .filterIt(it < node.children.len)
                .mapIt(evaluate(node.children[it]))
                .sum()
        )

let infile = commandLineParams()[0]
var input = infile.readFile().split(' ').map(parseInt).toStack()

let tree = readTree(input)
echo "value: " & $evaluate(tree)
