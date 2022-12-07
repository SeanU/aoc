(import chicken.io)
(import chicken.string)
(import srfi-1)

(define (unique lst)
  (let loop [(rest lst)
             (acc '())]
    (cond [(null? rest) acc]
          [(member (car rest) acc) (loop (cdr rest) acc)]
          [else (loop (cdr rest) (cons (car rest) acc))])))

(define (find-first-packet lst)
  (let loop [(packet (reverse (take lst 4)))
             (rest (drop lst 4))]
    (let* [(last-four (take packet 4))
           (uniq-four (unique last-four))]
      ;; (print packet)
      ;; (print last-four)
      ;; (print uniq-four)
      ;; (print rest)
      ;; (newline)
      (if (= (length uniq-four) 4)
          packet
          (loop (cons (car rest) packet)
                (cdr rest))))))

(let* [(input (call-with-input-file "./2022/day06/input.txt" read-line))
       (input-list (string->list input))
       (first-packet (find-first-packet input-list))]
  (print first-packet)
  (length first-packet))
