(import chicken.io)
(import chicken.string)
(import srfi-1)
(import matchable)

(define (sum xs)
  (apply + xs))

(define (score-round line)
  (match line
    ("A X" (+ 1 3))
    ("A Y" (+ 2 6))
    ("A Z" (+ 3 0))

    ("B X" (+ 1 0))
    ("B Y" (+ 2 3))
    ("B Z" (+ 3 6))

    ("C X" (+ 1 6))
    ("C Y" (+ 2 0))
    ("C Z" (+ 3 3))))

(define (score-game lines)
  (map score-round lines))

(let [(lines (call-with-input-file "./2022/day02/input.txt" read-lines))]
  (sum (score-game lines)))
