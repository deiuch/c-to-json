%s COMMENT
%s PREP

O         [0-7]
D         [0-9]
H         [0-9A-Fa-f]
ND        [A-Za-z_]
DE        ([Ee][+-]?{D}+)
HE        ([Pp][+-]?{D}+)
LS        (L|l|LL|ll)
IS        ([Uu]{LS}?|{LS}[Uu]?)
FS        [FfLl]
HASH      ("??="|"#")
LBRACKET  ("??("|"[")
BS        ("??/"|"\\")
RBRACKET  ("??)"|"]")
CARET     ("??'"|"^")
LBRACE    ("??<"|"{")
VERTICAL  ("??!"|"|")
RBRACE    ("??>"|"}")
TILDE     ("??-"|"~")
PR_INS    [ \t]+[^\n\r]*$
NLE       ({BS}\n|{BS}\r|{BS}\r\n)
UCN       ({BS}U{H}{8})
ID        {ND}({ND}|{D}|{BS}u{H}{4}|{UCN})*
ES        ({BS}\'|{BS}\"|{BS}\?|{BS}{BS}|{BS}a|{BS}b|{BS}f|{BS}n|{BS}r|{BS}t|{BS}v|{BS}{O}{1,3}|{BS}x{H}+|{UCN})

%{
#include "y.tab.h"

extern YYSTYPE yylval;

int comment_ctr = 0;
%}

%%

^[ \t]*({HASH}|"%:")[ \t]* { BEGIN PREP; }
<PREP>"if"{PR_INS}      { BEGIN INITIAL; }
<PREP>"ifdef"{PR_INS}   { BEGIN INITIAL; }
<PREP>"ifndef"{PR_INS}  { BEGIN INITIAL; }
<PREP>"elif"{PR_INS}    { BEGIN INITIAL; }
<PREP>"else"{PR_INS}    { BEGIN INITIAL; }
<PREP>"endif"{PR_INS}   { BEGIN INITIAL; }
<PREP>"include"{PR_INS} { BEGIN INITIAL; }
<PREP>"define"{PR_INS}  { BEGIN INITIAL; }
<PREP>"undef"{PR_INS}   { BEGIN INITIAL; }
<PREP>"line"{PR_INS}    { BEGIN INITIAL; }
<PREP>"error"{PR_INS}   { BEGIN INITIAL; /* TODO error */ }
<PREP>"warning"{PR_INS} { BEGIN INITIAL; /* TODO warning, removed from the ISO */ }
<PREP>"pragma"{PR_INS}  { BEGIN INITIAL; }
<PREP>""$               { BEGIN INITIAL; /* TODO ISO/IEC 9899:2017, pages 136-146 or 363-364 */ }
<PREP>[^\n\r]+$         { BEGIN INITIAL; /* TODO error */ }

"/"{NLE}?"/"({NLE}|[^\n\r])*$ { /* ignore inline comment */ }
"/"{NLE}?"*"            { BEGIN COMMENT; }
<COMMENT>"*"{NLE}?"/"   { BEGIN INITIAL; }
<COMMENT>(.|\n)|"*"{NLE}? { /* ignore comment content */ }

"auto"                  { return AUTO; }
"break"                 { return BREAK; }
"case"                  { return CASE; }
"char"                  { return CHAR; }
"const"                 { return CONST; }
"continue"              { return CONTINUE; }
"default"               { return DEFAULT; }
"do"                    { return DO; }
"double"                { return DOUBLE; }
"else"                  { return ELSE; }
"enum"                  { return ENUM; }
"extern"                { return EXTERN; }
"float"                 { return FLOAT; }
"for"                   { return FOR; }
"goto"                  { return GOTO; }
"if"                    { return IF; }
"inline"                { return INLINE; }
"int"                   { return INT; }
"long"                  { return LONG; }
"register"              { return REGISTER; }
"restrict"              { return RESTRICT; }
"return"                { return RETURN; }
"short"                 { return SHORT; }
"signed"                { return SIGNED; }
"sizeof"                { return SIZEOF; }
"static"                { return STATIC; }
"struct"                { return STRUCT; }
"switch"                { return SWITCH; }
"typedef"               { return TYPEDEF; }
"union"                 { return UNION; }
"unsigned"              { return UNSIGNED; }
"void"                  { return VOID; }
"volatile"              { return VOLATILE; }
"while"                 { return WHILE; }
"_Alignas"              { return ALIGNAS; }
"_Alignof"              { return ALIGNOF; }
"_Atomic"               { return ATOMIC; }
"_Bool"                 { return BOOL; }
"_Complex"              { return COMPLEX; }
"_Generic"              { return GENERIC; }
"_Imaginary"            { return IMAGINARY; }
"_Noreturn"             { return NORETURN; }
"_Static_assert"        { return STATIC_ASSERT; }
"_Thread_local"         { return THREAD_LOCAL; }

{ID}                    { return IDENTIFIER; /* TODO check universal char. name, ISO/IEC 9899:2017, p. 386 */ }
0[Xx]{H}+{IS}?          |
0{O}+{IS}?              |
{D}+{IS}?               |
{D}+{DE}{FS}?           |
{D}*"."{D}+{DE}?{FS}?   |
{D}+"."{D}*{DE}?{FS}?   |

0[Xx]{H}+{HE}{FS}?      |
0[Xx]{H}*"."{H}+{HE}?{FS}? |
0[Xx]{H}+"."{H}*{HE}?{FS}? |

[LUu]?'({ES}|{NLE}|[^'\\\n\r])+' { return CONSTANT; /* TODO check bounds, ISO/IEC 9899:2017, p. 387 */ }

([LUu]|u8)?\"({ES}|{NLE}|[^"\\\n\r])+\" { return STRING_LITERAL; /* TODO convert escapes and trigraphs */ }

{LBRACKET}|"<:"         { return LBRACKET; }
{RBRACKET}|":>"         { return RBRACKET; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
{LBRACE}|"<%"           { return LBRACE; }
{RBRACE}|"%>"           { return RBRACE; }
"."                     { return DOT; }
"->"                    { return ARROW; }
"++"                    { return DBL_PLUS; }
"--"                    { return DBL_MINUS; }
"&"                     { return AMPERSAND; }
"*"                     { return ASTERISK; }
"+"                     { return PLUS; }
"-"                     { return MINUS; }
{TILDE}                 { return TILDE; }
"!"                     { return BANG; }
"/"                     { return SLASH; }
"%"                     { return PERCENT; }
"<<"                    { return LSHIFT; }
">>"                    { return RSHIFT; }
"<"                     { return LS; }
">"                     { return GR; }
"<="                    { return LE; }
">="                    { return GE; }
"=="                    { return EQ; }
"!="                    { return NE; }
{CARET}                 { return CARET; }
{VERTICAL}              { return VERTICAL; }
"&&"                    { return LOG_AND; }
{VERTICAL}{VERTICAL}    { return LOG_OR; }
"?"                     { return QUESTION; }
":"                     { return COLON; }
";"                     { return SEMICOLON; }
"..."                   { return ELLIPSIS; }
"="                     { return ASSIGN; }
"*="                    { return MUL_ASSIGN; }
"/="                    { return DIV_ASSIGN; }
"%="                    { return MOD_ASSIGN; }
"+="                    { return ADD_ASSIGN; }
"-="                    { return SUB_ASSIGN; }
"<<="                   { return LEFT_ASSIGN; }
">>="                   { return RIGHT_ASSIGN; }
"&="                    { return AND_ASSIGN; }
{CARET}=                { return XOR_ASSIGN; }
{VERTICAL}=             { return OR_ASSIGN; }
","                     { return COMMA; }

[ \f\n\r\t\v]           { /* skip over whitespaces */ }
.                       { /* TODO error */ }

%%

/// Change input after EOF was reached.
int yywrap()
{
    return 1; // TODO change input on #include
}