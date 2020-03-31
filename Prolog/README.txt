816019 Zhou Jia Liang

•JSON_PARSE/2
json_parse restituisce Object, cioè l’oggetto JSON secondo la sintassi descritta nella specifica, ricevendo in input una stringa JSON

•CONVERT_SQ_IN_DQ/2
Converte tutti gli apici singoli in apici doppi.
Si suppone che le stringhe non possano contenere gli apici con cui sono racchiuse.

•CHECK_NUMBERS\1 (insieme a FIND_MORE_DIGIT/1, CHECK_NO_NUMBER\1, FIND_CLOSING_BRACE\1)
Controlla che nessun numero formato da cifre separate da spazi, cioè ogni numero JSON valido non può essere separato. Il controllo è necessario perché TERM_STRING/2 unisce due numeri separati da spazi.

•CATCH/3
E’ usato per gestire eventuali errori sorti durante l’esecuzione di term_string/2

•TERM_STRING/2
E’ standard. Converte una stringa/atomo in termine (quando è lecito) e viceversa.

•REPLACE_CODE/4
Sostituisce tutte le occorrenze del primo argomento con il secondo in una lista.

•EXTRACT_OBJECT/3
Unifica se il termine JSON ottenuto dalla stringa è un oggetto oppure un array.
Restituisce il tipo e nel caso di un oggetto, rimuove le parentesi graffe esterne, in modo da poter gestire dopo Members come una lista.
Con gli array non c’è bisogno perché sono già racchiusi tra quadre.

•GET_JSON_OBJECT/3
Ci dà l’oggetto o l’array a seconda del secondo parametro.
Due casi per l’oggetto per renderlo reversibile.
E’ reversibile grazie all’uso di VAR/NONVAR.

•ENCAPSULATE_IN_LIST/2
Racchiude Members (precedentemente rimosso dalle graffe) tra le quadre, in modo da poter essere gestito come una lista.

•EXTRACT_PAIRS/2
Otteniamo le coppie di Members chiamando FORMAT_PAIR/2.

•CHECK_AND_FORMAT_OBJECT/2
Restituisce VALUE della coppia.
Se è un oggetto a sua volta lo devo passare nuovamente a JSON_PARSE, nel caso vogliamo l’oggetto JSON, o a CONVERT_TO_JSON/2, nel caso vogliamo JSON standard.
E’ quindi reversibile.

•EXTRACT_ELEMENTS/2
Ottengo gli elementi dell’array parsati. E’ reversibile grazie a CHECK_AND_FORMAT_OBJECT/2.



•GET_JSON/3
ottengo Members oppure Elements

•GET_OBJECT_PAIRS/2
Ottengo Members in modo che Attribute e Value siano in una lista, in modo da poterli gestire piu facilmente.

•GET_RESULT/3
Ottengo il valore individuato da Fields.


•CONVERT_TO_JSON/2
Converto l’oggetto JSON in JSON Standard





