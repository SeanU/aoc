(import chicken.format)
(import chicken.io)
(import chicken.string)
(import chicken.pretty-print)
(import srfi-1) ; extra list functions
(import srfi-13) ; strings
(import srfi-71) ; receive multiple values from let

;;     [D]
;; [N] [C]
;; [Z] [M] [P]
;;  1   2   3

;; move 1 from 2 to 1
;; move 3 from 1 to 3
;; move 2 from 2 to 1
;; move 1 from 1 to 2

(define-record state stacks instructions)

(define (string-not-empty? str)
  (> (string-length (string-trim str))
     0))

(define (chop-instructions lines)
  (define (is-instruction? line)
    (substring=? line "move" 0 0 4))

  (partition is-instruction? (filter string-not-empty? lines)))

(define (chop-diagram diagram-line)
  (map string-trim-both (string-chop diagram-line 4)))

(define (pad-all lst)
  (let [(longest (apply max (map string-length lst)))]
    (map (lambda (str) (string-pad-right str longest)) lst)))

(define (add-crates stacks diagram-line)
  (let [(diagram (chop-diagram diagram-line))]
    (map cons diagram stacks)))

(define (remove-empty stack)
  (filter string-not-empty? stack))

(define (parse-stacks lst)
  (let loop [(stacks (map list (chop-diagram (car lst))))
             (diagram (pad-all (cdr lst)))]
    (if (null? diagram)
        (list->vector (map remove-empty stacks))
        (loop (add-crates stacks (car diagram)) (cdr diagram)))))

(define (apply-instruction state instruction-text)
  (let* [(parts (string-split instruction-text))
         (from (- (string->number (fourth parts)) 1))
         (to (- (string->number (sixth parts)) 1))]
    (do [(num (string->number (second parts)) (- num 1))]
      ((= num 0) state)
      (vector-set! state
                   to
                   (cons (car (vector-ref state from))
                         (vector-ref state to)))
      (vector-set! state
                   from
                   (cdr (vector-ref state from))))))

(define (parse lines)
  (let* [(lines (reverse lines))
         (instructions stacks (chop-instructions lines))]
    (make-state (parse-stacks stacks) instructions)))

(define (run-instructions state instructions)
  (if (null? instructions)
      state
      (begin
        (map print (map reverse (vector->list state)))
        (print (car instructions))
        (newline)
        (run-instructions (apply-instruction state (car instructions))
                          (cdr instructions)))))

(define (collect-top-crates state)
  (apply string
         (map (lambda (s) (string-ref s 1))
              (map car (vector->list state)))))

(let* [(lines (call-with-input-file "./2022/day05/test-input.txt" read-lines))
       (initial-state (parse lines))
       (final-state (run-instructions (state-stacks initial-state)
                                      (reverse (state-instructions initial-state))))
       (tops (collect-top-crates final-state))]
  tops)
