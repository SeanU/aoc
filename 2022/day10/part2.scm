(import chicken.io)
(import chicken.string)
(import matchable)
(import srfi-1) ; lists
;; (import srfi-13) ; strings
(import srfi-113) ; sets
(import srfi-128) ; comparators

(define-record cpu-state cycle x input)
(define-record noop)
(define-record storex)
(define-record addx addend)

(define (print-state state)
  (print "(cpu-state cycle: " (cpu-state-cycle state)
         " x: " (cpu-state-x state)
         " input: " (cpu-state-input state) ")"))

(define (parse-addx instruction)
  (make-addx (string->number (second (string-split instruction)))))

(define (parse-instruction instruction)
  (cond [(substring=? "noop" instruction) (make-noop)]
        [(substring=? "addx" instruction) (list (parse-addx instruction)
                                                (make-storex))]))

(define (run-noop state)
  (make-cpu-state (+ (cpu-state-cycle state) 1)
                  (cpu-state-x state)
                  0))

(define (run-addx state x)
  (make-cpu-state (+ (cpu-state-cycle state) 1)
                  (cpu-state-x state)
                  x))

(define (run-storex state)
  (make-cpu-state (+ (cpu-state-cycle state) 1)
                  (+ (cpu-state-x state) (cpu-state-input state))
                  0))

(define (get-pixel state)
  (let* [(scan (modulo (cpu-state-cycle state) 40))
         (x (cpu-state-x state))
         (pixel
          (if (<= (abs (- scan x)) 1)
              #\#
              #\.))]
    ;; (print "get-pixel at: " scan
    ;;        " with x at " x
    ;;        ": " pixel)
    pixel))

(define (run-cpu instructions)
  (let loop [(state (make-cpu-state 0 1 0))
             (pixels '())
             (instructions instructions)]
    (match instructions
      [() (reverse pixels)]
      [(($ noop) . rest) (loop (run-noop state)
                               (cons (get-pixel state) pixels)
                               rest)]
      [(($ addx x) . rest) (loop (run-addx state x)
                                 (cons (get-pixel state) pixels)
                                 rest)]
      [(($ storex) . rest) (loop (run-storex state)
                                 (cons (get-pixel state) pixels)
                                 rest)]
      [_ (begin
           (print "unrecognized instruction: " (car instructions))
           state)])))

(define (draw pixels)
  (let* [(scans (chop pixels 40))
         (lines (map (lambda (l) (apply string l)) scans))]
    (for-each print lines)))

(let* [(input (call-with-input-file "./2022/day10/input.txt" read-lines))
       (instructions (flatten (map parse-instruction input)))
       (pixels (run-cpu instructions))]
  (draw pixels)
  ;; instructions
  ;; (print-state final-state)
  ;; (cpu-state-sum-strength final-state)
  )
