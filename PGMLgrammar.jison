/* lexical grammar */
%lex

DIGIT [0-9]
IDENT [a-zA-Z_][0-9a-zA-Z_.]*

/* Regular string character: anything but \, <newline>, and quotes: '/"  */
RCHAR   [^\\\n'\"]

/* Quoted chars: \, <newline>, <tab>, <linefeed>, \, ', ". */
QCHAR   "\\\\"|"\\n"|"\\r"|"\\t"|"\\\""|"\\'"

/* A sequence of regular or quoted chars */
STRSEQ  ({RCHAR}|{QCHAR})*

/* String literals: must be quoted by ' */
STRING  \'{STRSEQ}\'

P_NAME \"{IDENT}\"

%%

\s+                   /* skip whitespace */
\n                    /* skip newlines */

{DIGIT}+("."{DIGIT}+)?\b  return 'NUMBER'
//"'"?{IDENT}"'"?  return 'ID'
true              return 'TRUE'
false             return 'FALSE'
{IDENT}          return 'ID'
{STRING}         return 'STR'
"\"*\""          return '*'
"\"/\""          return '/'
"\"-\""          return '-'
"\"+\""          return '+'
"\"%\""          return '%'
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
"\"if\""         return 'if'
"{"              return '{'
"}"              return '}'
"["              return '['
"]"              return ']'
","              return ','
":"              return ':'

"\"world\""       return 'WORLD'
"\"gameObjects\"" return 'GAME_OBJS'
"\"name\""        return 'NAME'
"\"id\""          return 'UID'
"\"description\"" return 'DESC'
"\"objectType\""  return 'OBJ_TYPE'
"\"VO\""          return 'VO'
"\"RWO\""         return 'RWO'
"\"icon\""        return 'ICON'
"\"exposes\""     return 'EXPOSES'
"\"collectable\"" return 'COLLECTABLE' 
"\"redeemable\""  return 'REDEEMABLE'
"\"exchangeable\"" return 'EXCHANGABLE'
"\"solvable\""    return 'SOLVABLE'
"\"scannable\""   return 'SCANNABLE'
"\"hidden\""      return 'HIDDEN'
"\"active\""      return 'ACTIVE'
"\"trackable\""   return 'TRACKABLE'
"\"proximity\""   return 'PROXIMITY'
"\"conditional\"" return 'CONDITIONAL'

{P_NAME}           return 'PROP_NAME'

<<EOF>>           return 'EOF'
.                 return 'INVALID'

/lex

%start pervasiveGame

%% /* language grammar */

pervasiveGame
  : '{' gameMeta ',' GAME_OBJS ':' gameObjs ',' WORLD ':' world '}' EOF
    { typeof console !== 'undefined' ? console.log($1+$2+$3+$4+$5+$6+$7+$8+$9+$10+$11) : print($1); }
  ;

gameMeta
  : UID ':' val ',' NAME ':' val ',' DESC ':' val  { $$ = $1 + $2 + $3 +$4 + $5 + $6 + $7 + $8 +$9 + $10 + $11; }
  ;
gameObjs 
  : '[' gameObjItems ']' { $$ = '[' + $2 + ']'; }
  ;
gameObjItems 
  : gameObject 
  | gameObject ',' gameObjItems { $$ = $1 + ',' + $3; }
  ;

gameObject
  : '{' objStdProps '}'     
    { $$ = '\n{\n'+ $objStdProps + '\n}\n'; }
  | '{' objStdProps  objAdditionalProps '}' 
    { $$ = '\n{\n'+ $objStdProps + $objAdditionalProps +'\n}\n'; }
  ;

objStdProps  
  :  UID ':' val ',' OBJ_TYPE ':' objType ',' NAME ':' val ',' ICON ':' val exposes
    { $$ = $1+$2+$3+$4+$5+$6+$7+$8+$9+$10+$11+$12+$13+$14+$15+$16; }
  ;

objType
  : VO vObjStdProps { $$ = $VO + $vObjStdProps; }
  | RWO
  ;

vObjStdProps
  : ',' HIDDEN ':' bool_val ',' ACTIVE ':' bool_val ',' TRACKABLE ':' FALSE
    { $$ = ',' + $HIDDEN + ':' + $bool_val1 + ',' + $ACTIVE + ':' + $bool_val2 + ',' + $TRACKABLE + ':' + $FALSE; }
  | ',' HIDDEN ':' bool_val ',' ACTIVE ':' bool_val ',' TRACKABLE ':' TRUE ',' PROXIMITY ':' num_val 
    { $$ = ',' + $HIDDEN + ':' + $bool_val1 + ',' + $ACTIVE + ':' + $bool_val2 + ',' + $TRACKABLE + ':' + $TRUE + ',' + $PROXIMITY + ':' + $num_val; } 
 ;

exposes
  : ',' EXPOSES ':' '[' behavioural_interfaces ']' { $$ = ',' + $EXPOSES + ':[' + ($behavioural_interfaces ? $behavioural_interfaces : '') +']'; }
  ;

behavioural_interfaces
  : behavioural_interface 
  | behavioural_interface ',' behavioural_interfaces { $$ = $1 + ',' + $3; }
  | %empty 
  ;

behavioural_interface
  : '{' NAME ':' interface '}' { $$ = $1 + $2 + $3 + $4 + $5; }
  | '{' NAME ':' interface ',' CONDITIONAL ':' cond '}' { $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9; }
  ; 

interface
  : COLLECTABLE
  | REDEEMABLE
  | EXCHANGABLE
  | SOLVABLE
  | SCANNABLE
  ;

objAdditionalProps
  : objAdditionalProp
  | objAdditionalProp objAdditionalProps { $$ = $1 + $2; }   
  ;

objAdditionalProp
  : ',' propName ':' propValue { $$ = $1 + $2 + $3 + $4; }
  ;

propName
  : PROP_NAME
  ;

propValue
  : val
  ;

cond
  : '{' op ':' '[' values ']' '}' { $$ = '{' + $2 + ':[' + $5 + ']}'; }  
  ;

world
  : '{' '}'
  ;

values
  : val { $$ = $1; }
  | val ',' values { $$ = $1 + ',' + $3; }
  ;
  
val 
  : cond 
  | num_val
  | ID 
  | STR 
  ;

bool_val
  : TRUE
  | FALSE
  ;

num_val
  : NUMBER 
  ;

op
  : '*' | '/' | '-' | '+' | '%' | '==' | '!==' | '!' | '<' | '>' | '<=' | '>=' | 'or' | 'and' | 'var' | 'if'
  ;