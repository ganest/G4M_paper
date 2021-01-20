/* lexical grammar */
%lex

DIGIT [0-9]
IDENT [a-zA-Z_][0-9a-zA-Z_.]*
%%

\s+                   /* skip whitespace */
\n                    /* skip newlines */

{DIGIT}+("."{DIGIT}+)?\b  return 'NUMBER'
"'"?{IDENT}"'"?  return 'ID'
"\"*\""          return '*'
"\"/\""          return '/'
"\"-\""          return '-'
"\"+\""          return '+'
"\"==\""         return '=='
"\"!==\""        return '!=='
"\"!\""          return '!'
"\"<\""          return '<'
"\"<=\""         return '<='
"\">\""          return '>'
"\">=\""         return '>='
"\"or\""         return 'or'
"\"and\""        return 'and'
"\"var\""        return 'var'
"{"              return '{'
"}"              return '}'
"["              return '['
"]"              return ']'
","              return ','
":"              return ':'



<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

%start conditional

%% /* language grammar */

conditional
  : cond EOF 
    { typeof console !== 'undefined' ? console.log($1) : print($1); }
  ;

cond
  : '{' op ':' '[' values ']' '}' { $$ = '{' + $2 + ':[' + $5 + ']}'; }  
  ;

values
  : val { $$ = $1; }
  | val ',' val { $$ = $1 + ',' + $3; }
  ;
  
val 
  : cond { $$ = $1; }
  | NUMBER { $$ = $1; }
  | ID { $$ = $1; }
  ;

op
  : '*' | '/' | '-' | '+' | '==' | '!==' | '!' | '<' | '>' | '<=' | '>=' | 'or' | 'and' | 'var'
  ;