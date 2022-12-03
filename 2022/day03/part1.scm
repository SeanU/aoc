(import chicken.io)
(import chicken.string)
(import matchable)
(import srfi-14) ; character sets

(define (char-priority c)
  (if (char-lower-case? c)
      (+ 1 (- (char->integer c) (char->integer #\a)))
      (+ 27 (- (char->integer c) (char->integer #\A)))))

(define (shared-char a b)
  (let [(haystack (string->char-set b))]
    (let loop [(needles (string->list a))]
      (match needles
        [() 'nil]
        [(needle . rest) (if (char-set-contains? haystack needle)
                              needle
                              (loop rest))]))))

(define (prioritize line)
  (let* [(midpoint (/ (string-length line) 2))
         (comp1 (substring line 0 midpoint))
         (comp2 (substring line midpoint))]
    (char-priority (shared-char comp1 comp2))))

(let [(lines (call-with-input-file "./2022/day03/input.txt" read-lines))]
  (foldl + 0 (map prioritize lines)))
