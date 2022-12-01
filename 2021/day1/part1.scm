(import chicken.io)
(import srfi-1)
(import matchable)


(define count-greater
  (lambda (lines)
    (letrec 
        (
            (values (filter integer? (map string->number lines)))
            (loop
                (lambda (lst acc)
                    (match lst
                        [(x y . rest) 
                            (if (> y x)
                                (loop (cdr lst) (+ acc 1))
                                (loop (cdr lst) acc))]
                        [else acc])))
        )
        (loop values 0))))

(let [(lines (call-with-input-file "day1/input.txt" read-lines))]
    (print (count-greater lines)))
