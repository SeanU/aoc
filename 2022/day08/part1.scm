(import chicken.io)
(import chicken.string)
(import math.base) ; math
(import srfi-1) ; lists
(import srfi-13) ; strings
(import srfi-196)

(define (parse-input lines)
  (define (parse-line line)
    (map string->number (string-chop line 1)))

  (let loop [(lines lines)
             (acc '())]
    (if (null? lines)
        acc
        (loop (cdr lines) (cons (parse-line (car lines)) acc)))))

(define (find-visibles grid)
  (define (is-visible? x y)
    (define (is-visible-north? x y)
      (if (eq? y 0)
          #t
          (let* [(column (map (lambda (row) (list-ref row x)) grid))
                 (tree (list-ref column y))
                 (further-north (take column y))]
            ;; (print x "," y ": " further-north)
            (every (lambda (h) (< h tree)) further-north))))

    (define (is-visible-south? x y)
      (if (eq? y (- (length grid) 1))
          #t
          (let* [(column (map (lambda (row) (list-ref row x)) grid))
                 (tree (list-ref column y))
                 (further-south (drop column (+ 1 y)))]
            ;; (print x "," y ": " tree "-" further-south)
            (every (lambda (h) (< h tree)) further-south))))

    (define (is-visible-west? x y)
      (if (eq? x 0)
          #t
          (let* [(row (list-ref grid y))
                 (tree (list-ref row x))
                 (further-west (take row x))]
            ;; (print x "," y ": " tree "-" further-west)
            (every (lambda (h) (< h tree)) further-west))))

    (define (is-visible-east? x y)
      (if (eq? x (- (length (car grid)) 1))
          #t
          (let* [(row (list-ref grid y))
                 (tree (list-ref row x))
                 (further-east (drop row (+ 1 x)))]
            ;; (print x "," y ": " tree "-" further-east)
            (every (lambda (h) (< h tree)) further-east))))

    (or (is-visible-north? x y)
        (is-visible-south? x y)
        (is-visible-west? x y)
        (is-visible-east? x y)))

  (let [(width (numeric-range 0 (length (car grid))))
        (height (numeric-range 0 (length grid)))]
    (range-map->list (lambda (y) (range-map->list (lambda (x) (is-visible? x y))
                                                  width))
                     height)))

(define (count-visibles visibles)
  (define (count-true lst)
    (count identity lst))

  (sum (map count-true visibles)))

(let* [(input (call-with-input-file "./2022/day08/input.txt" read-lines))
       (grid (parse-input input))
       (visibles (find-visibles grid))]
  ;; (newline)
  ;; (for-each print grid)
  ;; (newline)
  ;; (for-each print visibles)
  (count-visibles visibles))
