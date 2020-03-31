%%%% ---- Zhou Jia Liang 816019 ----

%%%% -*- Mode: Prolog -*-

%%%% json-parsing.pl

%%% ---- json_parse/2 ----
json_parse(JSONString, Object) :-
    convert_SQ_in_DQ(JSONString, CorrectedJSONString),

    %% controllo dei numeri (non ci deve essere spazio tra 2 numeri)
    %% altrimenti term_string/2 li unisce
    string_chars(CorrectedJSONString, Chars),
    check_numbers(Chars),

    %% se JSONTerm non è termine, ritorna false
    %% catch/3 è standard
    %% term_string/2 è standard
    %% term_string/2 converte sia atomi che stringhe in termini
    catch(term_string(JSONTerm, CorrectedJSONString), _, false),
    extract_object(JSONTerm, Type, JSONObject),
    get_JSON_object(JSONObject, Type, Object).


%%% check_numbers
check_numbers([]).

check_numbers([Char | Rest]) :-
    is_digit(Char),  % is_digit/1 è standard
    !,
    find_more_digit(Rest).

check_numbers([Char | Rest]) :-
    Char \= '\"',
    !,
    check_numbers(Rest).

check_numbers([Char | Rest]) :-
    Char = '\"',
    find_closing_brace(Rest).

%%% find_more_digit/1
%%% trova altre cifre se ci sono
find_more_digit([C | Rest]) :-
    is_digit(C),
    !,
    find_more_digit(Rest).

%%% se trovo lo spazio mi assicuro che non ci sia
%%% nessun'altra cifra dopo, ma un qualsiasi altro carattere
find_more_digit([C | Rest]) :-
    C = '\s',
    !,
    check_no_number(Rest).


find_more_digit([_ | Rest]) :-
    check_numbers(Rest).


check_no_number([C | Rest]) :-
    C = '\s',
    check_no_number(Rest).


check_no_number([C | Rest]) :-
    not(is_digit(C)),
    check_numbers(Rest).


find_closing_brace([C | Rest]) :-
    C \= '\"',
    !,
    find_closing_brace(Rest).

find_closing_brace([_ | Rest]):-
    check_numbers(Rest).


%%% convert_SQ_in_DQ/2
%%% converte gli apici singoli in apici doppi
    convert_SQ_in_DQ(String, NewString) :-
    string_codes(String, Codes),
    replace_code(39, 34, Codes, NewCodes),
    string_codes(NewString, NewCodes).


%%% replace_code/4
%%% sostituisce tutte le occorrenze di OLD con NEW
replace_code(_, _, [], []).

replace_code(Old, New, [Old | MoreCodes], [New | MoreNewCodes]) :-
    !,
    replace_code(Old, New, MoreCodes, MoreNewCodes).

replace_code(Old, New, [Code | MoreCodes], [Code | MoreNewCodes]) :-
    Code \= Old,
    replace_code(Old, New, MoreCodes, MoreNewCodes).






%%% extract_object/3
%%% unifica con il tipo di oggeto (object o array)
extract_object({}, object, []).                 % se JSONTerm è vuoto

extract_object({Members}, object, Members).     % Se JSONTerm è 'oggetto'
%% rimuovo le graffe per poter gestire Members come una lista

extract_object(Elements, array, Elements) :-    % Se JSONTerm è 'array'
    is_list(Elements).






%%% get_JSON_object/3
get_JSON_object(Members, object, json_obj(Pairs)) :-   % JSONObject è un oggetto
    nonvar(Members),
    !,
    encapsulate_in_list(Members, MembersInList),  % perchè Members è racchiuso
                                                  % tra tonde se non è vuoto
    extract_pairs(MembersInList, Pairs).

get_JSON_object(Members, object, json_obj(Pairs)) :-    % se vogliamo Members
                                                        % da Pairs
    var(Members),
    !,
    extract_pairs(Members, Pairs).

get_JSON_object(Elements, array, json_array(Array)) :-   % JSONObject è un array
    extract_elements(Elements, Array).



%%% encapsulate_in/2
%%% incapsula l'oggetto, in termine, tra parentesi quadre
encapsulate_in_list([], []).    % per l'oggetto JSON vuoto

%%% rimuove le tonde automaticamente passando da termine a stringa
encapsulate_in_list(Object, EncapsulatedObject) :-
    term_string(Object, String),
    atom_chars(String, Chars),
    append(['['], Chars, TempObject),
    append(TempObject, [']'], ObjectInChars),
    atom_chars(ObjectInTerm, ObjectInChars),
    term_string(EncapsulatedObject, ObjectInTerm).



%%% extract_pairs/2
extract_pairs([], []).

extract_pairs([Pair | MorePairs], [FormattedPair | MoreFormattedPairs]) :-
    format_pair(Pair, FormattedPair),
    extract_pairs(MorePairs, MoreFormattedPairs).



%%% format_pair/2
format_pair(Attribute : Value, (Attribute, FormattedValue)) :-
    %% se è variabile allora sto ottenendo Pair da FormattedPair
    is_prolog_string(Attribute),
    check_and_format_object(Value, FormattedValue).



%%% is_prolog_string/1
is_prolog_string(String) :-
    string(String).




%%% check_and_format_object/2
check_and_format_object(String, String) :-
    is_prolog_string(String),
    !.

check_and_format_object(Value, Value) :-
    number(Value),
    !.

check_and_format_object(Value, FormattedValue) :-    % ottengo FormattedValue
    var(FormattedValue),
    !,
    term_string(Value, ValueInString),
    json_parse(ValueInString, FormattedValue).

check_and_format_object(Value, FormattedValue) :-    % ottengo Value
    var(Value),
    convert_to_JSON(FormattedValue, Value).



%%% extract_elements/2
%%% ottengo gli elementi dell'array
extract_elements([], []).

extract_elements([Element | MoreElements], [FormattedElement | MoreFormElem]) :-
    check_and_format_object(Element, FormattedElement),
    extract_elements(MoreElements, MoreFormElem).








%%% ---- json_get/3 ----
%%% restituisce il valore identificato dalla sequenza di campi o da
%%% un campo singolo
json_get(JSON_obj, [], JSON_obj).

json_get(JSON_obj, Fields, Result) :-
    get_JSON(JSON_obj, JSON),
    get_result(JSON, Fields, Result).






get_JSON(json_array(Elements), Elements).

get_JSON(json_obj(Members), Pairs) :-
    get_object_pairs(Members, Pairs).



get_object_pairs([], []).

get_object_pairs([(Attr, Value) | Members], [[Attr, Value] | MoreMembers]) :-
    get_object_pairs(Members, MoreMembers).






%%% se JSON è Members con coppie allora Field è String
get_result(JSON, Fields, Result) :-
    get_first_field(Fields, FirstField),
    is_prolog_string(FirstField),
    !,
    get_value_from_pair(JSON, Fields, Result).

%% se abiamo un array con Elements allora Field è Number
get_result(Elements, Fields, Result) :-
    get_first_field(Fields, FirstField),
    number(FirstField),
    get_element_from_array(Elements, Fields, Result).



get_value_from_pair([[Field, Value] | _], [Field | MoreFields], Result) :-
    %!,
    find_final_result(Value, MoreFields, Result).

get_value_from_pair([[PairField, _] | MorePairs], [Field | MoreFields], Res) :-
    PairField \= Field,
    get_value_from_pair(MorePairs, [Field | MoreFields], Res).



%%% caso base: quando non ho più valori in Fields ho trovato Result
find_final_result(Value, [], Value).

%% se value non è stringa allora è JSON_obj, quindi richiamo json_get/3
%% con Value e i campi rimanenti
find_final_result(JSON_obj, Fields, Result) :-
    json_get(JSON_obj, Fields, Result).



%%% get_first_field/2
get_first_field([Field | _], Field).



%%% get_element_from_array/3
get_element_from_array([Element | _], [0 | Fields], Result) :-
    find_final_result(Element, Fields, Result).

get_element_from_array([_ | MoreElements], [Index | Fields], Result) :-
    NewIndex is Index - 1,
    get_element_from_array(MoreElements, [NewIndex | Fields], Result).








%%% ---- json_write/2 ----
json_write(JSON, FileName) :-
    convert_to_JSON(JSON, JSONConverted),
    term_string(JSONConverted, JSONString),
    open(FileName, write, Out),
    write(Out, JSONString),
    put(Out, 0'.),
    nl(Out),
    close(Out).




%%% convert_to_JSON/2
convert_to_JSON(JSON, JSONConverted) :-
    get_JSON_object(Converted, Type, JSON),
    encapsulate(Converted, Type, JSONConverted).



%%% encapsulate/3
encapsulate([], object, {}).

encapsulate(Object, object, EncapsulatedObject) :-
    term_string(Object, String),
    string_chars(String, Chars),
    remove_first_bracket(Chars, CharsTemp),
    remove_last_bracket(CharsTemp, NewChars),
    append(['{'], NewChars, PartialObject),
    append(PartialObject, ['}'], ObjectInChars),
    string_chars(ObjectInString, ObjectInChars),
    term_string(EncapsulatedObject, ObjectInString).

encapsulate(Array, array, Array).


%%% remove_first_char/2
remove_first_bracket([_ | More], More).


%%% remove_last_char/2
remove_last_bracket([_ | []], []).

remove_last_bracket([Char | MoreChars], [Char | OtherChars]) :-
    remove_last_bracket(MoreChars, OtherChars).






%%% ---- json_load/2 ----
json_load(FileName, JSON) :-
    catch(open(FileName, read, In), _, false),
    read(In, JSONTerm),
    close(In),
    term_string(JSONTerm, JSONString),
    json_parse(JSONString, JSON).




%%%% end of file -- json-parsing.pl --
