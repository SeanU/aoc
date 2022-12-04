;; Day 4 Part 2
(import chicken.io)
(import chicken.string)
(import srfi-1) ; extra list stuff
(import srfi-196) ; ranges

(define (parse-assignment input)
  (map string->number (string-split input "-")))

(define (parse-assignment-pair line)
  (let [(parts (string-split line ","))]
    (map parse-assignment parts)))

(define (overlap? assignments)
  (let* [(a (car assignments))
         (b (cadr assignments))
         (a-range (numeric-range (car a) (+ (cadr a) 1)))
         (b-range (numeric-range (car b) (+ (cadr b) 1)))
         (a-sections (range->list a-range))
         (b-sections (range->list b-range))]
    (> (length (lset-intersection eq? a-sections b-sections))
       0)))

(define (count-true xs)
  (let loop [(lst xs)
             (acc 0)]
    (if (null? lst)
        acc
        (loop (cdr lst) (+ acc
                           (if (car lst) 1 0))))))

(let* [(lines (call-with-input-file "./2022/day04/input.txt" read-lines))
       (assignments (map parse-assignment-pair lines))
       (overlaps (map overlap? assignments))]
  (count-true overlaps))
