816019 Zhou JiaLiang 


•JSON-PARSE prende in input una stringa e chiama subito GET-JSON, il quale restituisce una CONS-CELL, assegnata con “let” a JSONANDCHARS.
JSONANDCHARS contiene l’oggetto JSON parsato (obj/array) e 
la lista dei caratteri rimanenti. Se non ci sono più caratteri allora la sintassi è corretta, perché non ci sono caratteri in più dopo l’ultimo “}” o “]”.

•JSON-GET è chiamato da JSON-PARSE per analizzare la lista di caratteri.
Restituisce la CONS-CELL contenente o l’oggetto o l’array, e i caratteri rimanenti, altrimenti lancia un errore se non trova niente.

•GET-JSON-OBJECT ritorna una CONS-CELL, contente l’oggetto parsato e i caratteri rimanenti.
Chiama GET-PAIRS per ottenere MEMBERS.
GET-PAIRS tiene traccia delle coppie già trovate in PAIRS e della coppia che si sta cercando in SINGLEPAIR, entrambi inizializzati con la lista vuota.
Quando SINGLEPAIR è vuoto devo cercare prima la stringa ATTRIBUTE e poi VALUE.
GET-PAIR-ATTRIBUTE una volta trovata la stringa richiama nuovamente GET-PAIRS, che stavolta cerca VALUE con GET-PAIR-VALUE.
Quest’ultima funziona richiama anch’essa GET-PAIRS quando trova VALUE, tramite GET-VALUE.
GET-VALUE controlla il tipo dell’oggetto, e nel caso di array o obj richima nuovamente GET-JSON.

•GET-JSON-ARRAY restituisce la CONS-CELL contenente gli ELEMENTS e i caratteri rimanenti.
Usa GET-ELEMENTS per farlo, il quale salva gli elementi già trovati in ELEMENTS.


•JSON-GET trova il valore individuato dai campi FIELDS.
Usa GET-VALUE-FROM-OBJ se dobbiamo cercare una coppia in un oggetto, oppure GET-ARRAY-ELEM se stiamo cercando l’elemento i-esimo in un array.

•JSON-LOAD usa CONVERT-TO-JSON per convertire JSON standard letto da un file in oggetto JSON definito dalla specifica.
CONVERT-TO-JSON usa CONVERT-OBJECT se abbiamo un oggetto in JSON standard da convertire, altrimenti CONVERT-ARRAY per gli array in JSON standard.

