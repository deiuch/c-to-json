/**
 * Lexer for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

%pointer

%x COMMENT
%x PREP
%x INCLUDE
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
WS        [ \f\n\r\t\v]

%{
#include <string.h>
#include "y.tab.h"
#include "typedef_name.h"

#define ERROR 256

void change_source(char *);
void shift_yytext(int);
char *readstr(char *, size_t);
_Bool is_trigraph_suf(char);

#define MAX_INCLUDE_DEPTH 20  // TODO check
typedef struct { FILE *file; YY_BUFFER_STATE buffer; int start_cond; } config;
config config_stack[MAX_INCLUDE_DEPTH];
int file_stack_ptr = 0;
%}

%%

^[ \t]*({HASH}|"%:")[ \t]* { BEGIN PREP; }
<PREP>"if"{PR_INS}      { BEGIN INITIAL; }
<PREP>"ifdef"{PR_INS}   { BEGIN INITIAL; }
<PREP>"ifndef"{PR_INS}  { BEGIN INITIAL; }
<PREP>"elif"{PR_INS}    { BEGIN INITIAL; }
<PREP>"else"{PR_INS}    { BEGIN INITIAL; }
<PREP>"endif"{PR_INS}   { BEGIN INITIAL; }
<PREP>"include"[ \t]*\" { BEGIN INCLUDE; }
<INCLUDE>[^"\n\r]*/\"   { change_source(yytext); }
<INCLUDE>[^"\n\r]*$     { BEGIN INITIAL; /* TODO error */ }
<INCLUDE>\"{WS}*$       { BEGIN INITIAL; }
<PREP>"define"{PR_INS}  { BEGIN INITIAL; }
<PREP>"undef"{PR_INS}   { BEGIN INITIAL; }
<PREP>"line"{PR_INS}    { BEGIN INITIAL; }
<PREP>"error"{PR_INS}   { BEGIN INITIAL; /* TODO error */ }
<PREP>"warning"{PR_INS} { BEGIN INITIAL; /* TODO warning, not in ISO/IEC 9899:2017 review */ }
<PREP>"pragma"{PR_INS}  { BEGIN INITIAL; }
<PREP>""$ {
    BEGIN INITIAL;
    if (yyleng > 0) /* TODO error */;
    /* TODO ISO/IEC 9899:2017, pages 117-127 or 344-345 */
}
<PREP>[^\n\r]           { yymore(); }

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
    yylval.id = (char *) malloc(strlen(yytext));
    strcpy(yylval.id, yytext);
    if (is_typedef_name(yytext)) return TYPEDEF_NAME;
    return IDENTIFIER;
    // TODO check Universal character name, ISO/IEC 9899:2017, page 44
}

0[Xx]{H}+{IS}?          |
0{O}+{IS}?              |
{D}+{IS}? {
    yylval.integer = (char *) malloc(sizeof(char) * yyleng);
    strcpy(yylval.integer, yytext);
    return INTEGER_CONSTANT;
    // TODO value conversion, ISO/IEC 9899:2017, page 45-46
}

{D}+{DE}{FS}?           |
{D}*"."{D}+{DE}?{FS}?   |
{D}+"."{D}*{DE}?{FS}?   |
0[Xx]{H}+{HE}{FS}?      |
0[Xx]{H}*"."{H}+{HE}?{FS}? |
0[Xx]{H}+"."{H}*{HE}?{FS}? {
    yylval.floating = (char *) malloc(sizeof(char) * yyleng);
    strcpy(yylval.floating, yytext);
    return FLOATING_CONSTANT;
    // TODO value conversion, ISO/IEC 9899:2017, page 47-48
}

[LUu]?'                 { BEGIN CHR; /* TODO prefix considering, ISO/IEC 9899:2017, page 48-50 */ }
(L|U|u|u8)?\"           { BEGIN STR; /* TODO prefix considering, ISO/IEC 9899:2017, page 50-52 */ }
<CHR>' {
    BEGIN INITIAL;
    char *content = readstr(yytext, yyleng);
    if (strlen(content) != 1) {
        // TODO error
    }
    yylval.character = content[0];
    return CHARACTER_CONSTANT;
}
<STR>\" {
    BEGIN INITIAL;
    yylval.string = readstr(yytext, yyleng);
    return STRING_LITERAL;
    // TODO UTF-8, ISO/IEC 9899:2017, page 50-52
}
<STR>\"{WS}*\" {
    int i;
    for (i = 2;; ++i) {
        if (yytext[yyleng - i] == '"') break;
    }
    shift_yytext(i);  // skip and retry TODO efficiency
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

<INITIAL,PREP,STR,CHR>[^ \f\n\r\t\v]*"??/"\r\n {
    shift_yytext(5);  // skip and retry
}
<INITIAL,PREP,STR,CHR>[^ \f\n\r\t\v]*"??/"[\r\n] {
    shift_yytext(4);  // skip and retry
}
<INITIAL,PREP,STR,CHR>[^ \f\n\r\t\v]*\\\r\n {
    shift_yytext(3);  // skip and retry
}
<INITIAL,PREP,STR,CHR>[^ \f\n\r\t\v]*\\[\n\r] {
    shift_yytext(2);  // skip and retry
}

<COMMENT,STR,CHR><<EOF>> { /* TODO error */ }
{WS}                    { /* skip over whitespaces */ }
.                       { /* TODO error */ }

%%

/// Change source file to read next.
void change_source(char *name)
{
    if (file_stack_ptr >= MAX_INCLUDE_DEPTH)
    {
        fprintf(stderr, "Includes nested too deeply");
        exit(1);
    }

    FILE *new_file = fopen(name, "r");
    if (!new_file) /* TODO error */;

    config_stack[file_stack_ptr++] = (config) {yyin, YY_CURRENT_BUFFER, YY_START};

    yyin = new_file;
    yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));
    BEGIN INITIAL;
}

/// Change input after EOF was reached.
int yywrap()
{
    if (--file_stack_ptr < 0) return 1;

    yy_delete_buffer(YY_CURRENT_BUFFER);
    fclose(yyin);

    config *old_conf = &config_stack[file_stack_ptr];
    yyin = old_conf->file;
    yy_switch_to_buffer(old_conf->buffer);
    BEGIN old_conf->start_cond;

    return 0;
}

void shift_yytext(int n)
{
    int i;
    for (i = yyleng - n - 1; i >= 0; --i) {
        unput(yytext[i]);
    }
}

/// Replace escapes in string literal. Needs to be freed.
char *readstr(char *inp, size_t len)
{
    size_t i = 0, j = 0;
    char to_put;
    char *res = (char *) malloc(sizeof(char) * (len - 1));
    while (i < len - 1)
    {
        if (yytext[i] == '\\' || yytext[i] == '?' && yytext[i+1] == '?' && yytext[i+2] == '/')
        {
            ++i;
            if (yytext[i-1] != '\\') i += 2;
            switch (yytext[i])
            {
                case '?':
                    if (yytext[i+1] == '?' && is_trigraph_suf(yytext[i+2]))
                    {
                        i += 2;
                        if (yytext[i] == '/')
                        {
                            to_put = '\\';
                        }
                        else
                        {
                            /* TODO error */;
                        }
                    }
                    else
                    {
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
                    to_put = '\x1A'; // TODO: up to 3 octal
                    break;
                case 'x':
                    ++i;
                    to_put = '\x1A'; // TODO: closest hexes
                    break;
                case 'u':
                    ++i;
                    to_put = '\x1A'; // TODO: 4 hexes
                    i += 3;
                    break;
                case 'U':
                    ++i;
                    to_put = '\x1A'; // TODO: 8 hexes
                    i += 7;
                    break;
                default:
                    /* TODO error */;
            }
        }
        else if (yytext[i] == '?' && yytext[i+1] == '?' && is_trigraph_suf(yytext[i+2]))
        {
            i += 2;
            switch (yytext[i])
            {
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
        }
        else
        {
            to_put = yytext[i];
        }
        res[j] = to_put;
        ++i;
        ++j;
    }
    res[j] = '\0';
    return res;
}

/// Is given character - trigraph suffix?
_Bool is_trigraph_suf(char c)
{
    return c == '='  || c == '(' || c == '/' || c == ')'
        || c == '\'' || c == '<' || c == '!' || c == '>' || c == '-';
}
