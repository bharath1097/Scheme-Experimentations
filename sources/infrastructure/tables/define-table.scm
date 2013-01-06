
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; table definition

(define-syntax define-table
  (er-macro-transformer
    (lambda (exp rename compare)

      ;; converts multiple strings to symbols
      (define (strings->symbols strings)
        (map string->symbol strings))
      
      ;; parses the expression
      (let* ((table-symbol (car (list-ref exp 1)))
             (table-name (cadr (list-ref exp 1)))
             (row-symbol (car (list-ref exp 2)))
             (columns-name (cdr (list-ref exp 2)))
             (columns-symbol (strings->symbols columns-name))
             (id-column-name (car columns-name))
             (id-column-symbol (string->symbol id-column-name))
             (value-columns-name (cdr columns-name))
             (value-columns-symbol (strings->symbols value-columns-name)))
        `(begin

          (declare (uses sql))

          ;; encapsulates a row
          (define-record ,row-symbol ,@columns-symbol)

          ;; inserts a row
          (define (,(symbol-append table-symbol '-insert) sql-connection ,row-symbol)
            (sql-execute sql-connection
              (string-append
                "INSERT INTO \"" ,table-name "\" ("
                ,(string-join
                  (map
                    (lambda (value-column-name)
                      (string-append "\"" value-column-name "\""))
                    value-columns-name)
                  ", ")
                ") VALUES ("
                ,(string-join
                  (map
                    (lambda (value-column-number)
                      (string-append "?" (number->string value-column-number)))
                    (iota (length value-columns-name) 1))
                  ", ")
                ");")
              ,@(map
                (lambda (value-column-symbol)
                  `(,(symbol-append row-symbol '- value-column-symbol) ,row-symbol))
                value-columns-symbol))
            (caar
              (sql-read sql-connection
                "SELECT last_insert_rowid();")))

          ;; selects a row by id
          (define (,(symbol-append table-symbol '-select-by- id-column-symbol) sql-connection ,id-column-symbol)
            (map
              (lambda (row)
                (apply ,(symbol-append 'make- row-symbol) row))
              (sql-read sql-connection
                ,(string-append
                  "SELECT * "
                  "FROM \"" table-name "\" "
                  "WHERE \"" id-column-name "\" = ?1;")
                ,id-column-symbol)))

          ;; selects all rows
          (define (,(symbol-append table-symbol '-select-all) sql-connection)
            (map
              (lambda (row)
                (apply ,(symbol-append 'make- row-symbol) row))
              (sql-read sql-connection
                ,(string-append
                  "SELECT * "
                  "FROM \"" table-name "\" "))))

          ;; updates a row
          (define (,(symbol-append table-symbol '-update) sql-connection ,row-symbol)
            (sql-execute sql-connection
              (string-append
                "UPDATE \"" ,table-name "\" "
                "SET "
                ,(string-join
                  (map
                    (lambda (value-column-index)
                      (let ((value-column-number (+ value-column-index 2)))
                        (string-append
                          "\"" (list-ref value-columns-name value-column-index) "\" = "
                          "?" (number->string value-column-number))))
                    (iota (length value-columns-name)))
                  ", ")
                " "
                "WHERE \"" ,id-column-name "\" = ?1;")
              ,@(map
                (lambda (column-symbol)
                  `(,(symbol-append row-symbol '- column-symbol) ,row-symbol))
                columns-symbol)))

          ;; deletes a row
          (define (,(symbol-append table-symbol '-delete) sql-connection ,row-symbol)
            (sql-execute sql-connection
              (string-append
                "DELETE "
                "FROM \"" ,table-name "\" "
                "WHERE \"" ,id-column-name "\" = ?1;")
              (,(symbol-append row-symbol '- id-column-symbol) ,row-symbol))))))))