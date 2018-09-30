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