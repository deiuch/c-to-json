/**
 * Lexer for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov, Vladislav Kuleykin
 */

%pointer

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

/// Convert constant value to the corresponding AST node.
///
/// \param type Type of a new node
/// \param val Constant to put as content
/// \return New AST node for a given constant
AST_NODE *get_const_node(AST_NODE_TYPE type, char *val);

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
PR_INS    [ \t]+[^\n\r]*$
UCN       \\(u{H}{4}|U{H}{8})
ID        {ND}({ND}|{D}|{UCN})*
ESC       \\['"?\\abfnrtv]|\\{O}{1,3}|\\x{H}+|{UCN}
CHAR      [LUu]?'({ESC}|[^'\\\n\r])+'
STRL      ([LUu]|u8)?\"({ESC}|[^"\\\n\r])+\"
WS        [ \f\n\r\t\v]

%%

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
    char *lit = (char *) my_malloc(sizeof(char) * (yyleng + 1),
            "IDENTIFIER");
    strcpy(lit, yytext);
    yylval.node = get_const_node(Identifier, lit);
    if (is_typedef_name(yytext)) return TYPEDEF_NAME;
    return IDENTIFIER;
    // TODO check Universal character name, ISO/IEC 9899:2017, page 44
}

0[Xx]{H}+{IS}?          |
0{O}+{IS}?              |
{D}+{IS}? {
    char *lit = (char *) my_malloc(sizeof(char) * (yyleng + 1),
            "INTEGER_CONSTANT");
    strcpy(lit, yytext);
    yylval.node = get_const_node(IntegerConstant, lit);
    return CONSTANT;
    // TODO value conversion, ISO/IEC 9899:2017, page 45-46
}

{D}+{DE}{FS}?           |
{D}*"."{D}+{DE}?{FS}?   |
{D}+"."{D}*{DE}?{FS}?   |
0[Xx]{H}+{HE}{FS}?      |
0[Xx]{H}*"."{H}+{HE}?{FS}? |
0[Xx]{H}+"."{H}*{HE}?{FS}? {
    char *lit = (char *) my_malloc(sizeof(char) * (yyleng + 1),
            "FLOATING_CONSTANT");
    strcpy(lit, yytext);
    yylval.node = get_const_node(FloatingConstant, lit);
    return CONSTANT;
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
    char *lit = readstr();
    if (!lit || strlen(lit) != 1)
    {
        free(lit);
        return ERROR;  // TODO error message
    }
    yylval.node = get_const_node(CharacterConstant, lit);
    return CONSTANT;
    // TODO value conversion, UTF-8, ISO/IEC 9899:2017, page 50-52
}
<STR>\" {
    BEGIN INITIAL;
    char *lit = readstr();
    if (!lit)
    {
        free(lit);
        return ERROR;  // TODO error message
    }
    yylval.node = get_const_node(StringLiteral, lit);
    return STRING_LITERAL;
    // TODO UTF-8, ISO/IEC 9899:2017, page 50-52
}
<STR,CHR>{ESC}          { yymore(); }
<STR,CHR>.              { yymore(); }

"["|"<:"                { return LBRACKET; }
"]"|":>"                { return RBRACKET; }
"("                     { return LPAREN; }
")"                     { return RPAREN; }
"{"|"<%"                { return LBRACE; }
"}"|"%>"                { return RBRACE; }
"."                     { return DOT; }
"->"                    { return ARROW; }
"++"                    { return DBL_PLUS; }
"--"                    { return DBL_MINUS; }
"&"                     { return AMPERSAND; }
"*"                     { return ASTERISK; }
"+"                     { return PLUS; }
"-"                     { return MINUS; }
"~"                     { return TILDE; }
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
"^"                     { return CARET; }
"|"                     { return VERTICAL; }
"&&"                    { return LOG_AND; }
"||"                    { return LOG_OR; }
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
"^="                    { return XOR_ASSIGN; }
"|="                    { return OR_ASSIGN; }
","                     { return COMMA; }

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

AST_NODE *get_const_node(AST_NODE_TYPE type, char *val)
{
    AST_NODE *res = ast_create_node(type, (AST_CONTENT) {.value = val}, 0);
    return res;
}

char *readstr()
{
    size_t i = 0, j = 0;
    char to_put;
    char *res = (char *) my_malloc(sizeof(char) * (yyleng + 1),
            "STRING_LITERAL");
    while (i < yyleng - 1)
    {
        if (yytext[i] == '\\')
        {
            ++i;
            if (i == yyleng) return NULL;
            switch (yytext[i])
            {
                case '?':  to_put = '?'; break;
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
