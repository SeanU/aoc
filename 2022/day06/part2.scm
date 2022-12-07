(import chicken.io)
(import chicken.string)
(import srfi-1)

(define marker-size 14)

(define (unique lst)
  (let loop [(rest lst)
             (acc '())]
    (cond [(null? rest) acc]
          [(member (car rest) acc) (loop (cdr rest) acc)]
          [else (loop (cdr rest) (cons (car rest) acc))])))

(define (find-first-packet lst)
  (let loop [(packet (reverse (take lst marker-size)))
             (rest (drop lst marker-size))]
    (let* [(last-four (take packet marker-size))
           (uniq-four (unique last-four))]
      ;; (print packet)
      ;; (print last-four)
      ;; (print uniq-four)
      ;; (print rest)
      ;; (newline)
      (if (= (length uniq-four) marker-size)
          packet
          (loop (cons (car rest) packet)
                (cdr rest))))))

(let* [(input (call-with-input-file "./2022/day06/input.txt" read-line))
       (input-list (string->list input))
       (first-packet (find-first-packet input-list))]
  (print first-packet)
  (length first-packet))
