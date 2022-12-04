;; Day 4 Part 1
(import chicken.io)
(import chicken.string)

(define (parse-assignment input)
  (map string->number (string-split input "-")))

(define (parse-assignment-pair line)
  (let [(parts (string-split line ","))]
    (map parse-assignment parts)))

(define (is-in? a b)
  (let [(a-start (car a))
        (a-end (cadr a))
        (b-start (car b))
        (b-end (cadr b))]
    (and (<= b-start a-start)
         (>= b-end a-end))))

(define (overlap? assignments)
  (let [(a (car assignments))
        (b (cadr assignments))]
    (or (is-in? a b) (is-in? b a))))

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
