(import chicken.io)
(import chicken.sort)
(import srfi-1)
(import matchable)

(define (count-calories lines)
  (letrec [(loop (lambda (lines elves acc)
                    (match lines
                       ['() (cons acc elves)]
                       [("" . rest) (loop rest (cons acc elves) 0)]
                       [(cals . rest) (loop rest elves (+ acc (string->number cals)))])))]
    (loop lines '() 0)))

(define (take-top n lst)
     (take (sort lst >) n))

(let [(lines (call-with-input-file "./2022/day01/input.txt" read-lines))]
  (apply + (take-top 3 (count-calories lines))))
