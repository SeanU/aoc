(import chicken.io)
(import chicken.string)
(import matchable)
(import srfi-1) ; lists
;; (import srfi-13) ; strings
(import srfi-113) ; sets
(import srfi-128) ; comparators

(define-record cpu-state cycle x input sum-strength)
(define-record noop)
(define-record storex)
(define-record addx addend)

(define (print-state state)
  (print "(cpu-state cycle: " (cpu-state-cycle state)
         " x: " (cpu-state-x state)
         " input: " (cpu-state-input state)
         " sum-strength: " (cpu-state-sum-strength state) ")"))

(define (parse-addx instruction)
  (make-addx (string->number (second (string-split instruction)))))

(define (parse-instruction instruction)
  (cond [(substring=? "noop" instruction) (make-noop)]
        [(substring=? "addx" instruction) (list (parse-addx instruction)
                                                (make-storex))]))

(define (calc-signal-strength state)
  (if (= 0 (modulo (- (cpu-state-cycle state) 20) 40))
      (begin
        (print "Accumulating sum strength at cycle " (cpu-state-cycle state))
        (let* [(x (cpu-state-x state))
               (cycle (cpu-state-cycle state))
               (strength (* x cycle))]
          (print "  Strength is " x " * " cycle " = " strength)
          (+ (cpu-state-sum-strength state) strength)))
      (cpu-state-sum-strength state)))

(define (run-noop state)
  (make-cpu-state (+ (cpu-state-cycle state) 1)
                  (cpu-state-x state)
                  0
                  (calc-signal-strength state)))

(define (run-addx state x)
  (make-cpu-state (+ (cpu-state-cycle state) 1)
                  (cpu-state-x state)
                  x
                  (calc-signal-strength state)))

(define (run-storex state)
  (make-cpu-state (+ (cpu-state-cycle state) 1)
                  (+ (cpu-state-x state) (cpu-state-input state))
                  0
                  (calc-signal-strength state)))

(define (run-cpu instructions)
  (let loop [(state (make-cpu-state 1 1 0 0))
             (instructions instructions)]
    (match instructions
      [() state]
      [(($ noop) . rest) (loop (run-noop state) rest)]
      [(($ addx x) . rest) (loop (run-addx state x) rest)]
      [(($ storex) . rest) (loop (run-storex state) rest)]
      [_ (begin
           (print "unrecognized instruction: " (car instructions))
           state)])))

(let* [(input (call-with-input-file "./2022/day10/input.txt" read-lines))
       (instructions (flatten (map parse-instruction input)))
       (final-state (run-cpu instructions))]

  ;; instructions
  (print-state final-state)
  (cpu-state-sum-strength final-state))
