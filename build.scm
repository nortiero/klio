;; Copyright (c) 2010 Marco Benelli <mbenelli@yahoo.com> . All right reserved.
;;
;; Build file for klio.

(define dir "klio")

(define srcs
  '(
    prelude
    lists
    charsets
    strings
    irregex
    datetime
    rfc1123
    format
    vectors
    simple-sort
    shift-reset

    queue
    buffmap
    logger

    base64
    uri
    http-srv
    json

    input-parse
    ssax
    sxml

    kws
    http-auth
    sessions
    cgi

    modbus
    fetchwrite
    ))

(parameterize ((current-directory dir))
  (for-each
    (lambda (x)
      (let* ((name (symbol->string x))
             (src (string-append name ".scm"))
             (obj (string-append name ".o1")))
        (if (file-exists? obj)
            (delete-file obj))
        (print "Compiling " x " ... ")
        (compile-file src)
        (println "done.")))
    srcs))
