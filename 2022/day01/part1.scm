(import chicken.io)
(import srfi-1)
(import matchable)

(define (count-calories lines)
  (letrec [(loop (lambda (lines most acc)
                    (match lines
                       ['() (max acc most)]
                       [("" . rest) (loop rest (max acc most) 0)]
                       [(cals . rest)
                        (loop rest most (+ acc (string->number cals)))])))]
    (loop lines 0 0)))

(let [(lines (call-with-input-file "./2022/day01/input.txt" read-lines))]
  (count-calories lines))
