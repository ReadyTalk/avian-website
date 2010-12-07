#!/usr/bin/csi -script

;; This is a simple text template engine written in Chicken.

;(require-extension debug) (debug #f)

(use posix)

(define template-directory (make-parameter "./templates"))
(define output-directory (make-parameter "./output"))

(define (escape-character) #\\)
(define (output-suffix) ".html")

(define definitions (make-parameter '()))
(define output-file (make-parameter ""))
(define wrote-something (make-parameter #f))

(define (make-tag symbols #!optional connector)
  (assert (pair? symbols))
  (assert (symbol? (car symbols)))
  (unless connector (set! connector " "))
  (let ([s (symbol->string (car symbols))])
    (if (null? (cdr symbols)) s (conc s connector (make-tag (cdr symbols))))))

(define (link-href data)
  (let loop ([data data]
             [symbols '()])
    (cond
     ((null? data)
      (conc (make-tag (reverse symbols) "_") (output-suffix)))

     ((symbol? (car data))
      (loop (cdr data) (cons (car data) symbols)))

     ((string? (car data))
      (car data))

     (else
      (error "unexpected item: " item)))))

(define (link-text data)
  (make-tag
   (let loop ([data data])
     (if (or (null? data)
             (string? (car data)))
       '()
       (cons (car data) (loop (cdr data)))))))

(define (all-space? string)
  (let ([length (string-length string)])
    (let loop ([index 0])
      (cond
       ((= index length) #t)       
       ((char-whitespace? (string-ref string index)) (loop (+ index 1)))
       (else #f)))))        

(define (write-string* string)
  (write-string string)
  (wrote-something #t))

(define (evaluate content)
  (let ([item (car content)]
        [following (cdr content)])
    (cond
     ((string? item)
      (if (or (wrote-something) (not (all-space? item)))
        (write-string* item)))
     
     ((pair? item)
      (assert (symbol? (car item)))
      (let ([x (car item)]
            [remainder (cdr item)])
        (cond
         ((eq? x 'define)
          (add-definition (make-tag remainder) following))

         ((eq? x 'loop)
          (assert (number? (car remainder)))
          (let loop ([n (car remainder)])
            (assert (>= n 0))
            (unless (= n 0)
              (until-end evaluate following)
              (loop (- n 1)))))

         ((eq? x 'link)
          (let ([href (link-href remainder)]
                [text (link-text remainder)])
            (write-string*
             (if (string=? href (notdir (output-file)))
               (conc "<div class=\"les\">" text "</div>")                     
               (conc "<div class=\"le\">"
                     "<a href=\"" href "\">" text "</a>"
                     "</div>")))))

         ((eq? x 'place)
          (until-end evaluate (get-definition (make-tag remainder))))

         ((eq? x 'template)
          (translate (conc (template-directory) "/" (car remainder))))

         ((eq? x 'include)
          (doinclude (car remainder)))

         ((eq? x 'size)
          (size (car remainder)))

         (else
          (error "invalid command: " x)))))

     (else
      (error "unexpected item: " item)))))
  

(define (add-definition name body)
  (definitions (cons (cons name body) (definitions))))

(define (get-definition name)
  (let ([definition (assoc name (definitions))])
    (if definition
      (cdr definition)
      (error "symbol '" name "' not defined in " (definitions)))))

(define (block-start? item)
  (and (pair? item)
       (symbol? (car item))
       (let ([x (car item)])
         (or (eq? x 'define)
             (eq? x 'loop)))))

(define (block-end? item)
  (and (pair? item)
       (symbol? (car item))
       (let ([x (car item)])
         (eq? x 'end))))

(define (until-end fn body)
  (let loop ([x body]
             [level 0])
    (cond
     ((null? x)
      '())

     ((block-start? (car x))
      (when (= level 0) (fn x))
      (loop (cdr x) (+ level 1)))

     ((block-end? (car x))
      (unless (= level 0)
        (loop (cdr x) (- level 1))))

     (else
      (when (= level 0) (fn x))
      (loop (cdr x) level)))))

(define (parse)
  (let loop ([c (peek-char)]
             [string '()]
             [escaped #f])
    (cond
     ((eof-object? c)
      (list (reverse-list->string string)))

     ((eq? c (escape-character))
      (read-char)
      (if escaped
        (loop (peek-char) (cons c string) #f)
        (loop (peek-char) string #t)))

     ((eq? c #\[)
      (if escaped
        (begin
          (read-char)
          (loop (peek-char) (cons c string) #f))
        (let ([x (cons (read) (loop (peek-char) '() #f))])
          (if (null? string) x (cons (reverse-list->string string) x)))))

     (else
      (read-char)
      (loop (peek-char)
            (cons c (if escaped (cons (escape-character) string) string))
            #f)))))

(define (parse-include)
  (let loop ([c (peek-char)]
             [string '()])
    (if (eof-object? c)
      (list (reverse-list->string string))
      (begin
        (read-char)
        (loop (peek-char) (cons c string))))))

(define (translate file)
  (let ([content (with-input-from-file file (lambda () (parse)))])
    (until-end evaluate content)))

(define (doinclude file)
  (let ([content (with-input-from-file file (lambda () (parse-include)))])
    (until-end evaluate content)))

(define (size file)
  (write-string*
   (number->string (inexact->exact (floor (/ (file-size file) 1024)))))
  (write-string* "K"))

(define (show-usage-and-exit)
  (display (conc "usage: translate.scm"
                 " [--template-directory dir]"
                 " [--output-directory dir]"
                 " input-file [input-file ...]"))
  (newline)
  (exit))

(define (notdir file)
  (let loop ([i (- (string-length file) 1)])
    (if (< i 0)
      file
      (if (eq? (string-ref file i) #\/)
        (substring file (+ i 1))
        (loop (- i 1))))))

(define (basename file)
  (let loop ([i (- (string-length file) 1)])
    (if (< i 0)
      file
      (if (eq? (string-ref file i) #\.)
        (substring file 0 i)
        (loop (- i 1))))))

(let ([input-files '()])
  (let loop ([args (command-line-arguments)])
    (unless (null? args)
      (let ([arg (car args)])
        (cond
         ((substring=? arg "-")
          (cond
           ((string=? arg "--template-directory")
            (template-directory (cadr args))
            (loop (cddr args)))

           ((string=? arg "--output-directory")
            (output-directory (cadr args))
            (loop (cddr args)))

           (else
            (print "bad argument: " arg)
            (show-usage-and-exit))))

         (else
          (set! input-files (cons arg input-files)))))))

  (if (null? input-files)
    (show-usage-and-exit)
    (let loop ([files input-files])
      (unless (null? files)
        (let ([file (car files)])
          (wrote-something #f)
          (output-file (conc (output-directory) "/"
                             (notdir (basename file))
                             (output-suffix)))
          (with-output-to-file (output-file)
            (lambda () (translate file))))
        (loop (cdr files))))))
