(import chicken.sort)
(import chicken.io)
(import chicken.string)
(import srfi-1) ; lists
(import srfi-13) ; strings
(import math.base) ; math
(import srfi-71) ; receive multiple values from let

(define-record file name size)

(define-record directory name files subdirs size)
(define (print-dir dir)
  (print "(directory "
         (directory-name dir)
         " ("
         (string-join (map file-name (directory-files dir)) " ")
         ") "
         (directory-subdirs dir)
         " "
         (directory-size dir)
         " bytes)"))

(define (print-lines lst)
  (if (null? lst)
      (newline)
      (begin
        (print (car lst))
        (print-lines (cdr lst)))))


(define (cd cur-dir new-dir)
  (if (equal? ".." new-dir)
      (cdr cur-dir)
      (cons new-dir cur-dir)))


(define (parse-file str)
  (let [(parts (string-split str))]
    ;; (print "(file " (second parts) ")")
    (make-file (second parts) (string->number (first parts)))))


(define (list-dir dirname lines)
  (let loop [(lines lines)
             (files '())
             (subdirs '())]
    (if (null? lines)
        (values (make-directory dirname files subdirs 0) lines)
        (let [(entry (car lines))
              (rest (cdr lines))]
          (cond [(substring=? "$ " entry)
                 (values (make-directory dirname files subdirs 0) lines)]

                [(substring=? "dir " entry)
                 (loop rest
                       files
                       (cons (cd dirname (second (string-split entry))) subdirs))]

                [else
                 (loop rest (cons (parse-file entry) files) subdirs)])))))


(define (get-dir dirs name)
  (find (lambda (d) (equal? name (directory-name d))) dirs))

(define (calc-dir-sizes! dirs)
  (define (calc-size dir)
    (if (> (directory-size dir) 0)
        (directory-size dir)
        (let [(file-size (sum (map file-size (directory-files dir))))
              (subdir-size (sum (map (lambda (d) (calc-size (get-dir dirs d)))
                                     (directory-subdirs dir))))]
          (directory-size-set! dir (+ file-size subdir-size)))))
  (for-each calc-size dirs))

(define (walk-input lines)
  (let loop [(lines lines)
             (cur-dir '())
             (directories '())]
    ;; (newline)
    ;; (print "walk-input: ")
    (if (null? lines)
        directories
        (let [(next (car lines))
              (rest (cdr lines))]
          ;; (print "cur-dir: " cur-dir)
          ;; (print "cur-line: " next)
          (cond [(substring=? "$ cd /" next) (loop rest '("/") directories)]
                [(substring=? "$ cd" next) (loop rest
                                                 (cd cur-dir (substring next 5))
                                                 directories)]
                [(substring=? "$ ls" next)
                 (let [(dir rest (list-dir cur-dir rest))]
                   (loop rest cur-dir (cons dir directories)))])))))

(let* [(input (call-with-input-file "./2022/day07/input.txt" read-lines))
       (dirs (walk-input input))]
  (calc-dir-sizes! dirs)
  (for-each print-dir dirs)

  (let* [(used-space (directory-size (get-dir dirs '("/"))))
         (free-space (- 70000000 used-space))
         (needed-space (- 30000000 free-space))]
    (car (sort (filter (lambda (x) (>= x needed-space))
                       (map directory-size dirs)) <))))
