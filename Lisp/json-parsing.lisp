;;;; Zhou Jia Liang 816019

;;;; -*- Mode: Lisp -*-

;;;; json-parsing.lisp

;;; definisco liste vuote
(defparameter *emptyPair* '())


(defparameter *emptyString* '())


(defparameter *emptyMembers* '())


(defparameter *emptyValue* '())

;;; tiene conto della presenza o no di un certo simbolo
;;; per esempio la virgola, nella ricerca di un eventuale numero
;;; float
(defparameter *emptyStack* '())


(defparameter *emptyArray* '())


;;; estende Members
(defun extend-object-pairs (singlePair pairs)
  (append pairs (cons singlePair nil)))

;;; estende una singola coppia di MEMBERS
;;; la coppia � formata da 2 elementi: ATTRIBUTE e VALUE
(defun extend-single-pair (item &optional (singlePair *emptyPair*))
  (append singlePair (cons item nil)))

;;; estende l'oggetto che rapprensenta un numero
(defun extend-number (digit &optional (number '() ))
  (append number (cons digit nil)))

;;; aggiunge una virgola allo stack
;;; tiene traccia della virgola gi� trovata
(defun add-comma-to-stack (stack)
  (append (cons #\, nil) stack))

;;; estende ELEMENTS di un array
(defun extend-elements (element &optional (elements *emptyArray*))
  (append elements (cons element nil)))
  
;;; trasforma una stringa in una lista di caratteri
(defun string-to-list (string)
  (cond ((null string) nil)
        ((= (length string) 1) (cons (char string 0) nil))
        (T (cons (char string 0)
                 (string-to-list (subseq string 1))))))

                                
;;; trasforma una lista di caratteri in stringa
(defun list-to-string (lst)
    (format nil "~{~A~}" lst))


;;; trasforma una lista di caratteri (cifre, segni e virgola) in numero
(defun list-to-number (list)
  (if (contains-dot list)
      (parse-float (list-to-string list))
    (parse-integer (list-to-string list))))


;;; controlla se la lista rappresentante il numero contiene il 
;;; punto (virgola)
;;; se s� allora il numero non � intero
(defun contains-dot (list)
  (if (member #\. list)
      T
    NIL))


;;; salta i primi spazi consecutivi e le Newlines
(defun skip-spaces (list)   
  (cond ((null list)
         nil)
        
        ((or (eql (first list) #\Space)
             (eql (first list) #\Newline))
         (skip-spaces (rest list)))
        
        (t list)))


;;; is-digit
;;; verifica che il carattere digitInChar sia una cifra
(defun is-digit (digitInChar) 
  (or (eq digitInChar #\0) 
          (eq digitInChar #\1)
          (eq digitInChar #\2)
          (eq digitInChar #\3)
          (eq digitInChar #\4)
          (eq digitInChar #\5)
          (eq digitInChar #\6) 
          (eq digitInChar #\7)
          (eq digitInChar #\8)
          (eq digitInChar #\9)))
          


;;; get-number
;;; ottiene NUMBER da CHARS
(defun get-number (chars &optional (number *emptyValue*))
  (cond ((or (is-digit (first chars))
             (eql (first chars) #\-)
             (eql (first chars) #\+))
         (get-number (rest chars) (extend-number (first chars) number)))
              
        ((and (not (null number))
              (eql (first chars) #\.)
              (not (contains-dot number)))   
         ;; non deve contenere gi� un punto
         (get-number (rest chars) (extend-number (first chars) number)))
        
        ((and (not (null number))                      ; se NUMBER non � nullo
              (not (eql #\. (first (reverse chars))))) 
         ;; e se l'ultimo carattere non � il punto
         (cons (list-to-number number) chars))               
        ;; allora ritorno una CONS-CELL di NUMBER e CHARS
        
        (t 
         (error "ERROR: Not a correct number."))))



;;; format-object 
;;; aggiunge 'json-obj all'inizio della lista
(defun format-object (members)
  (append '(json-obj) members))



;;; format-array
;;; aggiunge 'json-array all'inizio della lista
(defun format-array (elements)
  (append '(json-array) elements))



;;; json-parse
(defun json-parse (JSONString)
  (let ((jsonAndChars (get-JSON (string-to-list JSONString))))  
    ;; GET-JSON restituisce una CONS-CELL con l'oggetto e i caratteri rimanenti
    (if (null (cdr jsonAndChars))   ; se non ci sono pi� caratteri da parsare
        (car jsonAndChars)          ; ritorno l'oggetto
      (error "ERROR: JSON Object syntax is not correct. ~S" (cdr jsonAndChars)  
             ;; altrimenti ci sono caratteri in pi�
             ))))


;;; restituisce una CONS-CELL con l'oggetto e i caratteri rimanenti
;;; l'input � una lista di caratteri
(defun get-JSON (jsonInChars)
  (cond ((eql (first jsonInChars) #\{)   ; se inizia con #\{ � un oggetto
         (let ((objectAndChars (get-JSON-Object (rest jsonInChars))))   
           ;; OBJECTANDCHARS � la CONS-CELL ritornata da GET-JSON-OBJECT
           (cons (format-object (car objectAndChars)) (cdr objectAndChars))))

        ((eql (first jsonInChars) #\[)   ; se inizia con #\[ � un array
         (let ((arrayAndChars (get-JSON-Array (rest jsonInChars))))   
           ;; ARRAYANDCHARS � la CONS-CELL ritornata da GET-JSON-ARRAY
           (cons (format-array (car arrayAndChars)) (cdr arrayAndChars))))

        ;; altrimenti errore
        (T (error "ERROR: ~S not a valid JSON object or array." 
                  (list-to-string jsonInChars)))
        ))
        

;;; get-JSON-Object
;;; ritorna una CONS-CELL con l'oggetto JSON individuato ed
;;; eventuali caratteri rimanenti, ancora da parsare
(defun get-JSON-Object (chars &optional (pairs *emptyMembers*))
  (let ((objectAndChars (get-pairs chars :pairs pairs)))  
    ;; GET-PAIRS ritorna una CONS-CELL 
    (cons (car objectAndChars) (cdr objectAndChars))))


;;; funzione a cui si appoggia GET-JSON-OBJECT per ottenere il valore di 
;;; ritorno
;;; PAIRS sono tutte le coppie trovate di OBJ
;;; SINGLE-PAIR � la coppia che si sta cercando, da aggiungere poi a 
;;; PAIRS
(defun get-pairs (chars &key (singlePair *emptyPair*) (pairs *emptyMembers*))
  (cond ((char= (first chars) #\Space)
         (get-pairs (skip-spaces chars) :singlePair singlePair :pairs pairs))  
        ;; salto gli spazi 

        ((and (eq (first chars) #\})    
              ;; se non ho pi� caratteri da leggere e mi rimane solo #\} nella 
              ;; lista
              (null singlePair))   ; e non ho una coppia incompleta
         (cons pairs (rest chars)))   
        ;; allora RITORNO la CONS-CELL con PAIRS e i caratteri rimanenti

        ((null singlePair)      
         ;; se non abbiamo ancora ATTRIBUTE, cio� quando PAIR � vuoto
         (get-pair-attribute chars :singlePair singlePair :pairs pairs))  
        ;; allora cerchiamo ATTRIBUTE
        
  
        ((and (not (null singlePair))    ; se abbiamo gi� attribute
              (char= (first chars) #\:))        
         ;; e abbiamo i due punti #\: dopo la stringa attribute
         (get-pair-value (rest chars) :singlePair singlePair :pairs pairs))  
        ;; allora cerco VALUE
        
        ;; altrimenti errore
        (t (error "Syntax error while parsing pairs"))))


  
;;; restituisce la stringa ATTRIBUTE di PAIR
(defun get-pair-attribute (chars &key (singlePair *emptyPair*) 
                                 (pairs *emptyMembers*) 
                                 (commaStack *emptyStack*))
  (cond ((or (and (null pairs)             ; se non ho ancora nessuna coppia
                  (char= (first chars) #\"))
             (and (not (null commaStack))  
                  ;; se ho gi� delle coppie devo avere una virgola che le separa
                  (char= (first chars) #\")))
         (let ((stringAndChars (get-string chars)))   
           ;; prendo la stringa e i caratteri rimanenti in una cons-cell
           (get-pairs (cdr stringAndChars)             
                      ;; prendo i caratteri rimanenti dalla cons-cell
                      :singlePair (extend-single-pair (car stringAndChars) 
                                                      singlePair)  
                      ;; aggiungo la stringa ATTRIBUTE a PAIR
                      :pairs pairs)))
             
        ((and (not (null pairs))  
              ;; se ho gi� delle coppie in pairs mi aspetto la virgola
              (null commaStack)
              (char= (first chars) #\,))
         (get-pair-attribute (skip-spaces (rest chars))
                             :singlePair singlePair 
                             :pairs pairs 
                             :commaStack (add-comma-to-stack commaStack)))  
        ;; tolgo la virgola e cerco la stringa
        
        (t (error "JSON syntax is not correct. ~S" chars) ; altrimenti errore di 
           ; sintassi
           )))
  
  

;;; ritorna la coppia di stringa e chars, cio� i caratteri ancora da parsare 
;;; dopo aver trovato la stringa  
(defun get-string (chars &optional (string *emptyString*))
  (cond ((and (char= #\" (first chars)) ; il primo carattere deve essere #\" per 
                                        ; essere una stringa
          (null string))            
         (get-string (rest chars) (append string (cons (first chars) nil))))  
        ;; inizio della stringa
          
        ((and (not (null string))   ; string non deve essere vuoto 
                                    ; (deve contenere almeno il carattere #\")
              (not (char= (first chars) #\"))) ; first-char deve essere diverso 
                                               ; da #\"
         (get-string (rest chars) (append string (cons (first chars) nil))))

        ((and (char= (first chars) #\")  ; STRING termina con #\"
              (not (null string)))
         (cons (list-to-string (rest string)) (rest chars)))  
        ;; RETURN qui. (rest string) --> per togliere il #\" iniziale
          
        (t (error "JSON syntax error: not a correct string. CHARS: ~S" chars))))



;;; ottengo VALUE di SINGLEPAIR
(defun get-pair-value (chars &key (singlePair *emptyPair*) 
                                  (pairs *emptyMembers*))
  (cond ((char= #\Space (first chars))
         (get-pair-value (rest chars) :singlePair singlePair :pairs pairs))  
        ;; salto gli spazi

        (t    
         (let ((valueAndChars (get-value chars)))    
           ;; prendo la stringa e i caratteri rimanenti in una cons-cell
           (get-pairs (cdr valueAndChars)             
                      ;; prendo i caratteri rimanenti dalla cons-cell
                      :pairs (extend-object-pairs (extend-single-pair 
                                                   (car valueAndChars) 
                                                   singlePair) pairs))))

        ))


;;; controlla di che tipo � VALUE e lo parsa con le 
;;; rispettive funzioni
(defun get-value (chars &optional (value *emptyValue*))
  (cond ((char= (first chars) #\")  ; se � stringa
         (get-string chars))

        ((or (is-digit (first chars))   ; se � numero
             (eql (first chars) #\-)
             (eql (first chars) #\+))
         (get-number chars))
        
        ;; altrimenti richiamo GET-JSON
        (t (get-JSON chars))))      ; se � object o array

  



;;; get-JSON-Array
(defun get-JSON-Array (chars &optional (elements *emptyArray*))
  (let ((elementsAndChars (get-elements chars :elements elements)))
    (cons (car elementsAndChars) (cdr elementsAndChars))))

;;; restiruisce ELEMENTS dell'array
(defun get-elements (chars &key (elements *emptyArray*) 
                           (commaStack *emptyStack*))
  (cond ((char= (first chars) #\Space)
         ;; salto gli spazi
         (get-elements (skip-spaces chars) :elements elements 
                       :commaStack commaStack))  

        ;; se trovo la virgola 
        ((and (char= (first chars) #\,) ; il primo char � la virgola
              (null commaStack)         ; non ho un'altra virgola nello stack
              (not (null elements)))    ; e ho altri elementi
         (get-elements (rest chars) :elements elements 
                       :commaStack (add-comma-to-stack commaStack)))

        ((char= (first chars) #\])   ; trovo la fine dell'array
         (cons elements (rest chars))) ; restituisco ELEMENTS e i CHARS 
  
        ((or (null elements)           ; se non ci sono ancora elementi
             (not (null commaStack)))  ; o se COMMASTACK contiene una virgola, 
         ;; cerco ELEMENT
         (let ((valueAndChars (get-value chars)))
           (get-elements (cdr valueAndChars) 
                         :elements (extend-elements (car valueAndChars)
                                                    elements))))  
        ;; altrimenti errore
        (t 
         (error "ERROR Uncorrect JSON syntax in array. " 
                elements chars))))


;;; controlla che sia un JSON-obj
(defun is-JSON-object (JSONObject)
  (eql (first JSONObject) 'json-obj))



;;; controlla che sia un JSON-array
(defun is-JSON-array (JSONObject)
  (eql (first JSONObject) 'json-array))



;;; restituisce RESULT individuato dai campi FIELDS
(defun json-get (JSONObject &rest fields)
  (if (null fields) ; se FIELDS � vuoto
      JSONObject ; ritorno JSONOBJECT stesso
    (get-fields-value JSONObject fields))) ; altrimenti cerco


;;; inizia a cercare 
(defun get-fields-value (JSONObject fields)
  (let ((field (first fields)))  ; FIELD � il primo valore di FIELDS
    (cond ((and (stringp field)  ; se FIELD � stringa
                (is-JSON-object JSONObject)) ; se � oggetto
           (let ((value (get-value-from-obj (rest JSONObject) field)))
             (if (null (rest fields))
                 value
               (get-fields-value value (rest fields)))))
          
          ((and (integerp field) ; se FIELD � numero
                (is-JSON-array JSONObject)) ; se � array
           ;; cerco l'elemento dell'array
           (let ((value (get-array-elem (rest JSONObject) field)))
             (if (null (rest fields))
                 value
               (get-fields-value value (rest fields)))))
          
          ;; altrimenti errore
          (t 
           (error "ERROR: wrong number of fields or incorrect field type.")))))



;;; cerca la coppia con lo stesso ATTRIBUTE e restituisce 
;;; VALUE
(defun get-value-from-obj (pairs attribute)
  (cond ((null pairs) ; se non ho pi� coppie o se non l'ho trovato
         (error "ERRORE: No result found for ~S field" attribute))
        
        ((string= (first (first pairs)) attribute)
         (second (first pairs)))
        
        (t 
         (get-value-from-obj (rest pairs) attribute))))


;;; cerco ELEMENT dell'array
(defun get-array-elem (elements index)
  (if (< index (list-length elements))
      (nth index elements)   ; NTH � standard
    (error "ERROR: Array index out of bounds.")))
    
            
;;; aggiunge la virgola alla stringa
(defun add-comma (string)
  (concatenate 'string string ", "))  ; CONCATENATE � standard

;;; aggiunge ':' alla stringa
(defun add-colon (string)
  (concatenate 'string string ":"))

;;; aggiunge PAIR o ELEMENT a JSONOBJ (obj o array)
(defun add-item (jsonObj item)  ; ITEM � un PAIR o un ELEMENT
  (concatenate 'string jsonObj item))
  
;;; aggiunge le graffe 
(defun add-braces (jsonObj)
  (concatenate 'string "{" jsonObj "}"))

;;; aggiunge le quadre
(defun add-brackets (jsonObj)
  (concatenate 'string "[" jsonObj "]"))

;;; aggiunge le virgolette
(defun add-quotes (string)
  (concatenate 'string "\"" string "\""))


;;; converte JSON standard in un oggetto JSON
;;; usato da JSON-LOAD
(defun convert-to-JSON (JSONObject)
  (cond ((is-JSON-object JSONObject) ; se � oggetto
         ;; converte l'oggetto e gli aggiunge poi le graffe
         (add-braces (convert-object (rest JSONObject))))
        
        ((is-JSON-array JSONObject) ; se � array
         ;; converte l'array e gli aggiunge le quadre
         (add-brackets (convert-array (rest JSONObject))))
        
        ;; altrimenti errore
        (t
         (error "ERROR: Not an object or an array."))

        ))

;;; converte l'oggetto JSON in JSON standard
(defun convert-object (pairs &key (obj "") (commaStack *emptyStack*))
  (cond ((null pairs)   ; se non ho pi� coppie ritorno l'oggetto OBJ
         obj)

        ((and (not (string= obj ""))    ; se l'oggetto non � vuoto
              (not (null pairs))        ; se ci sono ancora altre coppie
              (null commaStack))  ; e se non ho ancora la virgola
         (convert-object pairs 
                         :obj (add-comma obj)  ; aggiungo la virgola dopo 
                                               ; la coppia trovata
                         :commaStack (add-comma-to-stack commaStack)))
        
        (t                              ; altrimenti 
         ;; cerco la coppia
         (convert-object (rest pairs) 
                         :obj (add-item obj (convert-pair (first pairs)))))  
                       
        ))

;;; converto la coppia in JSON standard
(defun convert-pair (pair &optional (pairInString ""))
  (if (string= pairInString "")
      (convert-pair (second pair) (add-item pairInString (add-quotes 
                                                          (first pair))))
    ;; PAIR ora contiene VALUE
    (add-item (add-colon pairInString) (convert-value pair))))  



(defun convert-value (value)
  (cond ((stringp value)     ; se � stringa
         (add-quotes value)) 
        
        ((numberp value)     ; se � un numero
         (write-to-string value)) ; WRITE-TO-STRING � standard

        (t
         (convert-to-JSON value))))

;;; converte l'array da oggetto JSON in JSON standard
(defun convert-array (elements &key (array "") (commaStack *emptyStack*))
  (cond ((null elements)
         array)
        
        ((and (not (string= array ""))    ; se l'array non � vuoto
              (not (null elements))        ; se ci sono ancora altri elementi
              (null commaStack))  ; e se non ho ancora la virgola
         (convert-array elements 
                        :array (add-comma array) 
                        ;; aggiungo la virgola dopo la coppia trovata
                        :commaStack (add-comma-to-stack commaStack)))

        (t                              ; altrimenti 
         (convert-array (rest elements) 
                        :array (add-item array (convert-value 
                                                (first elements)))))

        ))

;;; legge il contenuto del file in una stringa 
;;; per poi essere passata a JSON-PARSE
(defun json-load (fileName)
  (with-open-file (in fileName 
                      :direction :input
                      :if-does-not-exist :error)
    (json-parse (read-string-from in))))
      


;; legge carattere per carattere il file di testo
(defun read-string-from (input-stream)
  (let ((stringa (read-char input-stream nil 'eof)))
    (cond ((equal stringa 'eof)
           "")
          (T
           (string-append stringa (read-string-from input-stream))))))
   
;;; scrive l'oggeto JSON convertito il JSON standard sul file specificato
;;; se tale file non esiste viene creato
(defun json-write (JSONObj fileName)
  (with-open-file (out fileName 
                       :direction :output
                       :if-exists :supersede
                       :if-does-not-exist :create)
    (format out (convert-to-JSON JSONObj))) 
  fileName)
      
     
                                                   
                                            
                                 
;;;; end-of-file --- json-parsing.lisp ---
        
                                                                                
         
              
  




  
                                                                                                                                                     



  
                                      
      

                                                                                
         
              
  




  
                                                                                                                                                     



  
                                      
      
