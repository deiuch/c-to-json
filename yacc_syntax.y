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
#include <stdlib.h>
#include <string.h>
#include "alloc_wrap.h"
#include "ast.h"
#include "string_tools.h"
#include "typedef_name.h"
#include "y.tab.h"

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

/// Convert constant value to the corresponding AST node.
///
/// \param type Type of a new node
/// \param val Constant to put as content
/// \return New AST node for a given constant
AST_NODE *get_const_node(AST_NODE_TYPE type, char *val);
%}

%start TranslationUnit

%union
{
    char *id;
    char *integer;
    char *floating;
    char *character;
    char *string;
    char *token;
    AST_NODE *node;
    _Bool boolean_v;
}  // TODO constant types support

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
 *  between this nonterminal and IDENTIFIER.
 *
 *  ISO/IEC 9899:2017, 6.7.8 Type definitions, pages 99-100
 */
%token <id> TYPEDEF_NAME

// Literals
// ISO/IEC 9899:2017, 6.4.2 and 6.4.4, pages 43-52
%token <id>        IDENTIFIER
%token <integer>   INTEGER_CONSTANT
%token <floating>  FLOATING_CONSTANT
%token <character> CHARACTER_CONSTANT
%token <string>    STRING_LITERAL

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

%type <node> TranslationUnit
%type <node> ExternalDeclaration
%type <node> FunctionDefinition
%type <node> DeclarationList
%type <node> Declaration
%type <node> DeclarationSpecifiers
%type <node> InitDeclaratorList
%type <node> InitDeclarator
%type <node> StorageClassSpecifier
%type <node> TypeSpecifier
%type <node> StructOrUnionSpecifier
%type <boolean_v> StructOrUnion
%type <node> StructDeclarationList
%type <node> StructDeclaration
%type <node> SpecifierQualifierList
%type <node> StructDeclaratorList
%type <node> StructDeclarator
%type <node> EnumSpecifier
%type <node> EnumeratorList
%type <node> Enumerator
%type <node> AtomicTypeSpecifier
%type <node> TypeQualifier
%type <node> FunctionSpecifier
%type <node> AlignmentSpecifier
%type <node> Declarator
%type <node> DirectDeclarator
%type <node> Pointer
%type <node> TypeQualifierList
%type <node> ParameterTypeList
%type <node> ParameterList
%type <node> ParameterDeclaration
%type <node> IdentifierList
%type <node> TypeName
%type <node> AbstractDeclarator
%type <node> DirectAbstractDeclarator
%type <node> TypedefName
%type <node> Initializer
%type <node> InitializerList
%type <node> Designation
%type <node> DesignatorList
%type <node> Designator
%type <node> StaticAssertDeclaration
%type <node> Statement
%type <node> LabeledStatement
%type <node> CompoundStatement
%type <node> BlockItemList
%type <node> BlockItem
%type <node> ExpressionStatement
%type <node> SelectionStatement
%type <node> IterationStatement
%type <node> JumpStatement
%type <node> ConstantExpression
%type <node> ExpressionOpt
%type <node> Expression
%type <node> AssignmentExpression
%type <node> AssignmentOperator
%type <node> ConditionalExpression
%type <node> ArithmeticalExpression
%type <node> CastExpression
%type <node> UnaryExpression
%type <node> UnaryOperator
%type <node> PostfixExpression
%type <node> ArgumentExpressionList
%type <node> PrimaryExpression
%type <node> Constant
%type <node> GenericSelection
%type <node> GenericAssocList
%type <node> GenericAssociation

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
                ast_root = ast_create_node(TranslationUnit, NULL, 1, $1);
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
            $$ = ast_create_node(FunctionDefinition, NULL, 3, $1, $2, $3);
        }
        | DeclarationSpecifiers Declarator DeclarationList CompoundStatement
        {
            $$ = ast_create_node(FunctionDefinition, NULL, 4, $1, $2, $3, $4);
        }
        ;

DeclarationList
        :                 Declaration
        {
            $$ = ast_create_node(DeclarationList, NULL, 1, $1);
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
            $$ = ast_create_node(Declaration, NULL, 1, $1);
        }
        | DeclarationSpecifiers InitDeclaratorList SEMICOLON
        {
            $$ = ast_create_node(Declaration, NULL, 2, $1, $2);
            if (is_typedef_used($1)) collect_typedef_names($2);  // Storing typedef-name
        }
        | StaticAssertDeclaration  { $$ = $1; }
        ;

DeclarationSpecifiers
        : StorageClassSpecifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, NULL, 1, $1);
        }
        | TypeSpecifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, NULL, 1, $1);
        }
        | TypeQualifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, NULL, 1, $1);
        }
        | FunctionSpecifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, NULL, 1, $1);
        }
        | AlignmentSpecifier
        {
            $$ = ast_create_node(DeclarationSpecifiers, NULL, 1, $1);
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
            $$ = ast_create_node(InitDeclaratorList, NULL, 1, $1);
        }
        | InitDeclaratorList COMMA InitDeclarator
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

InitDeclarator
        : Declarator
        {
            $$ = ast_create_node(InitDeclarator, NULL, 1, $1);
        }
        | Declarator ASSIGN Initializer
        {
            $$ = ast_create_node(InitDeclarator, NULL, 2, $1, $3);
        }
        ;

StorageClassSpecifier
        : TYPEDEF       { $$ = ast_create_node(StorageClassSpecifier, "TYPEDEF", 0); }
        | EXTERN        { $$ = ast_create_node(StorageClassSpecifier, "EXTERN", 0); }
        | STATIC        { $$ = ast_create_node(StorageClassSpecifier, "STATIC", 0); }
        | THREAD_LOCAL  { $$ = ast_create_node(StorageClassSpecifier, "THREAD_LOCAL", 0); }
        | AUTO          { $$ = ast_create_node(StorageClassSpecifier, "AUTO", 0); }
        | REGISTER      { $$ = ast_create_node(StorageClassSpecifier, "REGISTER", 0); }
        ;

TypeSpecifier
        : VOID       { $$ = ast_create_node(TypeSpecifier, "VOID", 0); }
        | CHAR       { $$ = ast_create_node(TypeSpecifier, "CHAR", 0); }
        | SHORT      { $$ = ast_create_node(TypeSpecifier, "SHORT", 0); }
        | INT        { $$ = ast_create_node(TypeSpecifier, "INT", 0); }
        | LONG       { $$ = ast_create_node(TypeSpecifier, "LONG", 0); }
        | FLOAT      { $$ = ast_create_node(TypeSpecifier, "FLOAT", 0); }
        | DOUBLE     { $$ = ast_create_node(TypeSpecifier, "DOUBLE", 0); }
        | SIGNED     { $$ = ast_create_node(TypeSpecifier, "SIGNED", 0); }
        | UNSIGNED   { $$ = ast_create_node(TypeSpecifier, "UNSIGNED", 0); }
        | BOOL       { $$ = ast_create_node(TypeSpecifier, "BOOL", 0); }
        | COMPLEX    { $$ = ast_create_node(TypeSpecifier, "COMPLEX", 0); }
        | IMAGINARY  { $$ = ast_create_node(TypeSpecifier, "IMAGINARY", 0); }
        | AtomicTypeSpecifier     { $$ = $1; }
        | StructOrUnionSpecifier  { $$ = $1; }
        | EnumSpecifier           { $$ = $1; }
        | TypedefName             { $$ = $1; }
        ;

StructOrUnionSpecifier
        : StructOrUnion            LBRACE StructDeclarationList RBRACE
        {
            $$ = ast_create_node($1 ? StructSpecifier : UnionSpecifier, NULL, 1, $3);
        }
        | StructOrUnion IDENTIFIER LBRACE StructDeclarationList RBRACE
        {
            $$ = ast_create_node($1 ? StructSpecifier : UnionSpecifier, NULL, 2, get_const_node(Identifier, $2), $4);
        }
        | StructOrUnion IDENTIFIER
        {
            $$ = ast_create_node($1 ? StructSpecifier : UnionSpecifier, NULL, 1, get_const_node(Identifier, $2));
        }
        ;

StructOrUnion
        : STRUCT  { $$ = true; }
        | UNION   { $$ = false; }
        ;

StructDeclarationList
        :                       StructDeclaration
        {
            $$ = ast_create_node(StructDeclarationList, NULL, 1, $1);
        }
        | StructDeclarationList StructDeclaration
        {
            $$ = ast_expand_node($1, $2);
        }
        ;

StructDeclaration
        : SpecifierQualifierList                      SEMICOLON
        {
            $$ = ast_create_node(StructDeclaration, NULL, 1, $1);
        }
        | SpecifierQualifierList StructDeclaratorList SEMICOLON
        {
            $$ = ast_create_node(StructDeclaration, NULL, 2, $1, $2);
        }
        | StaticAssertDeclaration  { $$ = $1; }
        ;

SpecifierQualifierList
        : TypeSpecifier
        {
            $$ = ast_create_node(SpecifierQualifierList, NULL, 1, $1);
        }
        | TypeQualifier
        {
            $$ = ast_create_node(SpecifierQualifierList, NULL, 1, $1);
        }
        | AlignmentSpecifier
        {
            $$ = ast_create_node(SpecifierQualifierList, NULL, 1, $1);
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
            $$ = ast_create_node(StructDeclaratorList, NULL, 1, $1);
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
            $$ = ast_create_node(StructDeclarator, NULL, 2, $1, $3);
        }
        ;

EnumSpecifier
        : ENUM            LBRACE EnumeratorList       RBRACE
        {
            $$ = ast_create_node(EnumSpecifier, NULL, 1, $3);
        }
        | ENUM            LBRACE EnumeratorList COMMA RBRACE
        {
            $$ = ast_create_node(EnumSpecifier, NULL, 1, $3);
        }
        | ENUM IDENTIFIER LBRACE EnumeratorList       RBRACE
        {
            $$ = ast_create_node(EnumSpecifier, NULL, 2, get_const_node(Identifier, $2), $4);
        }
        | ENUM IDENTIFIER LBRACE EnumeratorList COMMA RBRACE
        {
            $$ = ast_create_node(EnumSpecifier, NULL, 2, get_const_node(Identifier, $2), $4);
        }
        | ENUM IDENTIFIER
        {
            $$ = ast_create_node(EnumSpecifier, NULL, 1, get_const_node(Identifier, $2));
        }
        ;

EnumeratorList
        :                      Enumerator
        {
            $$ = ast_create_node(EnumeratorList, NULL, 1, $1);
        }
        | EnumeratorList COMMA Enumerator
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

Enumerator
        : IDENTIFIER  // EnumerationConstant, reduce/reduce with PrimaryExpression
        {
            $$ = ast_create_node(Enumerator, NULL, 1, get_const_node(Identifier, $1));
        }
        | IDENTIFIER ASSIGN ConstantExpression
        {
            $$ = ast_create_node(Enumerator, NULL, 2, get_const_node(Identifier, $1), $3);
        }
        ;

AtomicTypeSpecifier
        : ATOMIC LPAREN TypeName RPAREN
        {
            $$ = ast_create_node(AtomicTypeSpecifier, NULL, 1, $3);
        }
        ;

TypeQualifier
        : CONST     { $$ = ast_create_node(TypeQualifier, "CONST", 0); }
        | RESTRICT  { $$ = ast_create_node(TypeQualifier, "RESTRICT", 0); }
        | VOLATILE  { $$ = ast_create_node(TypeQualifier, "VOLATILE", 0); }
        | ATOMIC    { $$ = ast_create_node(TypeQualifier, "ATOMIC", 0); }
        ;

FunctionSpecifier
        : INLINE    { $$ = ast_create_node(FunctionSpecifier, "INLINE", 0); }
        | NORETURN  { $$ = ast_create_node(FunctionSpecifier, "NORETURN", 0); }
        ;

AlignmentSpecifier
        : ALIGNAS LPAREN TypeName           RPAREN
        {
            $$ = ast_create_node(AlignmentSpecifier, NULL, 1, $3);
        }
        | ALIGNAS LPAREN ConstantExpression RPAREN
        {
            $$ = ast_create_node(AlignmentSpecifier, NULL, 1, $3);
        }
        ;

Declarator
        :         DirectDeclarator
        {
            $$ = ast_create_node(Declarator, NULL, 1, $1);
        }
        | Pointer DirectDeclarator
        {
            $$ = ast_create_node(Declarator, NULL, 2, $1, $2);
        }
        ;

DirectDeclarator
        : IDENTIFIER
        {
            $$ = ast_create_node(DirectDeclarator, NULL, 1, get_const_node(Identifier, $1));
        }
        | LPAREN Declarator RPAREN
        {
            $$ = ast_create_node(DirectDeclarator, NULL, 1, $2);
        }
        | DirectDeclarator LBRACKET                                               RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, NULL, 0));
        }
        | DirectDeclarator LBRACKET                          AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, NULL, 1, $3));
        }
        | DirectDeclarator LBRACKET TypeQualifierList                             RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, NULL, 1, $3));
        }
        | DirectDeclarator LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, NULL, 2, $3, $4));
        }
        | DirectDeclarator LBRACKET                   STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, "STATIC", 1, $4));
        }
        | DirectDeclarator LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, "STATIC", 2, $4, $5));
        }
        | DirectDeclarator LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, "STATIC", 2, $3, $5));
        }
        | DirectDeclarator LBRACKET                   ASTERISK                    RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, "ASTERISK", 0));
        }
        | DirectDeclarator LBRACKET TypeQualifierList ASTERISK                    RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorBrackets, "ASTERISK", 1, $3));
        }
        | DirectDeclarator LPAREN ParameterTypeList RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorParen, NULL, 1, $3));
        }
        | DirectDeclarator LPAREN                   RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorParen, NULL, 0));
        }
        | DirectDeclarator LPAREN IdentifierList    RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectDeclaratorParen, NULL, 1, $3));
        }
        ;

Pointer
        : ASTERISK
        {
            $$ = ast_create_node(Pointer, NULL, 0);
        }
        | ASTERISK TypeQualifierList
        {
            $$ = ast_create_node(Pointer, NULL, 1, $2);
        }
        | ASTERISK                   Pointer
        {
            $$ = ast_expand_node(ast_create_node(Pointer, NULL, 0), $2);
        }
        | ASTERISK TypeQualifierList Pointer
        {
            $$ = ast_expand_node(ast_create_node(Pointer, NULL, 1, $2), $3);
        }
        ;

TypeQualifierList
        :                   TypeQualifier
        {
            $$ = ast_create_node(TypeQualifierList, NULL, 1, $1);
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
            $1->content = "ELLIPSIS";
            $$ = $1;
        }
        ;

ParameterList
        :                     ParameterDeclaration
        {
            $$ = ast_create_node(ParameterList, NULL, 1, $1);
        }
        | ParameterList COMMA ParameterDeclaration
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

ParameterDeclaration
        : DeclarationSpecifiers Declarator
        {
            $$ = ast_create_node(ParameterDeclaration, NULL, 2, $1, $2);
        }
        | DeclarationSpecifiers
        {
            $$ = ast_create_node(ParameterDeclaration, NULL, 1, $1);
        }
        | DeclarationSpecifiers AbstractDeclarator
        {
            $$ = ast_create_node(ParameterDeclaration, NULL, 2, $1, $2);
        }
        ;

IdentifierList
        :                      IDENTIFIER
        {
            $$ = ast_create_node(IdentifierList, NULL, 1, get_const_node(Identifier, $1));
        }
        | IdentifierList COMMA IDENTIFIER
        {
            $$ = ast_expand_node($1, get_const_node(Identifier, $3));
        }
        ;

TypeName
        : SpecifierQualifierList
        {
            $$ = ast_create_node(TypeName, NULL, 1, $1);
        }
        | SpecifierQualifierList AbstractDeclarator
        {
            $$ = ast_create_node(TypeName, NULL, 2, $1, $2);
        }
        ;

AbstractDeclarator
        : Pointer
        {
            $$ = ast_create_node(AbstractDeclarator, NULL, 1, $1);
        }
        |         DirectAbstractDeclarator
        {
            $$ = ast_create_node(AbstractDeclarator, NULL, 1, $1);
        }
        | Pointer DirectAbstractDeclarator
        {
            $$ = ast_create_node(AbstractDeclarator, NULL, 2, $1, $2);
        }
        ;

DirectAbstractDeclarator
        : LPAREN AbstractDeclarator RPAREN
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1, $2);
        }
        |                          LBRACKET                                               RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, NULL, 0));
        }
        |                          LBRACKET                          AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, NULL, 1, $2));
        }
        |                          LBRACKET TypeQualifierList                             RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, NULL, 1, $2));
        }
        |                          LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, NULL, 2, $2, $3));
        }
        |                          LBRACKET                   STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, "STATIC", 1, $3));
        }
        |                          LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, "STATIC", 2, $3, $4));
        }
        |                          LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, "STATIC", 2, $2, $4));
        }
        |                          LBRACKET ASTERISK RBRACKET
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorBrackets, "ASTERISK", 0));
        }
        |                          LPAREN                   RPAREN
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorParen, NULL, 0));
        }
        |                          LPAREN ParameterTypeList RPAREN
        {
            $$ = ast_create_node(DirectAbstractDeclarator, NULL, 1,
                ast_create_node(DirectAbstractDeclaratorParen, NULL, 1, $2));
        }
        | DirectAbstractDeclarator LBRACKET                                               RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, NULL, 0));
        }
        | DirectAbstractDeclarator LBRACKET                          AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, NULL, 1, $3));
        }
        | DirectAbstractDeclarator LBRACKET TypeQualifierList                             RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, NULL, 1, $3));
        }
        | DirectAbstractDeclarator LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, NULL, 2, $3, $4));
        }
        | DirectAbstractDeclarator LBRACKET                   STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, "STATIC", 1, $4));
        }
        | DirectAbstractDeclarator LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, "STATIC", 2, $4, $5));
        }
        | DirectAbstractDeclarator LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, "STATIC", 2, $3, $5));
        }
        | DirectAbstractDeclarator LBRACKET ASTERISK RBRACKET
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorBrackets, "ASTERISK", 0));
        }
        | DirectAbstractDeclarator LPAREN                   RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorParen, NULL, 0));
        }
        | DirectAbstractDeclarator LPAREN ParameterTypeList RPAREN
        {
            $$ = ast_expand_node($1, ast_create_node(DirectAbstractDeclaratorParen, NULL, 1, $3));
        }
        ;

TypedefName
        : TYPEDEF_NAME  { $$ = get_const_node(Identifier, $1); }
    //  | IDENTIFIER  // reduce/reduce with PrimaryExpression, resolved using lexical analyzer
        ;

Initializer
        : AssignmentExpression
        {
            $$ = ast_create_node(Initializer, NULL, 1, $1);
        }
        | LBRACE InitializerList       RBRACE
        {
            $$ = ast_create_node(Initializer, NULL, 1, $2);
        }
        | LBRACE InitializerList COMMA RBRACE
        {
            $$ = ast_create_node(Initializer, NULL, 1, $2);
        }
        ;

InitializerList
        :                                   Initializer
        {
            $$ = ast_create_node(InitializerList, NULL, 1, ast_create_node(InitializerListElem, NULL, 1, $1));
        }
        |                       Designation Initializer
        {
            $$ = ast_create_node(InitializerList, NULL, 1, ast_create_node(InitializerListElem, NULL, 2, $1, $2));
        }
        | InitializerList COMMA             Initializer
        {
            $$ = ast_expand_node($1, ast_create_node(InitializerListElem, NULL, 1, $3));
        }
        | InitializerList COMMA Designation Initializer
        {
            $$ = ast_expand_node($1, ast_create_node(InitializerListElem, NULL, 2, $3, $4));
        }
        ;

Designation
        : DesignatorList ASSIGN  { $$ = $1; }
        ;

DesignatorList
        :                Designator
        {
            $$ = ast_create_node(DesignatorList, NULL, 1, $1);
        }
        | DesignatorList Designator
        {
            $$ = ast_expand_node($1, $2);
        }
        ;

Designator
        : LBRACKET ConstantExpression RBRACKET  { $$ = $2; }
        | DOT IDENTIFIER                        { $$ = get_const_node(Identifier, $2); }
        ;

StaticAssertDeclaration
        : STATIC_ASSERT LPAREN ConstantExpression COMMA STRING_LITERAL RPAREN SEMICOLON
        {
            $$ = ast_create_node(StaticAssertDeclaration, NULL, 2, $3, get_const_node(StringLiteral, $5));
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
            $$ = ast_create_node(LabeledStatement, NULL, 2, get_const_node(Identifier, $1), $3);
        }
        | CASE ConstantExpression COLON Statement
        {
            $$ = ast_create_node(LabeledStatement, "CASE", 2, $2, $4);
        }
        | DEFAULT                 COLON Statement
        {
            $$ = ast_create_node(LabeledStatement, "DEFAULT", 1, $3);
        }
        ;

CompoundStatement
        : LBRACE               RBRACE  { $$ = NULL; }
        | LBRACE BlockItemList RBRACE  { $$ = $2; }
        ;

BlockItemList
        :               BlockItem
        {
            $$ = ast_create_node(BlockItemList, NULL, 1, $1);
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
            $$ = ast_create_node(SelectionStatement, "IF", 2, $3, $5);
        }
        | IF     LPAREN Expression RPAREN Statement ELSE Statement
        {
            $$ = ast_create_node(SelectionStatement, "IF", 3, $3, $5, $7);
        }
        | SWITCH LPAREN Expression RPAREN Statement
        {
            $$ = ast_create_node(SelectionStatement, "SWITCH", 2, $3, $5);
        }
        ;

IterationStatement
        :              WHILE LPAREN Expression RPAREN Statement
        {
            $$ = ast_create_node(IterationStatement, "WHILE", 2, $3, $5);
        }
        | DO Statement WHILE LPAREN Expression RPAREN SEMICOLON
        {
            $$ = ast_create_node(IterationStatement, "DO", 2, $5, $2);  // Expression first
        }
        | FOR LPAREN ExpressionOpt SEMICOLON ExpressionOpt SEMICOLON ExpressionOpt RPAREN Statement
        {
            $$ = ast_create_node(IterationStatement, "FOR", 4, $3, $5, $7, $9);
        }
        | FOR LPAREN Declaration             ExpressionOpt SEMICOLON ExpressionOpt RPAREN Statement
        {
            $$ = ast_create_node(IterationStatement, "FOR", 3, $3, $4, $6, $8);
        }
        ;

JumpStatement
        : GOTO IDENTIFIER   SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, "GOTO", 1, get_const_node(Identifier, $2));
        }
        | CONTINUE          SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, "CONTINUE", 0);
        }
        | BREAK             SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, "BREAK", 0);
        }
        | RETURN            SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, "RETURN", 0);
        }
        | RETURN Expression SEMICOLON
        {
            $$ = ast_create_node(JumpStatement, "RETURN", 1, $2);
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
            $$ = ast_create_node(Expression, NULL, 1, $1);
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
            $$ = ast_create_node(AssignmentExpression, NULL, 3, $1, $2, $3);
        }
        ;

AssignmentOperator
        : ASSIGN        { $$ = ast_create_node(AssignmentOperator, "ASSIGN", 0); }
        | MUL_ASSIGN    { $$ = ast_create_node(AssignmentOperator, "MUL_ASSIGN", 0); }
        | DIV_ASSIGN    { $$ = ast_create_node(AssignmentOperator, "DIV_ASSIGN", 0); }
        | MOD_ASSIGN    { $$ = ast_create_node(AssignmentOperator, "MOD_ASSIGN", 0); }
        | ADD_ASSIGN    { $$ = ast_create_node(AssignmentOperator, "ADD_ASSIGN", 0); }
        | SUB_ASSIGN    { $$ = ast_create_node(AssignmentOperator, "SUB_ASSIGN", 0); }
        | LEFT_ASSIGN   { $$ = ast_create_node(AssignmentOperator, "LEFT_ASSIGN", 0); }
        | RIGHT_ASSIGN  { $$ = ast_create_node(AssignmentOperator, "RIGHT_ASSIGN", 0); }
        | AND_ASSIGN    { $$ = ast_create_node(AssignmentOperator, "AND_ASSIGN", 0); }
        | XOR_ASSIGN    { $$ = ast_create_node(AssignmentOperator, "XOR_ASSIGN", 0); }
        | OR_ASSIGN     { $$ = ast_create_node(AssignmentOperator, "OR_ASSIGN", 0); }
        ;

ConditionalExpression
        : ArithmeticalExpression  { $$ = $1; }
        | ArithmeticalExpression QUESTION Expression COLON ConditionalExpression
        {
            $$ = ast_create_node(ConditionalExpression, NULL, 3, $1, $3, $5);
        }
        ;

ArithmeticalExpression
        : CastExpression  { $$ = $1; }
        | ArithmeticalExpression LOG_OR    ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "LOG_OR", 2, $1, $3);
        }
        | ArithmeticalExpression LOG_AND   ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "LOG_AND", 2, $1, $3);
        }
        | ArithmeticalExpression VERTICAL  ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "VERTICAL", 2, $1, $3);
        }
        | ArithmeticalExpression CARET     ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "CARET", 2, $1, $3);
        }
        | ArithmeticalExpression AMPERSAND ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "AMPERSAND", 2, $1, $3);
        }
        | ArithmeticalExpression EQ        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "EQ", 2, $1, $3);
        }
        | ArithmeticalExpression NE        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "NE", 2, $1, $3);
        }
        | ArithmeticalExpression LS        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "LS", 2, $1, $3);
        }
        | ArithmeticalExpression GR        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "GR", 2, $1, $3);
        }
        | ArithmeticalExpression LE        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "LE", 2, $1, $3);
        }
        | ArithmeticalExpression GE        ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "GE", 2, $1, $3);
        }
        | ArithmeticalExpression LSHIFT    ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "LSHIFT", 2, $1, $3);
        }
        | ArithmeticalExpression RSHIFT    ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "RSHIFT", 2, $1, $3);
        }
        | ArithmeticalExpression PLUS      ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "PLUS", 2, $1, $3);
        }
        | ArithmeticalExpression MINUS     ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "MINUS", 2, $1, $3);
        }
        | ArithmeticalExpression ASTERISK  ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "ASTERISK", 2, $1, $3);
        }
        | ArithmeticalExpression SLASH     ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "SLASH", 2, $1, $3);
        }
        | ArithmeticalExpression PERCENT   ArithmeticalExpression
        {
            $$ = ast_create_node(ArithmeticalExpression, "PERCENT", 2, $1, $3);
        }
        ;

CastExpression
        : UnaryExpression  { $$ = $1; }
        | LPAREN TypeName RPAREN CastExpression
        {
            $$ = ast_create_node(CastExpression, NULL, 2, $2, $4);
        }
        ;

UnaryExpression
        : PostfixExpression  { $$ = $1; }
        | DBL_PLUS  UnaryExpression
        {
            $$ = ast_create_node(UnaryExpression, "DBL_PLUS", 1, $2);
        }
        | DBL_MINUS UnaryExpression
        {
            $$ = ast_create_node(UnaryExpression, "DBL_MINUS", 1, $2);
        }
        | UnaryOperator CastExpression
        {
            $$ = ast_create_node(UnaryExpression, NULL, 2, $1, $2);
        }
        | SIZEOF  UnaryExpression
        {
            $$ = ast_create_node(UnaryExpression, "SIZEOF", 1, $2);
        }
        | SIZEOF  LPAREN TypeName RPAREN
        {
            $$ = ast_create_node(UnaryExpression, "SIZEOF", 1, $3);
        }
        | ALIGNOF LPAREN TypeName RPAREN
        {
            $$ = ast_create_node(UnaryExpression, "AKIGNOF", 1, $3);
        }
        ;

UnaryOperator
        : AMPERSAND { $$ = ast_create_node(UnaryOperator, "AMPERSAND", 0); }
        | ASTERISK  { $$ = ast_create_node(UnaryOperator, "ASTERISK", 0); }
        | PLUS      { $$ = ast_create_node(UnaryOperator, "PLUS", 0); }
        | MINUS     { $$ = ast_create_node(UnaryOperator, "MINUS", 0); }
        | TILDE     { $$ = ast_create_node(UnaryOperator, "TILDE", 0); }
        | BANG      { $$ = ast_create_node(UnaryOperator, "BANG", 0); }
        ;

PostfixExpression
        : PrimaryExpression  { $$ = $1; }
        | PostfixExpression LBRACKET Expression RBRACKET
        {
            $$ = ast_create_node(PostfixExpression, "BRACKETS", 1, $3);
        }
        | PostfixExpression LPAREN                        RPAREN
        {
            $$ = ast_create_node(PostfixExpression, "PARENTHESES", 0);
        }
        | PostfixExpression LPAREN ArgumentExpressionList RPAREN
        {
            $$ = ast_create_node(PostfixExpression, "PARENTHESES", 1, $3);
        }
        | PostfixExpression DOT   IDENTIFIER
        {
            $$ = ast_create_node(PostfixExpression, "DOT", 1, $3);
        }
        | PostfixExpression ARROW IDENTIFIER
        {
            $$ = ast_create_node(PostfixExpression, "ARROW", 1, $3);
        }
        | PostfixExpression DBL_PLUS
        {
            $$ = ast_create_node(PostfixExpression, "DBL_PLUS", 0);
        }
        | PostfixExpression DBL_MINUS
        {
            $$ = ast_create_node(PostfixExpression, "DBL_MINUS", 0);
        }
        | LPAREN TypeName RPAREN LBRACE InitializerList       RBRACE
        {
            $$ = ast_create_node(PostfixExpression, NULL, 2, $2, $5);
        }
        | LPAREN TypeName RPAREN LBRACE InitializerList COMMA RBRACE
        {
            $$ = ast_create_node(PostfixExpression, NULL, 2, $2, $5);
        }
        ;

ArgumentExpressionList
        :                              AssignmentExpression
        {
            $$ = ast_create_node(ArgumentExpressionList, NULL, 1, $1);
        }
        | ArgumentExpressionList COMMA AssignmentExpression
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

PrimaryExpression
        : IDENTIFIER                { $$ = get_const_node(Identifier, $1); }
        | Constant                  { $$ = $1; }
        | STRING_LITERAL            { $$ = get_const_node(StringLiteral, $1); }
        | LPAREN Expression RPAREN  { $$ = $2; }
        | GenericSelection          { $$ = $1; }
        ;

Constant
        : INTEGER_CONSTANT    { $$ = get_const_node(IntegerConstant, $1); }
        | FLOATING_CONSTANT   { $$ = get_const_node(FloatingConstant, $1); }
    //  | EnumerationConstant  // reduce/reduce with PrimaryExpression, identical to IDENTIFIER
        | CHARACTER_CONSTANT  { $$ = get_const_node(CharacterConstant, $1); }
        ;

GenericSelection
        : GENERIC LPAREN AssignmentExpression COMMA GenericAssocList RPAREN
        {
            $$ = ast_create_node(GenericSelection, NULL, 2, $3, $5);
        }
        ;

GenericAssocList
        :                        GenericAssociation
        {
            $$ = ast_create_node(GenericAssocList, NULL, 1, $1);
        }
        | GenericAssocList COMMA GenericAssociation
        {
            $$ = ast_expand_node($1, $3);
        }
        ;

GenericAssociation
        : TypeName COLON AssignmentExpression
        {
            $$ = ast_create_node(GenericAssociation, NULL, 2, $1, $3);
        }
        | DEFAULT  COLON AssignmentExpression
        {
            $$ = ast_create_node(GenericAssociation, "DEFAULT", 1, $3);
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
    for (int i = 0; i < node->children_number; ++i)  // TODO
    {
        if (str_eq("TYPEDEF", node->children[i]->content)) return true;
    }
    return false;
}

void collect_typedef_names(AST_NODE *node)
{
    if (node->type != InitDeclaratorList) return;
    for (int i = 0; i < node->children_number; ++i)  // TODO
    {
        for (int j = 0; j < node->children[i]->children_number; ++j)
        {
            if (node->children[i]->children[j]->type == DirectDeclarator
                && node->children[i]->children[j]->children[0]->type == Identifier)
            {
                put_typedef_name(node->children[i]->children[j]->children[0]->content);
            }
        }
    }
}

AST_NODE *get_const_node(AST_NODE_TYPE type, char *val)
{
    AST_NODE *res = ast_create_node(type, val, 0);
    return res;
}

/// Conversion function for AST node content.
///
/// \param obj Object of AST content
/// \return String representation of the given object, NULL if not AST_NODE
char *content_to_str(void *object)
{
    return object;
}
