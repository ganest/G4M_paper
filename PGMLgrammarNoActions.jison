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

pervasiveGame : '{' gameMeta ',' GAME_OBJS ':' gameObjs ',' WORLD ':' world '}' EOF;

gameMeta: UID ':' val ',' NAME ':' val ',' DESC ':' val;
gameObjs: '[' gameObjItems ']';
gameObjItems: gameObject | gameObject ',' gameObjItems;

gameObject: '{' objStdProps '}' | '{' objStdProps  objAdditionalProps '}';
objStdProps: UID ':' val ',' OBJ_TYPE ':' objType ',' NAME ':' val ',' ICON ':' val exposes;
objType: VO vObjStdProps | RWO;

vObjStdProps: ',' HIDDEN ':' boolVal ',' ACTIVE ':' boolVal ',' TRACKABLE ':' FALSE    
  | ',' HIDDEN ':' boolVal ',' ACTIVE ':' boolVal ',' TRACKABLE ':' TRUE ',' PROXIMITY ':' numVal;

exposes: ',' EXPOSES ':' '[' behavioural_interfaces ']';

behavioural_interfaces
  : behavioural_interface 
  | behavioural_interface ',' behavioural_interfaces 
  | %empty 
  ;

behavioural_interface: '{' NAME ':' interface '}' | '{' NAME ':' interface ',' CONDITIONAL ':' cond '}' ; 

interface: COLLECTABLE | REDEEMABLE | EXCHANGABLE | SOLVABLE | SCANNABLE;

objAdditionalProps: objAdditionalProp | objAdditionalProp objAdditionalProps;

objAdditionalProp: ',' propName ':' propValue;

propName: PROP_NAME;

propValue: val;

world: '{' worldMeta ',' SCENES ':' scenes ',' LAWS ':' laws ',' PLAYERS ':' players ',' NPCs ':' nonPlayerChars '}';

worldMeta: CURRENCY ':' STR ',' TERRITORY ':' STR ',' TERRITORY_AREA ':' area;

scenes: '[' sceneItems ']';
sceneItems: scene | scene ',' sceneItems;
scene: '{' UID ':' STR ',' NAME ':' STR ',' AREA ':' area ',' GAME_OBJS_INSTS ':' gameObjsInsts '}';

gameObjsInsts: '[' gameObjsInstItems ']';
gameObjsInstItems
  : gameObjInstance 
  | gameObjInstance ',' gameObjsInstItems
  | %empty
  ;

gameObjInstance
  : '{' OBJ_INST_ID ':' STR ',' INSTANCE_OF ':' instOf ',' CREATOR_ID ':' STR ',' POS ':' geoCoords '}'    
  | '{' objStdProps  objAdditionalProps '}' 
  ;

instOf: STR;
laws: '[' lawItems ']';
lawItems: law | law ',' lawItems 
  | %empty
  ;  
law: '{' UID ':' STR ',' NAME ':' STR ',' RULE ':' cond '}';

players: '[' playerItems ']';
playerItems: player | player ',' playerItems 
  | %empty
  ;

simplePlayer : playerMeta;

playerMeta: UID ':' STR ',' NAME ':' STR ',' ALIAS ':' STR;

simplePlayerWithAvatar: simplePlayer | AVATAR ':' avatar ',' simplePlayer;

simplePlayerWithAvatarInv: simplePlayerWithAvatar | INVENTORY ':' inventory ',' simplePlayerWithAvatar;

simplePlayerWithAvatarInvSkills: simplePlayerWithAvatarInv | SKILLS ':' skills ',' simplePlayerWithAvatarInv;

simplePlayerWithAvatarInvSkillsMissions
  : simplePlayerWithAvatarInvSkills
  | MISSIONS ':' missions ',' simplePlayerWithAvatarInvSkills     
  ;

player: '{' simplePlayerWithAvatarInvSkillsMissions '}';
avatar: '{' NAME ':' STR ',' ICON ':' STR ',' PHOTO ':' STR '}';
inventory: '[' gameObjsInstItems ']';

skills: '[' skillItems ']';
skillItems: skill | skill ',' skillItems 
  | %empty
  ;
skill: '{' NAME ':' STR '}';

missions: '[' missionItems ']';
missionItems: missionItem | missionItem ',' missionItems;
missionItem: '{' STATUS ':' missionStatus '}';
missionStatus: PENDING | ACCOMPLISHED;

nonPlayerChars: '[' nonPlayerCharItems ']';
nonPlayerCharItems: nonPlayerChar | nonPlayerChar ',' nonPlayerCharItems 
  | %empty
  ; 
nonPlayerChar: '{' NAME ':' STR ',' ICON ':' STR ',' PHOTO ':' STR '}';

area: '{' center ',' radius '}';
center: CENTER ':' geoCoords;
geoCoords: '{' LAT ':' numVal ',' LON ':' numVal '}';
radius: RADIUS ':' numVal;

cond: '{' op ':' '[' values ']' '}';
  
values: val | val ',' values;  
val : cond | numVal | ID | STR;
boolVal: TRUE | FALSE;
numVal: NUMBER;

op: '*' | '/' | '-' | '+' | '%' | '==' | '!==' | '!' | '<' | '>' | '<=' | '>=' | 'or' | 'and' | 'var' | 'if';