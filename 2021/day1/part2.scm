(import chicken.io)
(import srfi-1)
(import matchable)


(define count-greater-windows
  (lambda (lines)
          (letrec ((values (filter integer? (map string->number lines)))
                   (loop
                     (lambda (lst acc)
                             (match lst
                                    [(w x y z . rest) 
                                     (let ((a (+ w x y))
                                           (b (+ x y z)))
                                       (if (> b a)
                                         (loop (cdr lst) (+ acc 1))
                                         (loop (cdr lst) acc)))
                                     ]
                                    [else acc])))
                   )
            (loop values 0))))

(let [(lines (call-with-input-file "day1/input.txt" read-lines))]
  (print (count-greater-windows lines)))
