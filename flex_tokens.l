/**
 * Lexer for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov, Vladislav Kuleykin
 */

%pointer

%x COMMENT
%x PREP
%x INCL_FL
%x INCL_ST
%x ERROR_S
%x WARNING
%x CHR
%x STR

%{
#include <string.h>
#include "alloc_wrap.h"
#include "typedef_name.h"
#include "ast.h"
#include "y.tab.h"

/// Token for the error notification.
#define ERROR 256

// Defined in `yacc_syntax.y'
extern int yyerror(const char *);

/// Print warning to user.
///
/// \param str Warning description to be printed
void yywarn(const char *);

/// Change input after EOF was reached.
/// NOTE: it is used by Flex.
///
/// \return 0 - new source is assigned, 1 - nothing more to read
int yywrap();

/// Change source file to read next.
///
/// \param name Name of new source file
void change_source(char *name);

/// Skip last `n' symbols and retry reading of a previous literal.
///
/// \param n Number of symbols to be dropped
void shift_yytext(int n);

/// Is given character - trigraph suffix?
///
/// \param c Character to be checked
/// \return `true' - it is one of trigraph endings, `false' - otherwise
_Bool is_trigraph_suf(char c);

/// Expand escapes in string literal from `yytext'. NOTE: Needs to be freed.
///
/// \return Expanded string
char *readstr();

// ISO/IEC 9899:2017, 5.2.4.1 Translation limits, page 20
/// Maximum depth of the `#include' directive.
#define MAX_INCLUDE_DEPTH 15

/// Current source configuration.
typedef struct
{
    FILE *file;
    YY_BUFFER_STATE buffer;
    int start_cond;
}
config;

/// Stack of source configurations.
config config_stack[MAX_INCLUDE_DEPTH];

/// Size of the stack of source configurations.
int file_stack_ptr = 0;
%}

O         [0-7]
D         [0-9]
H         [0-9A-Fa-f]
ND        [A-Za-z_]
DE        [Ee][+-]?{D}+
HE        [Pp][+-]?{D}+
LS        L|l|LL|ll
IS        [Uu]{LS}?|{LS}[Uu]?
FS        [FfLl]
HASH      "??="|"#"
LBRACKET  "??("|"["
BS        "??/"|"\\"
RBRACKET  "??)"|"]"
CARET     "??'"|"^"
LBRACE    "??<"|"{"
VERTICAL  "??!"|"|"
RBRACE    "??>"|"}"
TILDE     "??-"|"~"
PR_INS    [ \t]+[^\n\r]*$
NLE       {BS}(\n|\r|\r\n)
UCN       {BS}(u{H}{4}|U{H}{8})
ID        {ND}({ND}|{D}|{BS}u{H}{4}|{UCN})*
ESC       {BS}['"?\\abfnrtv]|{BS}"??/"|{BS}{O}{1,3}|{BS}x{H}+|{UCN}
CHAR      [LUu]?'({ESC}|[^'\\\n\r])+'
STRL      ([LUu]|u8)?\"({ESC}|[^"\\\n\r])+\"
WS        [ \f\n\r\t\v]

%%

^[ \t]*({HASH}|"%:")[ \t]* { BEGIN PREP; }

<PREP>"if"{PR_INS} {
    BEGIN INITIAL;
    yywarn("Everything inside `#if' will be processed "
        "considering condition as true! Syntax error may occur.");
}
<PREP>"ifdef"{PR_INS} {
    BEGIN INITIAL;
    yywarn("Everything inside `#ifdef' will be processed "
        "considering pointed one as defined! Syntax error may occur.");
}
<PREP>"ifndef"{PR_INS} {
    BEGIN INITIAL;
    yywarn("Everything inside `#ifndef' will be processed "
        "considering pointed one as not defined! Syntax error may occur.");
}
<PREP>"elif"{PR_INS} {
    BEGIN INITIAL;
    yywarn("Everything inside `#elif' will be processed "
        "considering condition as true! Syntax error may occur.");
}
<PREP>"else"[^\n\r]*$ {
    BEGIN INITIAL;
    yywarn("Everything inside `#else' will be processed "
        "considering previous condition as false! Syntax error may occur.");
}
<PREP>"endif"[^\n\r]*$  { BEGIN INITIAL; }

<PREP>"include"[ \t]*\" { BEGIN INCL_FL; }
<PREP>"include"[ \t]*<  { BEGIN INCL_ST; }
<INCL_ST>[^>\n\r]*/> {
    add_str_typedef(yytext);
    yywarn("Standard libraries included will not be considered by lexer!\n"
        "Only `typedef-name's described in ISO/IEC 9899:2018.");
}
<INCL_ST>[^>\n\r]*$ {
    BEGIN INITIAL;
    yyerror("Preprocessing error: Include name does not have a closing quote.");
}
<INCL_ST>>[ \t]*$       { BEGIN INITIAL; }
<INCL_FL>[^"\n\r]*/\"   { change_source(yytext); }
<INCL_FL>[^"\n\r]*$ {
    BEGIN INITIAL;
    yyerror("Preprocessing error: Include name does not have a closing quote.");
}
<INCL_FL>\"[ \t]*$      { BEGIN INITIAL; }

<PREP>"define"{PR_INS}  {
    BEGIN INITIAL;
    yywarn("Everything defined by `#define' will be processed "
        "considering no `#define' was used! Syntax error may occur.");
}
<PREP>"undef"{PR_INS}   { BEGIN INITIAL; }

<PREP>"line"{PR_INS}    { BEGIN INITIAL; /* TODO change source notification */ }
<PREP>"error"{WS}*      { BEGIN ERROR_S; }
<ERROR_S>[^\n\r]*$ {
    BEGIN INITIAL;
    yyerror(yytext);
}
<PREP>"warning"{WS}*    { BEGIN WARNING; /* not in ISO/IEC 9899:2017 */ }
<WARNING>[^\n\r]*$ {
    BEGIN INITIAL;
    yywarn(yytext);
}
<PREP>"pragma"{PR_INS}  { BEGIN INITIAL; /* TODO compiler pragmas */ }

<PREP>""$ {
    BEGIN INITIAL;
    if (yyleng > 0)
    {
        yyerror("Preprocessing error: Wrong preprocessing content found!");
    }
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
    yylval.id = (char *) my_malloc(sizeof(char) * (yyleng + 1),
            "IDENTIFIER");
    strcpy(yylval.id, yytext);
    if (is_typedef_name(yytext)) return TYPEDEF_NAME;
    return IDENTIFIER;
    // TODO check Universal character name, ISO/IEC 9899:2017, page 44
}

0[Xx]{H}+{IS}?          |
0{O}+{IS}?              |
{D}+{IS}? {
    yylval.integer = (char *) my_malloc(sizeof(char) * (yyleng + 1),
            "INTEGER_CONSTANT");
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
    yylval.floating = (char *) my_malloc(sizeof(char) * (yyleng + 1),
            "FLOATING_CONSTANT");
    strcpy(yylval.floating, yytext);
    return FLOATING_CONSTANT;
    // TODO value conversion, ISO/IEC 9899:2017, page 47-48
}

[LUu]?' {
    BEGIN CHR;
    /* TODO prefix considering, ISO/IEC 9899:2017, page 48-50 */
}
(L|U|u|u8)?\" {
    BEGIN STR;
    /* TODO prefix considering, ISO/IEC 9899:2017, page 50-52 */
}
<CHR>' {
    BEGIN INITIAL;
    char *content = readstr();
    if (!yylval.string || strlen(content) != 1) {
        return ERROR;  // TODO error message
    }
    yylval.character = content;
    return CHARACTER_CONSTANT;
    // TODO UTF-8, ISO/IEC 9899:2017, page 50-52
}
<STR>\" {
    BEGIN INITIAL;
    yylval.string = readstr();
    if (!yylval.string)
    {
        return ERROR;  // TODO error message
    }
    return STRING_LITERAL;
    // TODO UTF-8, ISO/IEC 9899:2017, page 50-52
}
<STR>\"{WS}*\" {
    int i;
    for (i = 2;; ++i) {
        if (yytext[yyleng - i] == '"') break;
    }
    shift_yytext(i);  // Skip and retry
}
<STR,CHR>{ESC}          { yymore(); }
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

<COMMENT,STR,CHR><<EOF>> { return ERROR; /* TODO error message */ }
{WS}                    { /* skip over whitespaces */ }
.                       { return ERROR; /* TODO error message */ }

%%

void yywarn(const char *str)
{
    fprintf(stderr, "WARNING: %s\n", str);
}

int yywrap()
{
    if (--file_stack_ptr < 0) return 1;

    yy_delete_buffer(YY_CURRENT_BUFFER);
    int res = fclose(yyin);
    if (res == EOF){
        fprintf(stderr, "Cannot close opened source file!\n");
        exit(3);
    }

    config *old_conf = &config_stack[file_stack_ptr];
    yyin = old_conf->file;
    yy_switch_to_buffer(old_conf->buffer);
    BEGIN old_conf->start_cond;

    return 0;
}

void change_source(char *name)
{
    if (file_stack_ptr >= MAX_INCLUDE_DEPTH)
    {
        fprintf(stderr,
            "Includes nested too deeply (more than %d)\n", MAX_INCLUDE_DEPTH);
        exit(1);
    }

    FILE *new_file = fopen(name, "r");
    if (!new_file)
    {
        fprintf(stderr, "Cannot open for reading: %s\n", name);
        exit(3);
    }

    config_stack[file_stack_ptr++] = (config) {yyin, YY_CURRENT_BUFFER, YY_START};

    yyin = new_file;
    yy_switch_to_buffer(yy_create_buffer(yyin, YY_BUF_SIZE));
    BEGIN INITIAL;
}

void shift_yytext(int n)
{
    int i;
    for (i = yyleng - n - 1; i >= 0; --i) {
        unput(yytext[i]);
    }
}

_Bool is_trigraph_suf(char c)
{
    return c == '='  || c == '(' || c == '/' || c == ')'
        || c == '\'' || c == '<' || c == '!' || c == '>' || c == '-';
}

char *readstr()
{
    size_t i = 0, j = 0;
    char to_put;
    char *res = (char *) my_malloc(sizeof(char) * yyleng,
            "STRING_LITERAL");
    while (i < yyleng - 1)
    {
        if (yytext[i] == '\\' || yytext[i] == '?' && yytext[i+1] == '?' && yytext[i+2] == '/')
        {
            ++i;
            if (yytext[i-1] != '\\') i += 2;
            if (i == yyleng) return NULL;
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
                            return NULL;
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
                    return NULL;
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
                default: return NULL;
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
    res[i] = '\0';
    return res;
}
