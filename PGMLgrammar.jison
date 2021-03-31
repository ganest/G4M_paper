/*
Author: George Anestis
email: ganest@ced.tuc.gr
Organisation: Technical University of Crete (TUC), School of Electrical & Computer Engineering 

Grammar of the Pervasive Game Modelling Language described using the 
Jison, a JavaScript parser generator (https://zaa.ch/jison/)

The first part describes the tokens for Lexical Analysis via
regural expressions using notation similar to that of Flex tool (https://github.com/westes/flex)

The second part describes the grammar rules for Syntactic Analysis 
using BNF-like notation similar to that of the Bison tool (https://www.gnu.org/software/bison/)
*/

/* Part 1: lexical grammar */
%lex
%options easy_keyword_rules
%options flex

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
"\"statements\""            return 'STMTS'
"\"resources\""             return 'RESOURCES'
"\"marketplace\""           return 'MARKETPLACE'

"\"objInstId\""   return 'OBJ_INST_ID'
"\"instanceOf\""  return 'INSTANCE_OF'
"\"creatorId\""   return 'CREATOR_ID'
"\"missionId\""   return 'MISSION_ID'
"\"position\""    return 'POS'
"\"name\""        return 'NAME'
"\"label\""       return 'LABEL'
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
"\"responsable\"" return 'RESPONSABLE'
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
"\"laws\""        return 'LAWS'
"\"rule\""        return 'RULE'
"\"players\""     return 'PLAYERS'
"\"alias\""       return 'ALIAS'
"\"avatar\""      return 'AVATAR'
"\"photo\""       return 'PHOTO'
"\"inventory\""   return 'INVENTORY'
"\"skills\""      return 'SKILLS'
"\"missions\""    return 'MISSIONS'
"\"subMissions\"" return "SUB_MISSIONS"
"\"status\""      return 'STATUS'
"\"pending\""     return 'PENDING'
"\"ordered\""     return 'ORDERED'
"\"body\""        return 'BODY'
"\"response\""    return 'RESPONSE'
"\"implements\""  return 'IMPLEMENTS'
"\"amount\""      return 'AMOUNT'

"\"accomplished\""      return 'ACCOMPLISHED'

"\"nonPlayerChars\""    return 'NPCs' 
"\"assingedMissions\""  return 'ASSIGNED_MISSIONS'
"\"providedSkills\""    return 'PROVIDED_SKILLS'
"\"supplies\""          return 'SUPPLIES'

{P_NAME}          return 'PROP_NAME'

{IDENT}           return 'ID'
{STRING}          return 'STR'

<<EOF>>           return 'EOF'
.                 return 'INVALID'

/lex

/* Part 2: language grammar */
/* TODO
In the final version, I have to delete the action part of the rules 
which is used only during development for debugging purposes
*/

%start pervasiveGame

%% 

pervasiveGame
  : '{' gameMeta ',' GAME_OBJS ':' gameObjs ',' WORLD ':' world ','  MISSIONS ':' missions '}' EOF
    { 
      typeof console !== 'undefined' 
      ? console.log(`{\n${$gameMeta},${$GAME_OBJS}:${$gameObjs}, \n${$WORLD}:${$world}, \n${$MISSIONS}: ${$missions}}`) 
      : print($1); 
    }
  ;

gameMeta
  : UID ':' val ',' NAME ':' val ',' DESC ':' val  
    { $$ = $1 + $2 + $3 +$4 + $5 + $6 + $7 + $8 +$9 + $10 + $11; }
  ;

/* Pervasive Game GameObjects */
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
  :  UID ':' val ',' OBJ_TYPE ':' objType ',' NAME ':' val ',' ICON ':' STR exposes
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
  : ',' EXPOSES ':' '[' behaviouralInterfaces ']' 
    { $$ = ',' + $EXPOSES + ':[' + ($behaviouralInterfaces ? $behaviouralInterfaces : '') +']'; }
  ;

behaviouralInterfaces
  : behaviouralInterface 
  | behaviouralInterface ',' behaviouralInterfaces 
    { $$ = $1 + ',' + $3; }
  | %empty 
  ;

behaviouralInterface
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
  | RESPONSABLE
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

/* Pervasive Game World */
world
  : '{' worldMeta ',' SCENES ':' scenes ',' LAWS ':' laws ',' PLAYERS ':' players ',' NPCs ':' nonPlayerChars ',' RESOURCES ':' resources ',' MARKETPLACE ':' marketplace '}'
    { $$ = `{\n ${$worldMeta},\n${$SCENES}: ${$scenes},\n${$LAWS}:${$laws},\n${$PLAYERS}: ${$players},\n${$NPCs}:${$nonPlayerChars},${$RESOURCES}:${$resources},${$MARKETPLACE}:${$marketplace} \n}`; } 
  ;

worldMeta
  : CURRENCY ':' STR ',' TERRITORY ':' STR ',' TERRITORY_AREA ':' area
    { $$ = `${$CURRENCY}:${$STR1},${$TERRITORY}:${$STR2},${$TERRITORY_AREA}:${$area}`; }
  ;

/* World's Scenes */
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
  : '{' UID ':' STR ',' NAME ':' STR ',' AREA ':' area ',' GAME_OBJS_INSTS ':' gameObjsInsts ',' STMTS ':' stmts '}'
    { $$ = `{\n${$UID}:${$STR1}, ${$NAME}:${$STR2}, ${$AREA}:${$area},${$GAME_OBJS_INSTS}:${$gameObjsInsts},${$STMTS}:${$stmts} \n}`;}
  ;

gameObjsInsts 
  : '[' gameObjsInstItems ']' 
    { $$ = `[${$gameObjsInstItems ? $gameObjsInstItems : ''}]`; }
  ;
gameObjsInstItems 
  : gameObjInstance 
  | gameObjInstance ',' gameObjsInstItems 
    { $$ = `${$gameObjInstance},${$gameObjsInstItems}`; }
  | %empty  
  ;

gameObjInstance
  : '{' OBJ_INST_ID ':' STR ',' INSTANCE_OF ':' STR ',' CREATOR_ID ':' STR ',' POS ':' geoCoords '}'
    { $$ = `\n{\n${$OBJ_INST_ID}:${$STR1},${$INSTANCE_OF}:${$STR2},${$CREATOR_ID}:${$STR3},${$POS}:${$geoCoords}\n}\n`; }   
  ;

stmts
  : '[' stmtItems ']'
    { $$ = `[${$stmtItems ? $stmtItems : ''}]`; }
  ;

stmtItems
  : stmt
  | stmt ',' stmtItems
    { $$ = `${$stmt},${$stmtItems}`; }
  | %empty
  ;

stmt
  : '{' UID ':' STR ','  BODY ':' STR ',' RESPONSE ':' options  '}'
    { $$ = `{${$UID}:${$STR1},${$BODY}:${$STR2},${$RESPONSE}:${$options}}`; }
  ;

options
  : '[' optionItems ']'
    { $$ = `[${$optionItems}]`; }
  ;

optionItems
  : option
  | option ',' optionItems
    { $$ = `${$option},${$optionItems}`; }  
  ;

option
  : '{' LABEL ':' STR ',' ICON ':' STR ',' IMPLEMENTS ':' behaviouralInterface  '}'
    { $$ = `{${$LABEL}:${$STR1},${$ICON};${$STR2},${$IMPLEMENTS}:${$behaviouralInterface}}`; }
  ;

/* World's Laws */
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

/* World's Players */
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

simplePlayerWithAvatarInvSkillsAssignedMissions
  : simplePlayerWithAvatarInvSkills
  | ASSIGNED_MISSIONS ':' assignedMissions ',' simplePlayerWithAvatarInvSkills 
    { $$ = `\n${$ASSIGNED_MISSIONS}:${$assignedMissions},${$simplePlayerWithAvatarInvSkills}`; } 
  ;

player
  : '{' simplePlayerWithAvatarInvSkillsAssignedMissions '}'
    { $$ = `\n{${$simplePlayerWithAvatarInvSkillsAssignedMissions}}`; }
  ;

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
    { $$ = `[${$skillItems ? $skillItems : ''}]`; }
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

assignedMissions 
  : '[' assignedMissionItems ']'
    { $$ = `[${$assignedMissionItems}]`; }
  ;

assignedMissionItems
  : assignedMissionItem
  | assignedMissionItem ',' assignedMissionItems
    { $$ = `${$assignedMissionItem}, ${$assignedMissionItems}`; }
  ;

assignedMissionItem 
  : '{' MISSION_ID ':' STR ',' STATUS ':' assignedMissionStatus '}'
    { $$ = `{ ${$MISSION_ID}:${$STR}, ${$STATUS}:${$assignedMissionStatus} }`; }
  ;

assignedMissionStatus
  : PENDING
  | ACCOMPLISHED
  ;

/* Pervasive Game missions */
missions
  : '[' missionItems ']'
    { $$ = `[${$missionItems}]`; }
  ;

missionItems
  : missionItem
  | missionItem ',' missionItems
    { $$ = `${$missionItem},${$missionItems}`; }
  | %empty 
  ;

simpleMissionItem
  : MISSION_ID ':' STR ',' NAME ':' STR ',' DESC ':' STR 
    { $$ = `${$MISSION_ID}:${$STR1},${$NAME}:${$STR2},${$DESC}:${$STR3}`; }
  ;

compositeMissionItem
  : simpleMissionItem
  | SUB_MISSIONS ':'  missions ',' ORDERED ':' boolVal ',' simpleMissionItem
    { $$ = `${$SUB_MISSIONS}:${$missions},${$ORDERED}:${$boolVal},${$simpleMissionItem}`;}
  ;

missionItem
  : '{' compositeMissionItem '}'
    { $$ = `{${$compositeMissionItem}}`;}
  ;

/* World's NPCs */
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

/* World's Resources */
resources
  : '[' resourceItems ']'
    { $$ = `[${$resourceItems ? $resourceItems : '' }]`; }
  ;

resourceItems
  : resource
  | resource ',' resourceItems
    { $$ = `${$resource},${$resourceItems}`;}
  | %empty
  ;

resource
  : '{' NAME ':' STR ',' AMOUNT ':' NUMBER '}'
    { $$ = `{${$NAME}:${$STR},${$AMOUNT}:${$NUMBER}}`; }
  ;

/* World's Marketplace */
marketplace
  : '{' NAME ':' STR ',' SUPPLIES ':' gameObjsInsts ',' PROVIDED_SKILLS ':' skills '}'
    { $$ = `{${$NAME}:${$STR},${$SUPPLIES}:${$gameObjsInsts},${$PROVIDED_SKILLS}:${$skills}}`;}
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
  | boolVal
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