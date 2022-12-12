(import chicken.io)
(import chicken.sort)
(import chicken.string)
;; (import matchable)
(import math.base)
(import srfi-1) ; lists
(import srfi-13) ; strings
(import srfi-14) ; character sets
(import srfi-71) ; let binds multiple values
;; (import srfi-113) ; sets
(import srfi-117) ; queues
;; (import srfi-128) ; comparators
(import srfi-196) ; ranges

(define-record monkey
  name ; the monkey's name (actually a number)
  inspections ; number of times monkey inspected an item
  items ; items the monkey currently has, as a queue
  operation ; function to mutate the item's worry level
  test ; divisor for deciding who to throw to
  true-monkey ; monkey to throw to if worry level is divisible by divisor
  false-monkey ; monkey to throw to if not
  )

(define (print-monkey monkey)
  (print "(monkey " (monkey-name monkey)
         ":\n\titems: " (list-queue-list (monkey-items monkey))
         "\n\tinspections: " (monkey-inspections monkey)
         "\n\toperation: " (monkey-operation monkey)
         "\n\t\texample: (op 5) -> " ((monkey-operation monkey) 5)
         "\n\ttest: divisible by " (monkey-test monkey)
         "\n\tif-true: throw to " (monkey-true-monkey monkey)
         "\n\tif-false: throw to " (monkey-false-monkey monkey)
         "\n\t)"))

(define char-set:operation
  (char-set-union char-set:digit
                  (string->char-set "old*+")))

(define (read-monkey-lines lines)
  (define (parse-monkey-number line)
    (string->number (string-trim-right (second (string-split line))
                                       #\:)))

  (define (parse-items line)
    (make-list-queue (map string->number
                          (string-tokenize line char-set:digit))))

  (define (parse-operation line)
    (define (operand->code operand)
      (if (equal? operand "old")
          'old
          (string->number operand)))

    (let* [(expr (string-tokenize (substring/shared line
                                                    (string-length "Operation:"))
                                  char-set:operation))
           (x (operand->code (first expr)))
           (op (string->symbol (second expr)))
           (y (operand->code (third expr)))]
      (eval `(lambda (old) (,op ,x ,y)))))

  (define (parse-single-number line)
    (string->number (first (string-tokenize line char-set:digit))))

  (let [(name (parse-monkey-number (first lines)))
        (items (parse-items (second lines)))
        (operation (parse-operation (third lines)))
        (test (parse-single-number (fourth lines)))
        (true-monkey (parse-single-number (fifth lines)))
        (false-monkey (parse-single-number (sixth lines)))
        (rest (drop lines 6))]
    (values (make-monkey name 0 items operation test true-monkey false-monkey)
            rest)))


(define (parse-monkeys lines)
  (let loop[(lines lines)
            (monkeys '())]
    (cond [(null? lines) (reverse monkeys)]

          [(string-null? (car lines)) (loop (cdr lines) monkeys)]

          [(substring=? "Monkey" (car lines))
           (let [(monkey rest (read-monkey-lines lines))]
             (loop rest (cons monkey monkeys)))]

          [else
           (error "unexpected line: " (car lines))])))


(define (find-monkey monkeys name)
  (find (lambda (m) (equal? name (monkey-name m))) monkeys))


(define (take-turn monkeys active-monkey worry-reduction-rate)
  (let [(items (monkey-items active-monkey))
        (operation (monkey-operation active-monkey))
        (test-number (monkey-test active-monkey))
        (true-monkey-items (monkey-items
                            (find-monkey monkeys
                                         (monkey-true-monkey active-monkey))))
        (false-monkey-items (monkey-items
                             (find-monkey monkeys
                                          (monkey-false-monkey active-monkey))))]

    (define (handle-item item)
      (let* [(worry-level (modulo (operation item) worry-reduction-rate))
             (test-result (= 0 (modulo worry-level test-number)))
             (next-monkey (if test-result
                              true-monkey-items
                              false-monkey-items))]
        (list-queue-add-front! next-monkey worry-level)
        (monkey-inspections-set! active-monkey
                                 (+ 1 (monkey-inspections active-monkey)))))

    (for-each handle-item (list-queue-remove-all! items))))


(define (do-round monkeys worry-reduction-rate)
  (for-each (lambda (m) (take-turn monkeys m worry-reduction-rate)) monkeys))


(define (calc-monkey-business monkeys)
  (fold * 1 (take (sort (map monkey-inspections monkeys)
                        >)
                  2)))

(define (calc-worry-reduction-rate monkeys)
  (apply lcm (map monkey-test monkeys)))

(let* [(input (call-with-input-file "./2022/day11/input.txt" read-lines))
       (clean-input (map string-trim-both input))
       (monkeys (parse-monkeys clean-input))
       (worry-reduction-rate (calc-worry-reduction-rate monkeys))]
  ;; (for-each print-monkey monkeys)
  (print "worry reduction rate is " worry-reduction-rate)
  (range-for-each (lambda (_) (do-round monkeys worry-reduction-rate))
                  (numeric-range 0 10000))
  (newline)
  (print "After monkey business:")
  (for-each print-monkey monkeys)
  (calc-monkey-business monkeys))
