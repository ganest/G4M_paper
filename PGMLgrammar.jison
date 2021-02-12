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

"\"world\""                 return 'WORLD'
"\"currency\""              return 'CURRENCY'
"\"territory\""             return 'TERRITORY'
"\"territoryArea\""         return 'TERRITORY_AREA'
"\"gameObjects\""           return 'GAME_OBJS'
"\"gameObjectsInstances\""  return 'GAME_OBJS_INSTS'

"\"objInstId\""   return 'OBJ_INST_ID'
"\"instanceOf\""  return 'INSTANCE_OF'
"\"creatorId\""   return 'CREATOR_ID'
"\"position\""    return 'POS'
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
"\"center\""      return 'CENTER'
"\"lat\""         return 'LAT'
"\"lon\""         return 'LON'  
"\"radius\""      return 'RADIUS'
"\"area\""        return 'AREA'
"\"scenes\""      return 'SCENES'
"\"scene\""       return 'SCENE'
"\"laws\""        return "LAWS"
"\"rule\""        return "RULE"
"\"players\""     return "PLAYERS"
"\"alias\""       return "ALIAS"
"\"avatar\""      return "AVATAR"
"\"photo\""       return "PHOTO"
"\"inventory\""   return "INVENTORY"
"\"skills\""      return "SKILLS"
"\"missions\""    return "MISSIONS"
"\"status\""      return "STATUS"
"\"pending\""     return "PENDING"

"\"accomplished\"" return "ACCOMPLISHED"

"\"nonPlayerChars\"" return 'NPCs' 

{P_NAME}           return 'PROP_NAME'

<<EOF>>           return 'EOF'
.                 return 'INVALID'

/lex

%start pervasiveGame

%% /* language grammar */

pervasiveGame
  : '{' gameMeta ',' GAME_OBJS ':' gameObjs ',' WORLD ':' world '}' EOF
    { 
      typeof console !== 'undefined' 
      ? console.log(`{\n${$gameMeta}, ${$GAME_OBJS}: ${$gameObjs}, \n${$WORLD}:${$world}}`) 
      : print($1); 
    }
  ;

gameMeta
  : UID ':' val ',' NAME ':' val ',' DESC ':' val  
    { $$ = $1 + $2 + $3 +$4 + $5 + $6 + $7 + $8 +$9 + $10 + $11; }
  ;
gameObjs 
  : '[' gameObjItems ']' 
    { $$ = `[ ${$2} ]`; }
  ;
gameObjItems 
  : gameObject 
  | gameObject ',' gameObjItems 
    { $$ = `${$1},${$3}`; }
  ;

gameObject
  : '{' objStdProps '}' 
    { $$ = `\n{\n ${$objStdProps}\n}\n`; }
  | '{' objStdProps  objAdditionalProps '}' 
    { $$ = `\n{\n ${$objStdProps} ${$objAdditionalProps} \n}\n`; }
  ;

objStdProps  
  :  UID ':' val ',' OBJ_TYPE ':' objType ',' NAME ':' val ',' ICON ':' val exposes
    { $$ = $1+$2+$3+$4+$5+$6+$7+$8+$9+$10+$11+$12+$13+$14+$15+$16; }
  ;

objType
  : VO vObjStdProps 
    { $$ = $VO + $vObjStdProps; }
  | RWO
  ;

vObjStdProps
  : ',' HIDDEN ':' boolVal ',' ACTIVE ':' boolVal ',' TRACKABLE ':' FALSE
    { $$ = ',' + $HIDDEN + ':' + $boolVal1 + ',' + $ACTIVE + ':' + $boolVal2 + ',' + $TRACKABLE + ':' + $FALSE; }
  | ',' HIDDEN ':' boolVal ',' ACTIVE ':' boolVal ',' TRACKABLE ':' TRUE ',' PROXIMITY ':' numVal 
    { $$ = ',' + $HIDDEN + ':' + $boolVal1 + ',' + $ACTIVE + ':' + $boolVal2 + ',' + $TRACKABLE + ':' + $TRUE + ',' + $PROXIMITY + ':' + $numVal; } 
 ;

exposes
  : ',' EXPOSES ':' '[' behavioural_interfaces ']' 
    { $$ = ',' + $EXPOSES + ':[' + ($behavioural_interfaces ? $behavioural_interfaces : '') +']'; }
  ;

behavioural_interfaces
  : behavioural_interface 
  | behavioural_interface ',' behavioural_interfaces 
    { $$ = $1 + ',' + $3; }
  | %empty 
  ;

behavioural_interface
  : '{' NAME ':' interface '}' 
    { $$ = $1 + $2 + $3 + $4 + $5; }
  | '{' NAME ':' interface ',' CONDITIONAL ':' cond '}' 
    { $$ = $1 + $2 + $3 + $4 + $5 + $6 + $7 + $8 + $9; }
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
  | objAdditionalProp objAdditionalProps 
    { $$ = $1 + $2; }   
  ;

objAdditionalProp
  : ',' propName ':' propValue 
    { $$ = $1 + $2 + $3 + $4; }
  ;

propName
  : PROP_NAME
  ;

propValue
  : val
  ;

world
  : '{' worldMeta ',' SCENES ':' scenes ',' LAWS ':' laws ',' PLAYERS ':' players ',' NPCs ':' nonPlayerChars '}'
    { $$ = `{\n ${$worldMeta},\n${$SCENES}: ${$scenes},\n${$LAWS}:${$laws},\n${$PLAYERS}: ${$players},\n${$NPCs}:${$nonPlayerChars} \n}`; } 
  ;

worldMeta
  : CURRENCY ':' STR ',' TERRITORY ':' STR ',' TERRITORY_AREA ':' area
    { $$ = `${$CURRENCY}:${$STR1},${$TERRITORY}:${$STR2},${$TERRITORY_AREA}:${$area}`; }
  ;

scenes
  : '[' sceneItems ']' 
    { $$ = `[${$sceneItems}]`; }
  ;

sceneItems
  : scene
  | scene ',' sceneItems
    { $$ = `${$scene},${$sceneItems}`; }
  ;

scene
  : '{' UID ':' STR ',' NAME ':' STR ',' AREA ':' area ',' GAME_OBJS_INSTS ':' gameObjsInsts '}'
    { $$ = `{\n${$UID}:${$STR1}, ${$NAME}:${$STR2}, ${$AREA}:${$area},${$GAME_OBJS_INSTS}:${$gameObjsInsts} \n}`;}
  ;

gameObjsInsts 
  : '[' gameObjsInstItems ']' 
    { $$ = `[${$gameObjsInstItems}]`; }
  ;
gameObjsInstItems 
  : gameObjInstance 
  | gameObjInstance ',' gameObjsInstItems 
    { $$ = `${$gameObjInstance},${$gameObjsInstItems}`; }
  | %empty  
  ;

gameObjInstance
  : '{' OBJ_INST_ID ':' STR ',' INSTANCE_OF ':' instOf ',' CREATOR_ID ':' STR ',' POS ':' geoCoords '}'
    { $$ = '\n{\n'+ $OBJ_INST_ID + ':' + $STR1 + $INSTANCE_OF + ':' + $instOf + '\n}\n'; }
  | '{' objStdProps  objAdditionalProps '}' 
    { $$ = '\n{\n'+ $objStdProps + $objAdditionalProps +'\n}\n'; }  
  ;

instOf
  : STR
  ;

laws
  : '[' lawItems ']'  
    { $$ = `[${$lawItems}]`; }
  ;

lawItems
  : law
  | law ',' lawItems
    { $$ = `${$law},${$lawItems}`; } 
  | %empty
  ;  

law
  : '{' UID ':' STR ',' NAME ':' STR ',' RULE ':' cond '}'
    { $$ = `{ ${$UID}:${$STR1}, ${$NAME}:${$STR2},${$RULE}:${$cond} }`;}
  ;

players
  : '[' playerItems ']' 
    { $$ = `[${$playerItems}]`; }
  ;

playerItems
  : player
  | player ',' playerItems
    { $$ = `${$player}, ${$playerItems}`; }
  | %empty
  ;

// player
//   : '{' playerMeta '}'
//   | '{' playerMeta ',' AVATAR ':' avatar '}'
//   | '{' playerMeta ',' AVATAR ':' avatar ',' INVENTORY ':' inventory ',' SKILLS ':' skills ',' MISSIONS ':' missions '}'
//   ;

simplePlayer : playerMeta ;

playerMeta
  : UID ':' STR ',' NAME ':' STR ',' ALIAS ':' STR 
    { $$ = `${$UID}:${$STR1},${$NAME}:${$STR2},${$ALIAS}:${$STR3}`;}
  ;

simplePlayerWithAvatar 
  : simplePlayer 
  | AVATAR ':' avatar ',' simplePlayer 
    { $$ = `\n${$AVATAR}:${$avatar},${$simplePlayer}`; }
  ;

simplePlayerWithAvatarInv
  : simplePlayerWithAvatar 
  | INVENTORY ':' inventory ',' simplePlayerWithAvatar 
    { $$ = `\n${$INVENTORY}:${$inventory},${$simplePlayerWithAvatar}`; }
  ;

simplePlayerWithAvatarInvSkills
  : simplePlayerWithAvatarInv
  | SKILLS ':' skills ',' simplePlayerWithAvatarInv 
    { $$ = `\n${$SKILLS}:${$skills},${$simplePlayerWithAvatarInv}`; } 
  ;

simplePlayerWithAvatarInvSkillsMissions
  : simplePlayerWithAvatarInvSkills
  | MISSIONS ':' missions ',' simplePlayerWithAvatarInvSkills 
    { $$ = `\n${$MISSIONS}:${$missions},${$simplePlayerWithAvatarInvSkills}`; } 
  ;

player
  : '{' simplePlayerWithAvatarInvSkillsMissions '}' 
    { $$ = `\n{${$simplePlayerWithAvatarInvSkillsMissions}}`; };

avatar
  : '{' NAME ':' STR ',' ICON ':' STR ',' PHOTO ':' STR '}'
    { $$ = `{${$NAME}:${$STR1},${$ICON}:${$STR2},${$PHOTO}:${$STR3} }`; }
  ;

inventory
  : '[' gameObjsInstItems ']' 
    { $$ = `[${$gameObjsInstItems}]`; }
  ;

skills
  : '[' skillItems ']'
    { $$ = `[${$skillItems}]`; }
  ;

skillItems
  : skill
  | skill ',' skillItems 
    { $$ = `${$skill},${$skillItems}`; }
  | %empty
  ;

skill
  : '{' NAME ':' STR '}'
    { $$ = `{${$NAME}:${$STR} }`; }
  ;

missions
  : '[' missionItems ']'
    { $$ = `[${$missionItems}]`; }
  ;

missionItems
  : missionItem
  | missionItem ',' missionItems
    { $$ = `${$missionItem},${$missionItems}`; }
  ;

missionItem
  : '{' STATUS ':' missionStatus '}'
    { $$ = `{${$STATUS}:${$missionStatus}}`; }
  ;

missionStatus
  : PENDING
  | ACCOMPLISHED
  ;

nonPlayerChars
  : '[' nonPlayerCharItems ']'
    { $$ = `[${$nonPlayerCharItems}]`; }
  ;

nonPlayerCharItems
  : nonPlayerChar
  | nonPlayerChar ',' nonPlayerCharItems
    { $$ = `${$nonPlayerChar},${$nonPlayerCharItems}`; }
  | %empty
  ; 

nonPlayerChar
  : '{' NAME ':' STR ',' ICON ':' STR ',' PHOTO ':' STR '}'
    { $$ = `{\n${$NAME}:${$STR1},${$ICON}:${$STR2},${$PHOTO}:${$STR3} }`; }
  ;

area
  : '{' center ',' radius '}'
    { $$ = `{${$center},${$radius} }`; }
  ;

center
  : CENTER ':' geoCoords
    { $$ = `${$CENTER}:${$geoCoords}`; }
  ;

geoCoords
  : '{' LAT ':' numVal ',' LON ':' numVal '}'
    { $$ = `{ ${$LAT}:${$numVal1},${$LON}:${$numVal2} }`; }
  ;

radius
  : RADIUS ':' numVal
    { $$ = `${$RADIUS}:${$numVal}`; }
  ;

cond
  : '{' op ':' '[' values ']' '}' 
    { $$ = '{' + $2 + ':[' + $5 + ']}'; }  
  ;

values
  : val     
  | val ',' values 
    { $$ = $1 + ',' + $3; }
  ;
  
val 
  : cond 
  | numVal
  | ID 
  | STR 
  ;

boolVal
  : TRUE
  | FALSE
  ;

numVal
  : NUMBER 
  ;

op
  : '*' | '/' | '-' | '+' | '%' | '==' | '!==' | '!' | '<' | '>' | '<=' | '>=' | 'or' | 'and' | 'var' | 'if'
  ;