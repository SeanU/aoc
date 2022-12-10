(import chicken.io)
(import chicken.string)
(import math.base) ; math
(import srfi-1) ; lists
(import srfi-13) ; strings
(import srfi-196) ; ranges

(define (parse-input lines)
  (define (parse-line line)
    (map string->number (string-chop line 1)))

  (let loop [(lines lines)
             (acc '())]
    (if (null? lines)
        (reverse acc)
        (loop (cdr lines) (cons (parse-line (car lines)) acc)))))

(define (range-cartesian-product a b)
  (range->list
   (apply range-append
          (range-map->list (lambda (x)
                             (range-map (lambda (y) (vector x y))
                                        b))
                           a))))

(define (coord-x coord)
  (vector-ref coord 0))

(define (coord-y coord)
  (vector-ref coord 1))

(define (move coord offset)
  (vector (+ (coord-x coord) (coord-x offset))
          (+ (coord-y coord) (coord-y offset))))

(define (find-best-tree grid)

  (let [(width (length (car grid)))
        (height (length grid))]

    (define (at-edge? coordinate)
      (let [(x (coord-x coordinate))
            (y (coord-y coordinate))]
        (or (< x 0)
            (< y 0)
            (>= x width)
            (>= y height))))

    (define (get-tree-height coordinate)
      (if (at-edge? coordinate)
          99
          (list-ref (list-ref grid
                              (coord-y coordinate))
                    (coord-x coordinate))))


    (define (score-tree coordinate)
      (let [(tree-height (get-tree-height coordinate))]
        ;; (newline)
        ;; (print "candidate tree " coordinate " height: " tree-height)

        (define (score-direction dir)
          (define (print-return x)
            ;; (print "      returning " x)
            x)
          ;; (print "  checking direction:" dir)

          (let loop [(coord (move coordinate dir))
                     (acc 0)]
            (let* [(is-at-edge (at-edge? coord))
                   (cur-height (get-tree-height coord))
                   (taller (>= cur-height tree-height))]
              ;; (print "    visiting " coord
              ;;        " (acc: " acc
              ;;        " edge?: " is-at-edge
              ;;        " height: " cur-height ")")
              (cond [is-at-edge (print-return acc)]
                    [taller (print-return (+ acc 1))]
                    [else (loop (move coord dir) (+ acc 1))]))))

        (* (score-direction #(-1  0))
           (score-direction #( 1  0))
           (score-direction #( 0 -1))
           (score-direction #( 0  1)))))

    (let* [(xs (numeric-range 1 (- width 1)))
           (ys (numeric-range 1 (- height 1)))
           (candidates (range-cartesian-product xs ys))
           ;; (candidates (list (vector 2 1)))
           (scores (map score-tree candidates))]
      (apply max scores))))

(let* [(input (call-with-input-file "./2022/day08/input.txt" read-lines))
       (grid (parse-input input))]
  ;; (newline)
  ;; (for-each print grid)
  ;; (newline)
  ;; (for-each print visibles)
  (find-best-tree grid))
