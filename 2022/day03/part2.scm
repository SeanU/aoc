(import chicken.io)
(import chicken.string)
(import matchable)
(import srfi-1) ; lists
(import srfi-14) ; character sets

(define (windowed lst n)
  (let loop [(rest lst)
             (acc '())]
    (if (null? rest)
        acc
        (loop (drop rest n)
              (cons (take rest n) acc)))))

(define (char-priority c)
  (if (char-lower-case? c)
      (+ 1 (- (char->integer c) (char->integer #\a)))
      (+ 27 (- (char->integer c) (char->integer #\A)))))


(define (shared-chars xs)
  (define (find-shared-chars a b)
    (let [(haystack (string->char-set b))]
      (let loop [(needles (string->list a))
                (acc '())]
        (match needles
          [() (list->string acc)]
          [(needle . rest) (if (char-set-contains? haystack needle)
                                (loop rest (cons needle acc))
                                (loop rest acc))]))))
  (foldl find-shared-chars (car xs) (cdr xs)))

(define (find-badge-type xs)
  (string-ref (shared-chars xs) 0))

(let [(lines (call-with-input-file "./2022/day03/input.txt" read-lines))]
  (let* [(groups (windowed lines 3))
         (badges (map find-badge-type groups))
         (priorities (map char-priority badges))]
    (apply + priorities)))
