%x COMMENT
%x PREP
%x CHR
%x STR

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
NLE       ({BS}(\n|\r|\r\n))
UCN       ({BS}(u{H}{4}|U{H}{8}))
ID        {ND}({ND}|{D}|{BS}u{H}{4}|{UCN})*
ESC       ({BS}['"?\\abfnrtv]|{BS}"??/"|{BS}{O}{1,3}|{BS}x{H}+|{UCN})
CHAR      [LUu]?'({ESC}|[^'\\\n\r])+'
WRONGCHR  [LUu]?'[^']*(("??/"[^'"?\\abfnrtv])+[^']*|"??/")'
STRL      ([LUu]|u8)?\"({ESC}|[^"\\\n\r])+\"
WRONGSTR  ([LUu]|u8)?\"[^"]*(("??/"[^'"?\\abfnrtv])+[^"]*|"??/")\"

%{
#include <string.h>
#include "y.tab.h"

extern YYSTYPE yylval;

char *readstr(char *, size_t);
short istrigraphsuf(char);
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
<PREP>"warning"{PR_INS} { BEGIN INITIAL; /* TODO warning, no in ISO/IEC 9899:2017 review */ }
<PREP>"pragma"{PR_INS}  { BEGIN INITIAL; }
<PREP>""$               { BEGIN INITIAL; /* TODO ISO/IEC 9899:2017, pages 136-146 or 363-364 */ }
<PREP>[^\n\r]+$         { BEGIN INITIAL; /* TODO error */ }

"/"{NLE}?"/"({NLE}|[^\n\r])*$ { /* ignore inline comment */ }
"/"{NLE}?"*"            { BEGIN COMMENT; }
<COMMENT>(.|\n)|"*"{NLE}? { /* ignore comment content */ }
<COMMENT>"*"{NLE}?"/"   { BEGIN INITIAL; }

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

{ID} {
    yylval.text = (char *) malloc(strlen(yytext));
    strcpy(yylval.text, yytext);
    return IDENTIFIER;
}

0[Xx]{H}+{IS}?          |
0{O}+{IS}?              |
{D}+{IS}?               |
{D}+{DE}{FS}?           |
{D}*"."{D}+{DE}?{FS}?   |
{D}+"."{D}*{DE}?{FS}?   |
0[Xx]{H}+{HE}{FS}?      |
0[Xx]{H}*"."{H}+{HE}?{FS}? |
0[Xx]{H}+"."{H}*{HE}?{FS}? {
    yylval.text = (char *) malloc(strlen(yytext));
    strcpy(yylval.text, yytext);
    return CONSTANT;
    // TODO check bounds, ISO/IEC 9899:2017, p. 387
}

' { BEGIN CHR; }
\" { BEGIN STR; }
<CHR>' {
    BEGIN INITIAL;
    char *content = readstr(yytext, yyleng);
    if (strlen(content) != 1) {
        /* TODO error */
    }
    yylval.text = content;
    return CONSTANT;
}
<STR>\" {
    BEGIN INITIAL;
    yylval.text = readstr(yytext, yyleng);
    return STRING_LITERAL;
}
<STR,CHR>{ESC}          { yymore(); }
<STR,CHR>({BS}"??"[=()'<!>-]|{BS}.|\r|\n|\r\n) { BEGIN INITIAL; /* TODO error */ }
<STR,CHR>.              { yymore(); }

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

.*{BS}(\n|\r|\r\n) {
    /* remove escaped newline and check again */
    int i;
    //char *yycopy = strdup(yytext);  // recommended, but here it is unnecessary
    for (i = yyleng - 3; i >= 0; --i) {
        //unput(yycopy[i]);
        unput(yytext[i]);
    }
    //free(yycopy);
}
[ \f\n\r\t\v]           { /* skip over whitespaces */ }
.                       { /* TODO error */ }

%%

/// Replace escapes in string literal. Needs to be freed.
char *readstr(char *inp, size_t len) {
    char *res = (char *) malloc(sizeof(char) * (len - 1));
    size_t i = 0, j = 0;
    char to_put;
    while (i < len - 1) {
        if (yytext[i] == '\\' || yytext[i] == '?' && yytext[i+1] == '?' && yytext[i+2] == '/') {
            ++i;
            if (yytext[i-1] != '\\') i += 2;
            switch (yytext[i]) {
                case '?':
                    if (yytext[i+1] == '?' && istrigraphsuf(yytext[i+2])) {
                        i += 2;
                        if (yytext[i] == '/') {
                            to_put = '\\';
                        } else {
                            /* TODO error */;
                        }
                    } else {
                        to_put = '?';
                    }
                    break;
                case '\'': to_put = '\''; break;
                case '\"': to_put = '\"'; break;
                case '\\': to_put = '\\'; break;
                case 'a':  to_put = '\a'; break;
                case 'b':  to_put = '\b'; break;
                case 'f':  to_put = '\f'; break;
                case 'n':  to_put = '\n'; break;
                case 'r':  to_put = '\r'; break;
                case 't':  to_put = '\t'; break;
                case 'v':  to_put = '\v'; break;
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                    // TODO: up to 3 octal
                    break;
                case 'x':
                    ++i;
                    // TODO: closest hexes
                    break;
                case 'u':
                    ++i;
                    // TODO: 4 hexes
                    i += 3;
                    break;
                case 'U':
                    ++i;
                    // TODO: 8 hexes
                    i += 7;
                    break;
                default:
                    /* TODO error */;
            }
        } else if (yytext[i] == '?' && yytext[i+1] == '?' && istrigraphsuf(yytext[i+2])) {
            i += 2;
            switch (yytext[i]) {
                case '=': to_put = '#'; break;
                case '(': to_put = '['; break;
                case ')': to_put = ']'; break;
                case '\'': to_put = '^'; break;
                case '<': to_put = '{'; break;
                case '!': to_put = '|'; break;
                case '>': to_put = '}'; break;
                case '-': to_put = '~'; break;
                default: /* TODO error */;
            }
        } else {
            to_put = yytext[i];
        }
        res[j] = to_put;
        ++i;
        ++j;
    }
    res[j] = '\0';
    return res; // TODO
}

/// Is given character - trigraph suffix?
short istrigraphsuf(char c) {
    return c == '='  || c == '(' || c == '/' || c == ')'
        || c == '\'' || c == '<' || c == '!' || c == '>' || c == '-';
}

/// Change input after EOF was reached.
int yywrap() {
    return 1; // TODO change input on #include
}