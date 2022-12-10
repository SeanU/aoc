(import chicken.io)
(import chicken.string)
(import matchable)
(import srfi-1) ; lists
(import srfi-13) ; strings
(import srfi-113) ; sets
(import srfi-128) ; comparators
(import srfi-196) ; ranges

(define (point x y)
  (vector x y))

(define (point-x pt)
  (vector-ref pt 0))

(define (point-y pt)
  (vector-ref pt 1))

(define (point-add a b)
  (point (+ (point-x a) (point-x b))
         (+ (point-y a) (point-y b))))

(define (point-sub a b)
  (point (- (point-x a) (point-x b))
         (- (point-y a) (point-y b))))

(define point-comparator
  (make-vector-comparator (make-equal-comparator)
                          vector?
                          vector-length
                          vector-ref))

(define (direction->vector dir)
  (cond [(equal? dir "L") (vector -1  0)]
        [(equal? dir "R") (vector  1  0)]
        [(equal? dir "U") (vector  0 -1)]
        [(equal? dir "D") (vector  0  1)]))

(define (expand-move move)
  (let* [(parts (string-split move))
         (direction (direction->vector (first parts)))
         (times (string->number (second parts)))]
    (make-list times direction)))

(define (parse-moves input)
  (apply append (map expand-move input)))

;; (define (move-head moves)
;;   (let loop [(moves moves)
;;              (pos (point 0 0))
;;              (acc '())]
;;     (if (null? moves)
;;         (reverse acc)
;;         (let [(next (point-add pos (car moves)))]
;;           (loop (cdr moves) next (cons next acc))))))

(define (drag tail head)
  (let* [(difference (point-sub head tail))
         (move (match difference
                 ;; left
                 [#(-2 -1) #(-1 -1)]
                 [#(-2  0) #(-1  0)]
                 [#(-2  1) #(-1  1)]

                 ;; right
                 [#( 2 -1) #( 1 -1)]
                 [#( 2  0) #( 1  0)]
                 [#( 2  1) #( 1  1)]

                 ;; down
                 [#(-1  2) #(-1  1)]
                 [#( 0  2) #( 0  1)]
                 [#( 1  2) #( 1  1)]

                 ;; up
                 [#(-1 -2) #(-1 -1)]
                 [#( 0 -2) #( 0 -1)]
                 [#( 1 -2) #( 1 -1)]

                 [_ #(0 0)]))]
    (point-add tail move)))

(define (track-head moves)
  (let loop [(moves moves)
             (head-pos (point 0 0))
             (tail-pos (point 0 0))
             (acc '())]
    (if (null? moves)
        (reverse acc)
        (let* [(next-move (car moves))
               (next-head-pos (point-add head-pos next-move))
               (next-tail-pos (drag tail-pos next-head-pos))]
          (loop (cdr moves)
                next-head-pos
                next-tail-pos
                (cons next-tail-pos acc))))))

(let* [(input (call-with-input-file "./2022/day09/input.txt" read-lines))
       (moves (parse-moves input))
       ;; (head-positions (move-head moves))
       (tail-positions (track-head moves))
       (unique-tail-positions (list->set point-comparator tail-positions))]
  (set-size unique-tail-positions))
