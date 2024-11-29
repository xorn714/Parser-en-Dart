Hecho por:
Bach. Daniel Hernández
30.870.923
maureradaniel.2005@gmail.com

<programa> ::= 'Algoritmo' <identificador> 'Declaracion' <declaraciones> 'Inicio' <instrucciones> 'Fin'

<declaraciones> ::= 'Variables' <declaracion>*

<declaracion> ::= <tipo> <identificador> (',' <identificador>)*

<tipo> ::= 'entero' | 'real' | 'booleano' | 'caracter' | 'cadena'

<instrucciones> ::= <instruccion>*

<instruccion> ::= <asignacion> | <si> | <mientras> | <para> | <repetir> | <escribir> | <leer>

<asignacion> ::= <identificador> '=' <expresion>

<si> ::= 'SI' '(' <expresion> ')' '{' <instrucciones> '}' ('SINO' '{' <instrucciones> '}')? 'FSI'

<mientras> ::= 'MIENTRAS' '(' <expresion> ')' '{' <instrucciones> '}' 'FMIENTRAS'

<para> ::= 'PARA' '(' <asignacion> ';' <expresion> ';' <asignacion> ')' '{' <instrucciones> '}' 'FPARA'

<repetir> ::= 'REPETIR' '{' <instrucciones> '}' 'HASTA' '(' <expresion> ')'

<escribir> ::= 'ESCRIBIR' <expresion>

<leer> ::= 'LEER' <identificador>

<expresion> ::= <termino> ( <operador> <termino> )*

<termino> ::= <numero> | <identificador> | <booleano> | <cadena> | '(' <expresion> ')'

<operador> ::= '+' | '-' | '*' | '/' | '<' | '>' | '<=' | '>=' | '==' | '<>'

<identificador> ::= [a-zA-Z][a-zA-Z0-9]*

<numero> ::= [0-9]+

<booleano> ::= 'VERDADERO' | 'FALSO'

<cadena> ::= '"' .* '"'