; buffmap.scm - Build variables from a buffer following predefined definition.
;
; Copyright (c) 2011 by Benelli Marco <mbenelli@yahoo.com>.
; All Right Reserved.
;
; These utilities builds functions to read and write variables.
; A typical use is in conjunction with a binary communication protocol (ie:
; modbus), the variables are read from a buffer and written using a function
; provided by client.
;
; TODO: This is actually a work in progress and need substantial testing.
; 

(##namespace ("buffmap#"))
(##include "~~lib/gambit#.scm")
(##namespace
 ("ctypes#" read-s8 write-s8 read-u16 write-u16 read-s16 write-s16
  read-u32 write-u32 read-s32 write-s32 read-u64 write-u64
  read-s64 write-s64 read-f32 read-f64
  native-endianess u8vector-reverse))


(define types '(bit byte u16 u32 f32 f64))

(define-type
  var
  id: F32C84CD-66FA-4E85-920E-13C4560DDA55
  constructor: %make-var
  name
  type
  offset
  bit-index)

(define (make-var name type offset #!optional (bit-index #f))
  (cond
    ((and (eq? type 'bit)
	  (integer? bit-index)
	  (and (>= bit-index 0)
	       (< bit-index 8))) (%make-var name type offset bit-index))
    ((not (memq type types)) (raise "Unknow type"))
    (else (%make-var name type offset #f))))

; Build an hash table of accessor to BUFFER with mapping defined by DATAMAP,
; where DATAMAP is a list of variables as defined by make-var.
;
; Usage: ((table-ref accessors 'v0))

(define (build-accessors buffer datamap
                         #!optional (endianess (native-endianess)))
  (let ((accessors (make-table)))
    (for-each
     (lambda (x)
       (let ((name (var-name x))
             (type (var-type x))
             (offset (var-offset x))
             (convert (if (eq? endianess (native-endianess))
                          values
                          u8vector-reverse)))
	 (cond
	   ((eq? type 'byte) (table-set! accessors name
                               (lambda ()
                                 (u8vector-ref buffer offset))))
	   ((eq? type 'bit) (table-set! accessors name
                              (lambda ()
                                (extract-bit-field
                                  1
                                  (var-bit-index x)
                                  (u8vector-ref buffer offset)))))
           ((eq? type 'u16) (table-set! accessor name
                              (lambda ()
                                (with-input-from-u8vector
                                  (convert
                                    (subu8vector buffer offset (+ offset 2)))
                                  (lambda () (read-u16))))))
           ((eq? type 'u32) (table-set! accessor name
                              (lambda ()
                                (with-input-from-u8vector
                                  (convert
                                    (subu8vector buffer offset (+ offset 4)))
                                  (lambda () (read-u32))))))
	   ((eq? type 'f32) (table-set! accessors name
                              (lambda ()
                                (with-input-from-u8vector
                                  (convert
                                    (subu8vector buffer offset (+ offset 4)))
                                  (lambda () (read-f32))))))
	   ((eq? type 'f64) (table-set! accessors name
                              (lambda ()
                                (with-input-from-u8vector
                                  (convert
                                    (subu8vector buffer offset (+ offset 8)))
                                  (lambda () (read-f64))))))
	   (else (raise "Unknown type")))))
     datamap)
    (lambda (k) ((table-ref accessors k)))))


; Build a table of mutators based on DATAMAP.
; FN is a function that consumes a type and an offset and produce a function
; that consume the value to be set.

(define (build-mutators datamap fn)
  (let ((mutators (make-table)))
    (for-each
      (lambda (x)
        (let ((name (car x))
              (type (cadr x))
              (offset (caddr x)))
          (table-set! mutators name (fn type offset))))
      datamap)
    (lambda (k v) ((table-ref mutators k) v))))

