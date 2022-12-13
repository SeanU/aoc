(import chicken.io)
(import chicken.string)
(import format)
(import matchable)
;; (import math.base)
(import traversal)
(import srfi-1) ; lists
;; (import srfi-13) ; strings
;; (import srfi-14) ; character sets
;; (import srfi-71) ; let binds multiple values
(import srfi-113) ; sets
;; (import srfi-117) ; queues
;; (import srfi-128) ; comparators
(import srfi-133) ; vectors
;; (import srfi-196) ; ranges
(import chicken.sort)

(define-record point x y)
(define-record-printer (point p out)
  (format out "(~S, ~S)" (point-x p) (point-y p)))


(define-record node location letter elevation unvisited distance)
(define-record-printer (node n out)
  (format out "~C~C~S"
          (node-letter n)
          (if (node-unvisited n) #\_ #\#)
          (node-distance n))
  #;(format out "(~C @ (~S, ~S))"
          (node-letter n)
          (point-x (node-location n))
          (point-y (node-location n))))


(define (calc-elevation letter)
  (match letter
    [#\S (calc-elevation #\a)]
    [#\E (calc-elevation #\z)]
    [_ (- (char->integer letter) (char->integer #\a))]))


(define (create-node letter x y)
  (make-node (make-point x y)
             letter
             (calc-elevation letter)
             #t
             (if (equal? #\S letter) 0 999999999)))

(define (grid->flat-list grid)
  (flatten (map vector->list (vector->list grid))))

(define (parse-input input)
  (let* [(input (list->vector (map list->vector (map string->list input))))]
    (map-indexed-vector (lambda (row i)
                          (map-indexed-vector (lambda (square j)
                                                (create-node square i j))
                                              row))
                        input)))


(define (neighbors? a b)
  (let [(ax (point-x (node-location a)))
        (ay (point-y (node-location a)))
        (az (node-elevation a))
        (bx (point-x (node-location b)))
        (by (point-y (node-location b)))
        (bz (node-elevation b))]
    (and (= 1
            (+ (abs (- ax bx))
               (abs (- ay by))))
         (<= bz (+ 1 az)))))


(define (find-neighbors grid node)
  (filter (lambda (n) (neighbors? node n))
          (grid->flat-list grid)))


(define (calc-distance! grid)
  (define (find-next-unvisited)
    (let* [(all-nodes (grid->flat-list grid))
           (unvisited-nodes (filter node-unvisited all-nodes))]
      (if (null? unvisited-nodes)
          '()
          (car (sort unvisited-nodes
                               (lambda (a b) (< (node-distance a)
                                                (node-distance b))))))))

  (define (visit! node)
    (let [(neighbors (find-neighbors grid node))]
      (for-each (lambda (n)
                  (node-distance-set! n (min (node-distance n)
                                             (+ 1 (node-distance node)))))
                neighbors))
    (node-unvisited-set! node #f))

  (let loop [(current (find-next-unvisited))]
    (if (null? current)
        '()
        (begin
          (visit! current)
          ;; (vector-for-each print grid)
          ;; (newline)
          (loop (find-next-unvisited))))))


(define (get-endpoint grid)
  (car (filter (lambda (n) (equal? (node-letter n) #\E))
               (grid->flat-list grid))))

(let* [(input (call-with-input-file "./2022/day12/input.txt" read-lines))
       (grid (parse-input input))]
  (calc-distance! grid)
  ;; (newline)
  ;; (for-each print input)
  ;; (newline)
  ;; (vector-for-each print grid)
  (node-distance (get-endpoint grid)))
