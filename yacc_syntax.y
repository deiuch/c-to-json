%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yydebug;  // TODO: REMOVE IN PROD, 'yacc' it with -t flag.
extern int yylex();
char const *yyerror(const char *str);
%}

%expect 0  // For expected amount of conflicts

%start TranslationUnit

//%union

%token AUTO
%token BREAK
%token CASE
%token CHAR
%token CONST
%token CONTINUE
%token DEFAULT
%token DO
%token DOUBLE
%token ELSE
%token ENUM
%token EXTERN
%token FLOAT
%token FOR
%token GOTO
%token IF
%token INLINE
%token INT
%token LONG
%token REGISTER
%token RESTRICT
%token RETURN
%token SHORT
%token SIGNED
%token SIZEOF
%token STATIC
%token STRUCT
%token SWITCH
%token TYPEDEF
%token UNION
%token UNSIGNED
%token VOID
%token VOLATILE
%token WHILE
%token ALIGNAS
%token ALIGNOF
%token ATOMIC
%token BOOL
%token COMPLEX
%token GENERIC
%token IMAGINARY
%token NORETURN
%token STATIC_ASSERT
%token THREAD_LOCAL

%token IDENTIFIER
%token CONSTANT
%token STRING_LITERAL

%token LBRACKET
%token RBRACKET
%token LPAREN
%token RPAREN
%token LBRACE
%token RBRACE
%token DOT
%token ARROW
%token DBL_PLUS
%token DBL_MINUS
%token AMPERSAND
%token ASTERISK
%token PLUS
%token MINUS
%token TILDE
%token BANG
%token SLASH
%token PERCENT
%token LSHIFT
%token RSHIFT
%token LS
%token GR
%token LE
%token GE
%token EQ
%token NE
%token CARET
%token VERTICAL
%token LOG_AND
%token LOG_OR
%token QUESTION
%token COLON
%token SEMICOLON
%token ELLIPSIS
%token ASSIGN
%token MUL_ASSIGN
%token DIV_ASSIGN
%token MOD_ASSIGN
%token ADD_ASSIGN
%token SUB_ASSIGN
%token LEFT_ASSIGN
%token RIGHT_ASSIGN
%token AND_ASSIGN
%token XOR_ASSIGN
%token OR_ASSIGN
%token COMMA

//%prec TODO ISO/IEC 9899:2017, page 385

%%

TranslationUnit
        : /* empty */
        | error
        | TranslationUnit AUTO { printf("AUTO\n"); }
        | TranslationUnit BREAK { printf("BREAK\n"); }
        | TranslationUnit CASE { printf("CASE\n"); }
        | TranslationUnit CHAR { printf("CHAR\n"); }
        | TranslationUnit CONST { printf("CONST\n"); }
        | TranslationUnit CONTINUE { printf("CONTINUE\n"); }
        | TranslationUnit DEFAULT { printf("DEFAULT\n"); }
        | TranslationUnit DO { printf("DO\n"); }
        | TranslationUnit DOUBLE { printf("DOUBLE\n"); }
        | TranslationUnit ELSE { printf("ELSE\n"); }
        | TranslationUnit ENUM { printf("ENUM\n"); }
        | TranslationUnit EXTERN { printf("EXTERN\n"); }
        | TranslationUnit FLOAT { printf("FLOAT\n"); }
        | TranslationUnit FOR { printf("FOR\n"); }
        | TranslationUnit GOTO { printf("GOTO\n"); }
        | TranslationUnit IF { printf("IF\n"); }
        | TranslationUnit INLINE { printf("INLINE\n"); }
        | TranslationUnit INT { printf("INT\n"); }
        | TranslationUnit LONG { printf("LONG\n"); }
        | TranslationUnit REGISTER { printf("REGISTER\n"); }
        | TranslationUnit RESTRICT { printf("RESTRICT\n"); }
        | TranslationUnit RETURN { printf("RETURN\n"); }
        | TranslationUnit SHORT { printf("SHORT\n"); }
        | TranslationUnit SIGNED { printf("SIGNED\n"); }
        | TranslationUnit SIZEOF { printf("SIZEOF\n"); }
        | TranslationUnit STATIC { printf("STATIC\n"); }
        | TranslationUnit STRUCT { printf("STRUCT\n"); }
        | TranslationUnit SWITCH { printf("SWITCH\n"); }
        | TranslationUnit TYPEDEF { printf("TYPEDEF\n"); }
        | TranslationUnit UNION { printf("UNION\n"); }
        | TranslationUnit UNSIGNED { printf("UNSIGNED\n"); }
        | TranslationUnit VOID { printf("VOID\n"); }
        | TranslationUnit VOLATILE { printf("VOLATILE\n"); }
        | TranslationUnit WHILE { printf("WHILE\n"); }
        | TranslationUnit ALIGNAS { printf("ALIGNAS\n"); }
        | TranslationUnit ALIGNOF { printf("ALIGNOF\n"); }
        | TranslationUnit ATOMIC { printf("ATOMIC\n"); }
        | TranslationUnit BOOL { printf("BOOL\n"); }
        | TranslationUnit COMPLEX { printf("COMPLEX\n"); }
        | TranslationUnit GENERIC { printf("GENERIC\n"); }
        | TranslationUnit IMAGINARY { printf("IMAGINARY\n"); }
        | TranslationUnit NORETURN { printf("NORETURN\n"); }
        | TranslationUnit STATIC_ASSERT { printf("STATIC_ASSERT\n"); }
        | TranslationUnit THREAD_LOCAL { printf("THREAD_LOCAL\n"); }
        | TranslationUnit IDENTIFIER { printf("IDENTIFIER\n"); }
        | TranslationUnit CONSTANT { printf("CONSTANT\n"); }
        | TranslationUnit STRING_LITERAL { printf("STRING_LITERAL\n"); }
        | TranslationUnit LBRACKET { printf("LBRACKET\n"); }
        | TranslationUnit RBRACKET { printf("RBRACKET\n"); }
        | TranslationUnit LPAREN { printf("LPAREN\n"); }
        | TranslationUnit RPAREN { printf("RPAREN\n"); }
        | TranslationUnit LBRACE { printf("LBRACE\n"); }
        | TranslationUnit RBRACE { printf("RBRACE\n"); }
        | TranslationUnit DOT { printf("DOT\n"); }
        | TranslationUnit ARROW { printf("ARROW\n"); }
        | TranslationUnit DBL_PLUS { printf("DBL_PLUS\n"); }
        | TranslationUnit DBL_MINUS { printf("DBL_MINUS\n"); }
        | TranslationUnit AMPERSAND { printf("AMPERSAND\n"); }
        | TranslationUnit ASTERISK { printf("ASTERISK\n"); }
        | TranslationUnit PLUS { printf("PLUS\n"); }
        | TranslationUnit MINUS { printf("MINUS\n"); }
        | TranslationUnit TILDE { printf("TILDE\n"); }
        | TranslationUnit BANG { printf("BANG\n"); }
        | TranslationUnit SLASH { printf("SLASH\n"); }
        | TranslationUnit PERCENT { printf("PERCENT\n"); }
        | TranslationUnit LSHIFT { printf("LSHIFT\n"); }
        | TranslationUnit RSHIFT { printf("RSHIFT\n"); }
        | TranslationUnit LS { printf("LS\n"); }
        | TranslationUnit GR { printf("GR\n"); }
        | TranslationUnit LE { printf("LE\n"); }
        | TranslationUnit GE { printf("GE\n"); }
        | TranslationUnit EQ { printf("EQ\n"); }
        | TranslationUnit NE { printf("NE\n"); }
        | TranslationUnit CARET { printf("CARET\n"); }
        | TranslationUnit VERTICAL { printf("VERTICAL\n"); }
        | TranslationUnit LOG_AND { printf("LOG_AND\n"); }
        | TranslationUnit LOG_OR { printf("LOG_OR\n"); }
        | TranslationUnit QUESTION { printf("QUESTION\n"); }
        | TranslationUnit COLON { printf("COLON\n"); }
        | TranslationUnit SEMICOLON { printf("SEMICOLON\n"); }
        | TranslationUnit ELLIPSIS { printf("ELLIPSIS\n"); }
        | TranslationUnit ASSIGN { printf("ASSIGN\n"); }
        | TranslationUnit MUL_ASSIGN { printf("MUL_ASSIGN\n"); }
        | TranslationUnit DIV_ASSIGN { printf("DIV_ASSIGN\n"); }
        | TranslationUnit MOD_ASSIGN { printf("MOD_ASSIGN\n"); }
        | TranslationUnit ADD_ASSIGN { printf("ADD_ASSIGN\n"); }
        | TranslationUnit SUB_ASSIGN { printf("SUB_ASSIGN\n"); }
        | TranslationUnit LEFT_ASSIGN { printf("LEFT_ASSIGN\n"); }
        | TranslationUnit RIGHT_ASSIGN { printf("RIGHT_ASSIGN\n"); }
        | TranslationUnit AND_ASSIGN { printf("AND_ASSIGN\n"); }
        | TranslationUnit XOR_ASSIGN { printf("XOR_ASSIGN\n"); }
        | TranslationUnit OR_ASSIGN { printf("OR_ASSIGN\n"); }
        | TranslationUnit COMMA { printf("COMMA\n"); }
        ;

// TODO ISO/IEC 9899:2017, pages 75-135 or 353-363
// http://www.open-std.org/jtc1/sc22/wg14/www/abq/c17_updated_proposed_fdis.pdf

%%

/// Called when parse error was detected.
char const *yyerror(const char *str)
{
    fprintf(stderr, "yyerror: %s\n", str);
}

/// Program entry point.
int main()
{
    yydebug = 1;  // TODO: REMOVE IN PROD, set 0 for no debug info.
    return yyparse();
}