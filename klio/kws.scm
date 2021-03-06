;; kws.scm - Klio web server
;;
;; Copyright (c) 2010 by Marco Benelli <mbenelli@yahoo.com>
;; All Rights Reserved.

(##namespace ("kws#"))
(##include "~~lib/gambit#.scm")
(##include "base64#.scm")
(##include "uri#.scm")
(##include "http-srv#.scm")
(##include "prelude#.scm")
(##namespace
  ("rfc1123#" time->string))

(declare
  (standard-bindings)
  (extended-bindings)
  (block))


(define *server-root* (make-parameter (current-directory)))

(define input-file-buffer-size 4096)

(define (static-content path)
  (let ((p (open-input-file `(path: ,path buffering: #f)))
        (buff (make-u8vector input-file-buffer-size)))
    (let loop ((n (read-subu8vector buff 0 input-file-buffer-size p)))
      (if (zero? n)
          (close-input-port p)
          (begin
            (write-subu8vector buff 0 n)
            (loop (read-subu8vector buff 0 input-file-buffer-size p)))))))

;;;

(define (mime path)
  (or
    (and-let* ((mimetype (assoc (path-extension path)
                           '((".html" . "text/html")
                             (".htm"  . "text/html")
                             (".css"  . "text/css")
                             (".txt"  . "text/plain")
                             (""      . "text/plain")
                             (".js"   . "application/javascript")
                             (".json" . "application/json")
                             (".bmp"  . "image/bmp")
                             (".ico"  . "image/ico")
                             (".jpg"  . "image/jpg")
                             (".jpeg" . "image/jpeg")
                             (".png"  . "image/png")
                             (".svg"  . "image/svg+xml")
                             (".svgz" . "image/svg+xml")))))
      (cdr mimetype))
    "text/plain"))


(define (last-modified path)
  (time->string
    (file-info-last-modification-time (file-info path))))


(define get-static
  (lambda ()
    (with-exception-catcher
      (lambda (e)
        (if (no-such-file-or-directory-exception? e)
            (not-found)))
      (lambda ()
        (let ((path (string-append
                      (path-strip-trailing-directory-separator (*server-root*))
                      (uri-path (request-uri (current-request))))))
          (reply-unbuffered (lambda () (static-content path))
	    `(("Content-Type" . ,(mime path))
              ("Content-Length" . ,(file-info-size (file-info path)))
	      ("Last-Modified" . ,(last-modified path)))
            ))))))


(define get-file
  (lambda (path attributes)
    (with-exception-catcher
      (lambda (e)
	(if (no-such-file-or-directory-exception? e)
	    (not-found)))
      (lambda ()
	(let ((p (string-append
	           (path-strip-trailing-directory-separator (*server-root*))
		   path)))
	  (reply (lambda () (static-content p))
            (append `(("Content-Type" . ,(mime p))
                      ("Last-Modified" . ,(last-modified p)))
              attributes)))))))


(define (kws #!key
          (port-number 8000)
          (multithread #f)
          (dispatcher #f)
          (server-root (*server-root*)))

  (println port: (current-error-port)
    "\nStarting Klio Web Server\n\n"
    "Port: " port-number #\newline
    "Server root: " server-root #\newline
    "Multithreading: " (if multithread "enabled" "disabled") #\newline)
  (force-output (current-error-port))

  (parameterize ((*server-root* server-root))
                     (http-server-start!
                       (make-http-server
                         port-number: port-number
                         threaded?: multithread
                         GET: (or dispatcher get-static)
                         HEAD: (or dispatcher get-static)
                         POST: (or dispatcher get-static)))))

