;;;
;;;; JSON reader and writer
;;;
;; Originally developed by:
;; Dominique Boucher (SchemeWay) <schemeway at sympatico.ca>
;; @created   "Wed Feb 14 15:30:07 EST 2007"
;; @copyright "NuEcho Inc."
;;
;; Revised by Marco Benelli
;;


;;;
;;;; Platform-specific declarations
;;;

(##namespace ("json#"))
(##include "~~lib/gambit#.scm")
(##include "json#.scm")

(declare
  (standard-bindings)
  (extended-bindings)
  (block)
  (not safe))

;;;
;;;; --
;;;; Some constants
;;;


(define json-null (vector 'json-null))

(define (json-null? obj)
  (eq? obj json-null))



;;;
;;;; --
;;;; JSON object constructor
;;;


;; Converts an a-list to a JSON object (a Scheme table)
;; TODO: check values and keys
(define json-object list->table)


;;;
;;;; --
;;;; JSON reader
;;;


(define (json-read #!optional (port (current-input-port)))

  (define lookahead (peek-char port))

  (define (consume)
    (read-char port)
    (set! lookahead (peek-char port)))

  (define (match-char ch message #!optional (consume? #t))
    (if (not (eqv? lookahead ch))
        (error message)
        (if consume?
            (consume))))

  (define (skip-ws)
    (if (char-whitespace? lookahead)
        (begin
          (consume)
          (skip-ws))))


  (define (read-object)
    (let ((object (make-table)))
      (match-char #\{ "object must begin with a '{'")
      (skip-ws)
      (if (eq? lookahead #\})
          (begin
            (consume)
            object)
          (let loop ()
            (let ((key (read-value)))
              (if (not (string? key))
                  (error "key must be a string"))
              (skip-ws)
              (match-char #\: "key must be following by ':'")
              (let ((value (read-value)))
                (table-set! object key value)
                (skip-ws)
                (if (eq? lookahead #\,)
                    (begin
                      (consume)
                      (loop))
                    (begin
                      (match-char #\} "object must be terminated by '}'")
                      object))))))))

  (define (read-array)
    (match-char #\[ "array must begin with a '['")
    (skip-ws)
    (if (eq? lookahead #\])
        (begin (consume) '())
        (let loop ((elements (list (read-value))))
          (skip-ws)
          (cond ((eq? lookahead #\])
                 (consume)
                 (reverse elements))
                ((eq? lookahead #\,)
                 (consume)
                 (loop (cons (read-value) elements)))
                (else
                 (raise 'invalid-json-array))))))

  (define (read-string)
    (match-char #\" "string must begin with a double quote" #f)
    (let ((str (read port)))
      (set! lookahead (peek-char port))
      str))

  (define (read-number)
    (let ((op (open-output-string)))
      ;; optional minus sign
      (if (eq? lookahead #\-)
          (begin
            (consume)
            (write-char #\- op)))
      ;; integral part
      (cond ((eq? lookahead #\0)
             (consume)
             (write-char #\0 op))
            ((and (char? lookahead) (char-numeric? lookahead))
             (let loop ()
               (write-char lookahead op)
               (consume)
               (if (and (char? lookahead) (char-numeric? lookahead))
                   (loop))))
            (else
             (raise 'invalid-json-number)))
      (if (eq? lookahead #\.)
          (begin
            (write-char #\. op)
            (consume)
            (if (and (char? lookahead) (char-numeric? lookahead))
                (let loop ()
                  (write-char lookahead op)
                  (consume)
                  (if (and (char? lookahead) (char-numeric? lookahead))
                      (loop)
                      ;;  e | E
                      (if (or (eq? lookahead #\e) (eq? lookahead #\E))
                          (begin
                            (write-char lookahead op)
                            (consume)
                            ;; [ + | - ]
                            (if (or (eq? lookahead #\+) (eq? lookahead #\-))
                                (begin
                                  (write-char lookahead op)
                                  (consume)))
                            ;; digit+
                            (if (and (char? lookahead) (char-numeric? lookahead))
                                (let loop ()
                                  (write-char lookahead op)
                                  (consume)
                                  (if (and (char? lookahead) (char-numeric? lookahead))
                                      (loop)))
                                (raise 'invalid-json-number))))))
                (raise 'invalid-json-number))))
      (string->number (get-output-string op))))

  (define (read-constant)
    (let loop ((chars '()))
      (if (and (not (eof-object? lookahead))
               (char-alphabetic? lookahead))
          (let ((ch lookahead))
            (consume)
            (loop (cons ch chars)))
          (let ((str (list->string (reverse chars))))
            (cond ((string=? str "false") #f)
                  ((string=? str "true")  #t)
                  ((string=? str "null")  json-null)
                  (else                   (raise 'invalid-json-constant)))))))

  (define (read-value)
    (skip-ws)
    (cond ((eof-object? lookahead)
           (raise 'unexpected-eof))
          ((char=? lookahead #\{)
           (read-object))
          ((char=? lookahead #\[)
           (read-array))
          ((char=? lookahead #\")
           (read-string))
          ((or (char-numeric? lookahead) (char=? lookahead #\-))
           (read-number))
          ((char-alphabetic? lookahead)
           (read-constant))
          (else
           (raise 'json-syntax-error))))

  (read-value))


;;;
;;;; --
;;;; JSON writer
;;;


(define (json-write value #!optional (port (current-output-port)))

  (define (write-object object)
    (write-char #\{ port)
    (let ((first? #t))
      (table-for-each (lambda (key value)
                        (let ((key (if (symbol? key)
                                     (symbol->string key)
                                     key)))
                          (if (not (string? key))
                            (raise 'invalid-json-object))
                          (if (not first?)
                            (display ", " port))
                          (write key port)
                          (display ": ")
                          (write-value value)
                          (set! first? #f)))
                        object))
    (write-char #\} port))

  (define (write-array elements)
    (write-char #\[)
    (let ((first? #t))
      (for-each (lambda (value)
                  (if (not first?)
                      (display ", " port))
                  (write-value value)
                  (set! first? #f))
                elements))
    (write-char #\]))

  (define (write-string str)
    (display #\" port)
    (display str port)
    (display #\" port))

  (define (write-number num)
    (let ((str (number->string (exact->inexact num))))
      (cond
	((char=? (string-ref str 0) #\.)
	 (display "0" port)
	 (display str port))
	((and (char=? (string-ref str 0) #\-)
	      (char=? (string-ref str 1) #\.))
	 (display "-0" port)
	 (display (substring str 1 (string-length str)) port))
	((char=? (string-ref str (- (string-length str) 1)) #\.)
	 (display (substring str 0 (- (string-length str) 1)) port))
	(else
	 (display str port)))))

  (define (write-constant value)
    (cond ((eq? value #f)
           (display "false" port))
          ((eq? value #t)
           (display "true" port))
          ((symbol? value)
           (write-string (symbol->string value)))
          ((json-null? value)
           (display "null" port))
          (else
           (pp value)
           (raise 'invalid-json-object))))

  (define (write-value value)
    (cond ((table? value)
           (write-object value))
          ((list? value)
           (write-array value))
          ((real? value)
           (write-number value))
          ((string? value)
           (write-string value))
          (else
           (write-constant value))))

  (write-value value))


