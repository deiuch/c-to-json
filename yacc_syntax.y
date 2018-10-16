/**
 * Parser for C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 *
 * Source (ISO/IEC 9899:2017, no critical changes were applied in :2018):
 * http://www.open-std.org/jtc1/sc22/wg14/www/abq/c17_updated_proposed_fdis.pdf
 *
 * Not for commercial use.
 */

%expect    0  // shift/reduce
%expect-rr 0  // reduce/reduce
//%lex-param {}
//%parse-param {}
//%pure-parser

%{
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "alloc_wrap.h"
#include "ast.h"
#include "string_tools.h"
#include "typedef_name.h"
#include "y.tab.h"

#define content_t(v)  ((AST_CONTENT) {.token = v})
#define content_null  ((AST_CONTENT) {.value = NULL})

/// Get next token from the specified input.
///
/// \return Next token of the source
extern int yylex();

/// Was error already found?
_Bool error_found = false;

/// Called when parse error was detected.
///
/// \param str Error description to be printed
/// \return Always 0
int yyerror(const char *str);

/// Does this node contains TYPEDEF token?
///
/// \param node AST Node of `DeclarationSpecifiers' to search trough
/// \return `true' - TYPEDEF is found, `false' - otherwise
_Bool is_typedef_used(AST_NODE *node);

/// Collect all the identifiers (DirectDeclarators) from this node.
///
/// \param node AST Node of `InitDeclaratorList' to collect from
void collect_typedef_names(AST_NODE *node);
%}

%start TranslationUnit

%union
{
    AST_NODE *node;
    _Bool boolean_v;
}

// Keywords
// ISO/IEC 9899:2017, 6.4.1 Keywords, page 42
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

/*
 *  NOTE:
 *  This nonterminal was introduced
 *  in order to deal with reduce/reduce
 *  conflict of TypedefName with PrimaryExpression.
 *  Lexical analyzer should make distinction
 *  between this token and IDENTIFIER.
 *
 *  ISO/IEC 9899:2017, 6.7.8 Type definitions, pages 99-100
 */
%token <node> TYPEDEF_NAME

// Literals
// ISO/IEC 9899:2017, 6.4.2 and 6.4.4, pages 43-52
%token <node> IDENTIFIER
%token <node> CONSTANT
%token <node> STRING_LITERAL

// Punctuators
// ISO/IEC 9899:2017, 6.4.6 Punctuators, page 52
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

%type <node>      TranslationUnit
%type <node>      ExternalDeclaration
%type <node>      FunctionDefinition
%type <node>      DeclarationList
%type <node>      Declaration
%type <node>      DeclarationSpecifiers
%type <node>      InitDeclaratorList
%type <node>      InitDeclarator
%type <node>      StorageClassSpecifier
%type <node>      TypeSpecifier
%type <node>      StructOrUnionSpecifier
%type <boolean_v> StructOrUnion
%type <node>      StructDeclarationList
%type <node>      StructDeclaration
%type <node>      SpecifierQualifierList
%type <node>      StructDeclaratorList
%type <node>      StructDeclarator
%type <node>      EnumSpecifier
%type <node>      EnumeratorList
%type <node>      Enumerator
%type <node>      AtomicTypeSpecifier
%type <node>      TypeQualifier
%type <node>      FunctionSpecifier
%type <node>      AlignmentSpecifier
%type <node>      Declarator
%type <node>      DirectDeclarator
%type <node>      Pointer
%type <node>      TypeQualifierList
%type <node>      ParameterTypeList
%type <node>      ParameterList
%type <node>      ParameterDeclaration
%type <node>      IdentifierList
%type <node>      TypeName
%type <node>      AbstractDeclarator
%type <node>      DirectAbstractDeclarator
%type <node>      TypedefName
%type <node>      Initializer
%type <node>      InitializerList
%type <node>      Designation
%type <node>      DesignatorList
%type <node>      Designator
%type <node>      StaticAssertDeclaration
%type <node>      Statement
%type <node>      LabeledStatement
%type <node>      CompoundStatement
%type <node>      BlockItemList
%type <node>      BlockItem
%type <node>      ExpressionStatement
%type <node>      SelectionStatement
%type <node>      IterationStatement
%type <node>      JumpStatement
%type <node>      ConstantExpression
%type <node>      ExpressionOpt
%type <node>      Expression
%type <node>      AssignmentExpression
%type <node>      AssignmentOperator
%type <node>      ConditionalExpression
%type <node>      ArithmeticalExpression
%type <node>      CastExpression
%type <node>      UnaryExpression
%type <node>      UnaryOperator
%type <node>      PostfixExpression
%type <node>      ArgumentExpressionList
%type <node>      PrimaryExpression
%type <node>      GenericSelection
%type <node>      GenericAssocList
%type <node>      GenericAssociation

// *** PRECEDENCE ASSIGNMENT ***

// Lower precedence

// _Atomic type shift/reduce resolution
// ISO/IEC 9899:2017, 6.7.2.4 Atomic type specifiers (Semantics), page 87
%nonassoc ATOMIC
%nonassoc LPAREN

// "Dangling Else" shift/reduce resolution
// ISO/IEC 9899:2017, 6.8.4.1 The if statement (Semantics), page 108
%nonassoc NO_ELSE  // Fake token for precedence
%nonassoc ELSE

// Expression precedence
// ISO/IEC 9899:2017, 6.5.5-6.5.14 Expressions, pages 66-71
%left LOG_OR                  // Logical OR
%left LOG_AND                 // Logical AND
%left VERTICAL                // Inclusive OR
%left CARET                   // Exclusive OR
%left AMPERSAND               // AND
%left EQ NE                   // Equality
%left LS GR LE GE             // Relational
%left LSHIFT RSHIFT           // Shift
%left PLUS MINUS              // Additive
%left ASTERISK SLASH PERCENT  // Multiplicative

// Higher precedence

%%

// ISO/IEC 9899:2017, 6.9 External definitions, pages 113-116

TranslationUnit
        :                 ExternalDeclaration
        {
            if (!error_found)
            {
                ast_root = ast_create_node(TranslationUnit, content_null, 1, $1);
            }
        }
        | TranslationUnit ExternalDeclaration
        {
            if (!error_found)
            {
                ast_root = ast_expand_node(ast_root, $2);
            }
        }
        ;

ExternalDeclaration
        : FunctionDefinition  { $$ = $1; }
        | Declaration         { $$ = $1; }
        ;

FunctionDefinition
        : DeclarationSpecifiers Declarator                 CompoundStatement
        {
            $$ = ast_create_node(FunctionDefinition, content_null, 3, $1, $2, $3);
        }
        | DeclarationSpecifiers Declarator DeclarationList CompoundStatement
        {
            $$ = ast_create_node(FunctionDefinition, content_null, 4, $1, $2, $3, $4);
        }
        ;

DeclarationList
        :                 Declaration
        {
            $$ = ast_create_node(DeclarationList, content_null, 1, $1);
        }
        | DeclarationList Declaration
        {
            $$ = ast_expand_node($1, $2);
        }
        ;

// ISO/IEC 9899:2017, 6.7 Declarations, pages 78-105

Declaration
        : DeclarationSpecifiers                    SEMICOLON
        {
            $$ = ast_create_node(Declaration, content_null, 1, $1);
        }
        | DeclarationSpecifiers InitDeclaratorList SEMICOLON
        {
            if (is_typedef_used($1)) collect_typedef_names($2);  // Storing typedef-name
            $$ = ast_create_node(Declaration, content_null, 2, $1, $2);
        }
        | StaticAssertDeclaration  { $$ = $1; }
        ;

DeclarationSpecifiers
        : StorageClassSpecifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, content_null, 1, $1);
        }
        | TypeSpecifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, content_null, 1, $1);
        }
        | TypeQualifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, content_null, 1, $1);
        }
        | FunctionSpecifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, content_null, 1, $1);
        }
        | AlignmentSpecifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, content_null, 1, $1);
        }
        | StorageClassSpecifier DeclarationSpecifiers
        {
            $$ = ast_expand_node($2, $1);
        }
        | TypeSpecifier         DeclarationSpecifiers
        {
            $$ = ast_expand_node($2, $1);
        }
        | TypeQualifier         DeclarationSpecifiers
        {
            $$ = ast_expand_node($2, $1);
        }
        | FunctionSpecifier     DeclarationSpecifiers
        {
            $$ = ast_expand_node($2, $1);
        }
        | AlignmentSpecifier    DeclarationSpecifiers
        {
            $$ = ast_expand_node($2, $1);
        }
        ;

InitDeclaratorList
        :                          InitDeclarator
        {
            $$ = ast_create_node(InitDeclaratorList, content_null, 1, $1);
        }
        | InitDeclaratorList COMMA InitDeclarator
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

InitDeclarator
        : Declarator
        {
            $$ = ast_create_node(InitDeclarator, content_null, 1, $1);
        }
        | Declarator ASSIGN Initializer
        {
            $$ = ast_create_node(InitDeclarator, content_null, 2, $1, $3);
        }
        ;

StorageClassSpecifier
        : TYPEDEF       { $$ = ast_create_node(StorageClassSpecifier, content_t(TYPEDEF), 0); }
        | EXTERN        { $$ = ast_create_node(StorageClassSpecifier, content_t(EXTERN), 0); }
        | STATIC        { $$ = ast_create_node(StorageClassSpecifier, content_t(STATIC), 0); }
        | THREAD_LOCAL  { $$ = ast_create_node(StorageClassSpecifier, content_t(THREAD_LOCAL), 0); }
        | AUTO          { $$ = ast_create_node(StorageClassSpecifier, content_t(AUTO), 0); }
        | REGISTER      { $$ = ast_create_node(StorageClassSpecifier, content_t(REGISTER), 0); }
        ;

TypeSpecifier
        : VOID       { $$ = ast_create_node(TypeSpecifier, content_t(VOID), 0); }
        | CHAR       { $$ = ast_create_node(TypeSpecifier, content_t(CHAR), 0); }
        | SHORT      { $$ = ast_create_node(TypeSpecifier, content_t(SHORT), 0); }
        | INT        { $$ = ast_create_node(TypeSpecifier, content_t(INT), 0); }
        | LONG       { $$ = ast_create_node(TypeSpecifier, content_t(LONG), 0); }
        | FLOAT      { $$ = ast_create_node(TypeSpecifier, content_t(FLOAT), 0); }
        | DOUBLE     { $$ = ast_create_node(TypeSpecifier, content_t(DOUBLE), 0); }
        | SIGNED     { $$ = ast_create_node(TypeSpecifier, content_t(SIGNED), 0); }
        | UNSIGNED   { $$ = ast_create_node(TypeSpecifier, content_t(UNSIGNED), 0); }
        | BOOL       { $$ = ast_create_node(TypeSpecifier, content_t(BOOL), 0); }
        | COMPLEX    { $$ = ast_create_node(TypeSpecifier, content_t(COMPLEX), 0); }
        | IMAGINARY  { $$ = ast_create_node(TypeSpecifier, content_t(IMAGINARY), 0); }
        | AtomicTypeSpecifier     { $$ = $1; }
        | StructOrUnionSpecifier  { $$ = $1; }
        | EnumSpecifier           { $$ = $1; }
        | TypedefName             { $$ = $1; }
        ;

StructOrUnionSpecifier
        : StructOrUnion            LBRACE StructDeclarationList RBRACE
        {
            $$ = ast_create_node($1 ? StructSpecifier : UnionSpecifier, content_null, 1, $3);
        }
        | StructOrUnion IDENTIFIER LBRACE StructDeclarationList RBRACE
        {
            $$ = ast_create_node($1 ? StructSpecifier : UnionSpecifier, content_null, 2, $2, $4);
        }
        | StructOrUnion IDENTIFIER
        {
            $$ = ast_create_node($1 ? StructSpecifier : UnionSpecifier, content_null, 1, $2);
        }
        ;

StructOrUnion
        : STRUCT  { $$ = true; }
        | UNION   { $$ = false; }
        ;

StructDeclarationList
        :                       StructDeclaration
        {
            $$ = ast_create_node(StructDeclarationList, content_null, 1, $1);
        }
        | StructDeclarationList StructDeclaration
        {
            $$ = ast_expand_node($1, $2);
        }
        ;

StructDeclaration
        : SpecifierQualifierList                      SEMICOLON
        {
            $$ = ast_create_node(StructDeclaration, content_null, 1, $1);
        }
        | SpecifierQualifierList StructDeclaratorList SEMICOLON
        {
            $$ = ast_create_node(StructDeclaration, content_null, 2, $1, $2);
        }
        | StaticAssertDeclaration  { $$ = $1; }
        ;

SpecifierQualifierList
        : TypeSpecifier
        {
            $$ = ast_create_node(SpecifierQualifierList, content_null, 1, $1);
        }
        | TypeQualifier
        {
            $$ = ast_create_node(SpecifierQualifierList, content_null, 1, $1);
        }
        | AlignmentSpecifier
        {
            $$ = ast_create_node(SpecifierQualifierList, content_null, 1, $1);
        }
        | TypeSpecifier      SpecifierQualifierList
        {
            $$ = ast_expand_node($2, $1);
        }
        | TypeQualifier      SpecifierQualifierList
        {
            $$ = ast_expand_node($2, $1);
        }
        | AlignmentSpecifier SpecifierQualifierList
        {
            $$ = ast_expand_node($2, $1);
        }
        ;

StructDeclaratorList
        :                            StructDeclarator
        {
            $$ = ast_create_node(StructDeclaratorList, content_null, 1, $1);
        }
        | StructDeclaratorList COMMA StructDeclarator
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

StructDeclarator
        : Declarator                           { $$ = $1; }
        |            COLON ConstantExpression  { $$ = $2; }
        | Declarator COLON ConstantExpression
        {
            $$ = ast_create_node(StructDeclarator, content_null, 2, $1, $3);
        }
        ;

EnumSpecifier
        : ENUM            LBRACE EnumeratorList       RBRACE
        {
            $$ = ast_create_node(EnumSpecifier, content_null, 1, $3);
        }
        | ENUM            LBRACE EnumeratorList COMMA RBRACE
        {
            $$ = ast_create_node(EnumSpecifier, content_null, 1, $3);
        }
        | ENUM IDENTIFIER LBRACE EnumeratorList       RBRACE
        {
            $$ = ast_create_node(EnumSpecifier, content_null, 2, $2, $4);
        }
        | ENUM IDENTIFIER LBRACE EnumeratorList COMMA RBRACE
        {
            $$ = ast_create_node(EnumSpecifier, content_null, 2, $2, $4);
        }
        | ENUM IDENTIFIER
        {
            $$ = ast_create_node(EnumSpecifier, content_null, 1, $2);
        }
        ;

EnumeratorList
        :                      Enumerator
        {
            $$ = ast_create_node(EnumeratorList, content_null, 1, $1);
        }
        | EnumeratorList COMMA Enumerator
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

Enumerator
        : IDENTIFIER  // EnumerationConstant, reduce/reduce with PrimaryExpression
        {
            $$ = ast_create_node(Enumerator, content_null, 1, $1);
        }
        | IDENTIFIER ASSIGN ConstantExpression
        {
            $$ = ast_create_node(Enumerator, content_null, 2, $1, $3);
        }
        ;

AtomicTypeSpecifier
        : ATOMIC LPAREN TypeName RPAREN
        {
            $$ = ast_create_node(AtomicTypeSpecifier, content_null, 1, $3);
        }
        ;

TypeQualifier
        : CONST     { $$ = ast_create_node(TypeQualifier, content_t(CONST), 0); }
        | RESTRICT  { $$ = ast_create_node(TypeQualifier, content_t(RESTRICT), 0); }
        | VOLATILE  { $$ = ast_create_node(TypeQualifier, content_t(VOLATILE), 0); }
        | ATOMIC    { $$ = ast_create_node(TypeQualifier, content_t(ATOMIC), 0); }
        ;

FunctionSpecifier
        : INLINE    { $$ = ast_create_node(FunctionSpecifier, content_t(INLINE), 0); }
        | NORETURN  { $$ = ast_create_node(FunctionSpecifier, content_t(NORETURN), 0); }
        ;

AlignmentSpecifier
        : ALIGNAS LPAREN TypeName           RPAREN
        {
            $$ = ast_create_node(AlignmentSpecifier, content_null, 1, $3);
        }
        | ALIGNAS LPAREN ConstantExpression RPAREN
        {
            $$ = ast_create_node(AlignmentSpecifier, content_null, 1, $3);
        }
        ;

Declarator
        :         DirectDeclarator
        {
            $$ = ast_create_node(Declarator, content_null, 1, $1);
        }
        | Pointer DirectDeclarator
        {
            $$ = ast_create_node(Declarator, content_null, 2, $1, $2);
        }
        ;

DirectDeclarator
        : IDENTIFIER
        {
            $$ = ast_create_node(DirectDeclarator, content_null, 1, $1);
        }
        | LPAREN Declarator RPAREN
        {
            $$ = ast_create_node(DirectDeclarator, content_t(LPAREN), 1, $2);
        }
        | DirectDeclarator LBRACKET                                               RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_null, 0));
        }
        | DirectDeclarator LBRACKET                          AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_null, 1, $3));
        }
        | DirectDeclarator LBRACKET TypeQualifierList                             RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_null, 1, $3));
        }
        | DirectDeclarator LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_null, 2, $3, $4));
        }
        | DirectDeclarator LBRACKET                   STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_t(STATIC), 1, $4));
        }
        | DirectDeclarator LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_t(STATIC), 2, $4, $5));
        }
        | DirectDeclarator LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_t(STATIC), 2, $3, $5));
        }
        | DirectDeclarator LBRACKET                   ASTERISK                    RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_t(ASTERISK), 0));
        }
        | DirectDeclarator LBRACKET TypeQualifierList ASTERISK                    RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, content_t(ASTERISK), 1, $3));
        }
        | DirectDeclarator LPAREN ParameterTypeList RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorParen, content_null, 1, $3));
        }
        | DirectDeclarator LPAREN                   RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorParen, content_null, 0));
        }
        | DirectDeclarator LPAREN IdentifierList    RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorParen, content_null, 1, $3));
        }
        ;

Pointer
        : ASTERISK
        {
            $$ = ast_create_node(Pointer, content_null, 0);
        }
        | ASTERISK TypeQualifierList
        {
            $$ = ast_create_node(Pointer, content_null, 1, $2);
        }
        | ASTERISK                   Pointer
        {
            $$ = ast_expand_node(ast_create_node(Pointer, content_null, 0), $2);
        }
        | ASTERISK TypeQualifierList Pointer
        {
            $$ = ast_expand_node(ast_create_node(Pointer, content_null, 1, $2), $3);
        }
        ;

TypeQualifierList
        :                   TypeQualifier
        {
            $$ = ast_create_node(TypeQualifierList, content_null, 1, $1);
        }
        | TypeQualifierList TypeQualifier
        {
            $$ = ast_expand_node($1, $2);
        }
        ;

ParameterTypeList
        : ParameterList  { $$ = $1; }
        | ParameterList COMMA ELLIPSIS
        {
            $1->content = content_t(ELLIPSIS);
            $$ = $1;
        }
        ;

ParameterList
        :                     ParameterDeclaration
        {
            $$ = ast_create_node(ParameterList, content_null, 1, $1);
        }
        | ParameterList COMMA ParameterDeclaration
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

ParameterDeclaration
        : DeclarationSpecifiers Declarator
        {
            $$ = ast_create_node(ParameterDeclaration, content_null, 2, $1, $2);
        }
        | DeclarationSpecifiers
        {
            $$ = ast_create_node(ParameterDeclaration, content_null, 1, $1);
        }
        | DeclarationSpecifiers AbstractDeclarator
        {
            $$ = ast_create_node(ParameterDeclaration, content_null, 2, $1, $2);
        }
        ;

IdentifierList
        :                      IDENTIFIER
        {
            $$ = ast_create_node(IdentifierList, content_null, 1, $1);
        }
        | IdentifierList COMMA IDENTIFIER
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

TypeName
        : SpecifierQualifierList
        {
            $$ = ast_create_node(TypeName, content_null, 1, $1);
        }
        | SpecifierQualifierList AbstractDeclarator
        {
            $$ = ast_create_node(TypeName, content_null, 2, $1, $2);
        }
        ;

AbstractDeclarator
        : Pointer
        {
            $$ = ast_create_node(AbstractDeclarator, content_null, 1, $1);
        }
        |         DirectAbstractDeclarator
        {
            $$ = ast_create_node(AbstractDeclarator, content_null, 1, $1);
        }
        | Pointer DirectAbstractDeclarator
        {
            $$ = ast_create_node(AbstractDeclarator, content_null, 2, $1, $2);
        }
        ;

DirectAbstractDeclarator
        : LPAREN AbstractDeclarator RPAREN
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1, $2);
        }
        |                          LBRACKET                                               RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, content_null, 0));
        }
        |                          LBRACKET                          AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, content_null, 1, $2));
        }
        |                          LBRACKET TypeQualifierList                             RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, content_null, 1, $2));
        }
        |                          LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, content_null, 2, $2, $3));
        }
        |                          LBRACKET                   STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, content_t(STATIC), 1, $3));
        }
        |                          LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, content_t(STATIC), 2, $3, $4));
        }
        |                          LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, content_t(STATIC), 2, $2, $4));
        }
        |                          LBRACKET ASTERISK RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, content_t(ASTERISK), 0));
        }
        |                          LPAREN                   RPAREN
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorParen, content_null, 0));
        }
        |                          LPAREN ParameterTypeList RPAREN
        {
            $$ = ast_create_node(DirectAbstractDeclarator, content_null, 1,
                ast_create_node(DirectAbstractDeclaratorParen, content_null, 1, $2));
        }
        | DirectAbstractDeclarator LBRACKET                                               RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, content_null, 0));
        }
        | DirectAbstractDeclarator LBRACKET                          AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, content_null, 1, $3));
        }
        | DirectAbstractDeclarator LBRACKET TypeQualifierList                             RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, content_null, 1, $3));
        }
        | DirectAbstractDeclarator LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, content_null, 2, $3, $4));
        }
        | DirectAbstractDeclarator LBRACKET                   STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, content_t(STATIC), 1, $4));
        }
        | DirectAbstractDeclarator LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, content_t(STATIC), 2, $4, $5));
        }
        | DirectAbstractDeclarator LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, content_t(STATIC), 2, $3, $5));
        }
        | DirectAbstractDeclarator LBRACKET ASTERISK RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, content_t(ASTERISK), 0));
        }
        | DirectAbstractDeclarator LPAREN                   RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorParen, content_null, 0));
        }
        | DirectAbstractDeclarator LPAREN ParameterTypeList RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorParen, content_null, 1, $3));
        }
        ;

TypedefName
        : TYPEDEF_NAME  { $$ = $1; }
    //  | IDENTIFIER  // reduce/reduce with PrimaryExpression, resolved using lexical analyzer
        ;

Initializer
        : AssignmentExpression
        {
            $$ = ast_create_node(Initializer, content_null, 1, $1);
        }
        | LBRACE InitializerList       RBRACE
        {
            $$ = ast_create_node(Initializer, content_null, 1, $2);
        }
        | LBRACE InitializerList COMMA RBRACE
        {
            $$ = ast_create_node(Initializer, content_null, 1, $2);
        }
        ;

InitializerList
        :                                   Initializer
        {
            $$ = ast_create_node(InitializerList, content_null, 1, ast_create_node(InitializerListElem, content_null, 1, $1));
        }
        |                       Designation Initializer
        {
            $$ = ast_create_node(InitializerList, content_null, 1, ast_create_node(InitializerListElem, content_null, 2, $1, $2));
        }
        | InitializerList COMMA             Initializer
        {
            $$ = ast_expand_node($1, ast_create_node(InitializerListElem, content_null, 1, $3));
        }
        | InitializerList COMMA Designation Initializer
        {
            $$ = ast_expand_node($1, ast_create_node(InitializerListElem, content_null, 2, $3, $4));
        }
        ;

Designation
        : DesignatorList ASSIGN  { $$ = $1; }
        ;

DesignatorList
        :                Designator
        {
            $$ = ast_create_node(DesignatorList, content_null, 1, $1);
        }
        | DesignatorList Designator
        {
            $$ = ast_expand_node($1, $2);
        }
        ;

Designator
        : LBRACKET ConstantExpression RBRACKET  { $$ = $2; }
        | DOT IDENTIFIER                        { $$ = $2; }
        ;

StaticAssertDeclaration
        : STATIC_ASSERT LPAREN ConstantExpression COMMA STRING_LITERAL RPAREN SEMICOLON
        {
            $$ = ast_create_node(StaticAssertDeclaration, content_null, 2, $3, $5);
        }
        ;

// ISO/IEC 9899:2017, 6.8 Statements, page 106-112

Statement
        : LabeledStatement     { $$ = $1; }
        | CompoundStatement    { $$ = $1; }
        | ExpressionStatement  { $$ = $1; }
        | SelectionStatement   { $$ = $1; }
        | IterationStatement   { $$ = $1; }
        | JumpStatement        { $$ = $1; }
        ;

LabeledStatement
        : IDENTIFIER              COLON Statement
        {
            $$ = ast_create_node(LabeledStatement, content_null, 2, $1, $3);
        }
        | CASE ConstantExpression COLON Statement
        {
            $$ = ast_create_node(LabeledStatement, content_t(CASE), 2, $2, $4);
        }
        | DEFAULT                 COLON Statement
        {
            $$ = ast_create_node(LabeledStatement, content_t(DEFAULT), 1, $3);
        }
        ;

CompoundStatement
        : LBRACE               RBRACE  { $$ = NULL; }
        | LBRACE BlockItemList RBRACE  { $$ = $2; }
        ;

BlockItemList
        :               BlockItem
        {
            $$ = ast_create_node(BlockItemList, content_null, 1, $1);
        }
        | BlockItemList BlockItem
        {
            $$ = ast_expand_node($1, $2);
        }
        ;

BlockItem
        : Declaration  { $$ = $1; }
        | Statement    { $$ = $1; }
        ;

ExpressionStatement
        :            SEMICOLON  { $$ = NULL; }
        | Expression SEMICOLON  { $$ = $1; }
        ;

SelectionStatement
        : IF     LPAREN Expression RPAREN Statement %prec NO_ELSE
        {
            $$ = ast_create_node(SelectionStatement, content_t(IF), 2, $3, $5);
        }
        | IF     LPAREN Expression RPAREN Statement ELSE Statement
        {
            $$ = ast_create_node(SelectionStatement, content_t(IF), 3, $3, $5, $7);
        }
        | SWITCH LPAREN Expression RPAREN Statement
        {
            $$ = ast_create_node(SelectionStatement, content_t(SWITCH), 2, $3, $5);
        }
        ;

IterationStatement
        :              WHILE LPAREN Expression RPAREN Statement
        {
            $$ = ast_create_node(IterationStatement, content_t(WHILE), 2, $3, $5);
        }
        | DO Statement WHILE LPAREN Expression RPAREN SEMICOLON
        {
            $$ = ast_create_node(IterationStatement, content_t(DO), 2, $5, $2);  // Expression first
        }
        | FOR LPAREN ExpressionOpt SEMICOLON ExpressionOpt SEMICOLON ExpressionOpt RPAREN Statement
        {
            $$ = ast_create_node(IterationStatement, content_t(FOR), 4, $3, $5, $7, $9);
        }
        | FOR LPAREN Declaration             ExpressionOpt SEMICOLON ExpressionOpt RPAREN Statement
        {
            $$ = ast_create_node(IterationStatement, content_t(FOR), 3, $3, $4, $6, $8);
        }
        ;

JumpStatement
        : GOTO IDENTIFIER   SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, content_t(GOTO), 1, $2);
        }
        | CONTINUE          SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, content_t(CONTINUE), 0);
        }
        | BREAK             SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, content_t(BREAK), 0);
        }
        | RETURN            SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, content_t(RETURN), 0);
        }
        | RETURN Expression SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, content_t(RETURN), 1, $2);
        }
        ;

// ISO/IEC 9899:2017, 6.6 Constant expressions, page 76-77

ConstantExpression
        : ConditionalExpression  { $$ = $1; }
        ;

// ISO/IEC 9899:2017, 6.5 Expressions, page 55-75

ExpressionOpt  // Not from a standard
        : /* empty */  { $$ = NULL; }
        | Expression   { $$ = $1; }
        ;

Expression
        :                  AssignmentExpression
        {
            $$ = ast_create_node(Expression, content_null, 1, $1);
        }
        | Expression COMMA AssignmentExpression
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

AssignmentExpression
        : ConditionalExpression  { $$ = $1; }
        | UnaryExpression AssignmentOperator AssignmentExpression
        {
            $$ = ast_create_node(AssignmentExpression, content_null, 3, $1, $2, $3);
        }
        ;

AssignmentOperator
        : ASSIGN        { $$ = ast_create_node(AssignmentOperator, content_t(ASSIGN), 0); }
        | MUL_ASSIGN    { $$ = ast_create_node(AssignmentOperator, content_t(MUL_ASSIGN), 0); }
        | DIV_ASSIGN    { $$ = ast_create_node(AssignmentOperator, content_t(DIV_ASSIGN), 0); }
        | MOD_ASSIGN    { $$ = ast_create_node(AssignmentOperator, content_t(MOD_ASSIGN), 0); }
        | ADD_ASSIGN    { $$ = ast_create_node(AssignmentOperator, content_t(ADD_ASSIGN), 0); }
        | SUB_ASSIGN    { $$ = ast_create_node(AssignmentOperator, content_t(SUB_ASSIGN), 0); }
        | LEFT_ASSIGN   { $$ = ast_create_node(AssignmentOperator, content_t(LEFT_ASSIGN), 0); }
        | RIGHT_ASSIGN  { $$ = ast_create_node(AssignmentOperator, content_t(RIGHT_ASSIGN), 0); }
        | AND_ASSIGN    { $$ = ast_create_node(AssignmentOperator, content_t(AND_ASSIGN), 0); }
        | XOR_ASSIGN    { $$ = ast_create_node(AssignmentOperator, content_t(XOR_ASSIGN), 0); }
        | OR_ASSIGN     { $$ = ast_create_node(AssignmentOperator, content_t(OR_ASSIGN), 0); }
        ;

ConditionalExpression
        : ArithmeticalExpression  { $$ = $1; }
        | ArithmeticalExpression QUESTION Expression COLON ConditionalExpression
        {
            $$ = ast_create_node(ConditionalExpression, content_null, 3, $1, $3, $5);
        }
        ;

ArithmeticalExpression
        : CastExpression  { $$ = $1; }
        | ArithmeticalExpression LOG_OR    ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(LOG_OR), 2, $1, $3);
        }
        | ArithmeticalExpression LOG_AND   ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(LOG_AND), 2, $1, $3);
        }
        | ArithmeticalExpression VERTICAL  ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(VERTICAL), 2, $1, $3);
        }
        | ArithmeticalExpression CARET     ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(CARET), 2, $1, $3);
        }
        | ArithmeticalExpression AMPERSAND ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(AMPERSAND), 2, $1, $3);
        }
        | ArithmeticalExpression EQ        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(EQ), 2, $1, $3);
        }
        | ArithmeticalExpression NE        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(NE), 2, $1, $3);
        }
        | ArithmeticalExpression LS        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(LS), 2, $1, $3);
        }
        | ArithmeticalExpression GR        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(GR), 2, $1, $3);
        }
        | ArithmeticalExpression LE        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(LE), 2, $1, $3);
        }
        | ArithmeticalExpression GE        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(GE), 2, $1, $3);
        }
        | ArithmeticalExpression LSHIFT    ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(LSHIFT), 2, $1, $3);
        }
        | ArithmeticalExpression RSHIFT    ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(RSHIFT), 2, $1, $3);
        }
        | ArithmeticalExpression PLUS      ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(PLUS), 2, $1, $3);
        }
        | ArithmeticalExpression MINUS     ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(MINUS), 2, $1, $3);
        }
        | ArithmeticalExpression ASTERISK  ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(ASTERISK), 2, $1, $3);
        }
        | ArithmeticalExpression SLASH     ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(SLASH), 2, $1, $3);
        }
        | ArithmeticalExpression PERCENT   ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, content_t(PERCENT), 2, $1, $3);
        }
        ;

CastExpression
        : UnaryExpression  { $$ = $1; }
        | LPAREN TypeName RPAREN CastExpression
        {
            $$ = ast_create_node(CastExpression, content_null, 2, $2, $4);
        }
        ;

UnaryExpression
        : PostfixExpression  { $$ = $1; }
        | DBL_PLUS  UnaryExpression
        {
            $$ = ast_create_node(UnaryExpression, content_t(DBL_PLUS), 1, $2);
        }
        | DBL_MINUS UnaryExpression
        {
            $$ = ast_create_node(UnaryExpression, content_t(DBL_MINUS), 1, $2);
        }
        | UnaryOperator CastExpression
        {
            $$ = ast_create_node(UnaryExpression, content_null, 2, $1, $2);
        }
        | SIZEOF  UnaryExpression
        {
            $$ = ast_create_node(UnaryExpression, content_t(SIZEOF), 1, $2);
        }
        | SIZEOF  LPAREN TypeName RPAREN
        {
            $$ = ast_create_node(UnaryExpression, content_t(SIZEOF), 1, $3);
        }
        | ALIGNOF LPAREN TypeName RPAREN
        {
            $$ = ast_create_node(UnaryExpression, content_t(ALIGNOF), 1, $3);
        }
        ;

UnaryOperator
        : AMPERSAND { $$ = ast_create_node(UnaryOperator, content_t(AMPERSAND), 0); }
        | ASTERISK  { $$ = ast_create_node(UnaryOperator, content_t(ASTERISK), 0); }
        | PLUS      { $$ = ast_create_node(UnaryOperator, content_t(PLUS), 0); }
        | MINUS     { $$ = ast_create_node(UnaryOperator, content_t(MINUS), 0); }
        | TILDE     { $$ = ast_create_node(UnaryOperator, content_t(TILDE), 0); }
        | BANG      { $$ = ast_create_node(UnaryOperator, content_t(BANG), 0); }
        ;

PostfixExpression
        : PrimaryExpression  { $$ = $1; }
        | PostfixExpression LBRACKET Expression RBRACKET
        {
            $$ = ast_create_node(PostfixExpression, content_t(LBRACKET), 2, $1, $3);
        }
        | PostfixExpression LPAREN                        RPAREN
        {
            $$ = ast_create_node(PostfixExpression, content_t(LPAREN), 1, $1);
        }
        | PostfixExpression LPAREN ArgumentExpressionList RPAREN
        {
            $$ = ast_create_node(PostfixExpression, content_t(LPAREN), 2, $1, $3);
        }
        | PostfixExpression DOT   IDENTIFIER
        {
            $$ = ast_create_node(PostfixExpression, content_t(DOT), 2, $1, $3);
        }
        | PostfixExpression ARROW IDENTIFIER
        {
            $$ = ast_create_node(PostfixExpression, content_t(ARROW), 2, $1, $3);
        }
        | PostfixExpression DBL_PLUS
        {
            $$ = ast_create_node(PostfixExpression, content_t(DBL_PLUS), 1, $1);
        }
        | PostfixExpression DBL_MINUS
        {
            $$ = ast_create_node(PostfixExpression, content_t(DBL_MINUS), 1, $1);
        }
        | LPAREN TypeName RPAREN LBRACE InitializerList       RBRACE
        {
            $$ = ast_create_node(PostfixExpression, content_null, 2, $2, $5);
        }
        | LPAREN TypeName RPAREN LBRACE InitializerList COMMA RBRACE
        {
            $$ = ast_create_node(PostfixExpression, content_null, 2, $2, $5);
        }
        ;

ArgumentExpressionList
        :                              AssignmentExpression
        {
            $$ = ast_create_node(ArgumentExpressionList, content_null, 1, $1);
        }
        | ArgumentExpressionList COMMA AssignmentExpression
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

PrimaryExpression
        : IDENTIFIER                { $$ = $1; }
        | CONSTANT                  { $$ = $1; }
    //  | EnumerationConstant  // reduce/reduce with PrimaryExpression, identical to IDENTIFIER
        | STRING_LITERAL            { $$ = $1; }
        | LPAREN Expression RPAREN  { $$ = $2; }
        | GenericSelection          { $$ = $1; }
        ;

GenericSelection
        : GENERIC LPAREN AssignmentExpression COMMA GenericAssocList RPAREN
        {
            $$ = ast_create_node(GenericSelection, content_null, 2, $3, $5);
        }
        ;

GenericAssocList
        :                        GenericAssociation
        {
            $$ = ast_create_node(GenericAssocList, content_null, 1, $1);
        }
        | GenericAssocList COMMA GenericAssociation
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

GenericAssociation
        : TypeName COLON AssignmentExpression
        {
            $$ = ast_create_node(GenericAssociation, content_null, 2, $1, $3);
        }
        | DEFAULT  COLON AssignmentExpression
        {
            $$ = ast_create_node(GenericAssociation, content_t(DEFAULT), 1, $3);
        }
        ;

%%

int yyerror(const char *str)
{
    error_found = true;
    fprintf(stderr, "%s\n", str);
    return 0;
}

_Bool is_typedef_used(AST_NODE *node)
{
    if (node->type != DeclarationSpecifiers) return false;
    for (int i = 0; i < node->children_number; ++i)
    {
        if (node->children[i] && node->children[i]->content.token == TYPEDEF) return true;
    }
    return false;
}

void collect_typedef_names(AST_NODE *node)
{
    if (node->type != InitDeclaratorList) return;
    if (node->children_number < 1) return;
    AST_NODE *cur_decl;
    AST_NODE *cur_direct_decl;
    for (int i = 0; i < node->children_number; ++i)
    {
        cur_decl = node->children[i]->children[0];
        sub_decl:
        cur_direct_decl = cur_decl->children[cur_decl->children_number == 2];
        if (cur_direct_decl->content.token == LPAREN)
        {
            cur_decl = cur_direct_decl->children[0];
            goto sub_decl;
        }
        else if (cur_direct_decl->children[0]->type == Identifier)
        {
            put_typedef_name(cur_direct_decl->children[0]->content.value);
        }
    }
}
