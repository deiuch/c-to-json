%{
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern int yydebug;  // TODO: REMOVE IN PROD, 'yacc' it with -t flag.
extern int yylex();
char const *yyerror(const char *str);
%}

%expect    0  // shift/reduce
%expect-rr 0  // reduce/reduce

%start TranslationUnit

%union
{
    char *id;
    char *integer;
    char *floating;
    char character;
    char *string;
}  // TODO type conversions

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
    This nonterminal was introduced
    in order to deal with reduce/reduce
    conflict of TypedefName with PrimaryExpression.
    Lexical analyzer should make distinction
    between this nonterminal and IDENTIFIER.
*/
%token <id> TYPEDEF_NAME

%token <id>        IDENTIFIER
%token <integer>   INTEGER_CONSTANT
%token <floating>  FLOATING_CONSTANT
%token <character> CHARACTER_CONSTANT
%token <string>    STRING_LITERAL

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

// Lower precedence

// _Atomic type shift/reduce resolution
%nonassoc ATOMIC
%nonassoc LPAREN

// "Dangling Else" shift/reduce resolution
%nonassoc NO_ELSE  // Fake token for precedence
%nonassoc ELSE

// Expression precedence
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

// TODO ISO/IEC 9899:2017, pages 55-116 or 338-344
// http://www.open-std.org/jtc1/sc22/wg14/www/abq/c17_updated_proposed_fdis.pdf

%%

// ISO/IEC 9899:2017, 6.9 External definitions, p. 113-116

TranslationUnit
        :                 ExternalDeclaration
        | TranslationUnit ExternalDeclaration
        ;

ExternalDeclaration
        : FunctionDefinition
        | Declaration
        ;

FunctionDefinition
        : DeclarationSpecifiers Declarator                 CompoundStatement
        | DeclarationSpecifiers Declarator DeclarationList CompoundStatement
        ;

DeclarationList
        :                 Declaration
        | DeclarationList Declaration
        ;

// ISO/IEC 9899:2017, 6.7 Declarations, p. 78-105

Declaration
        : DeclarationSpecifiers                    SEMICOLON
        | DeclarationSpecifiers InitDeclaratorList SEMICOLON
        | StaticAssertDeclaration
        ;

DeclarationSpecifiers
        : StorageClassSpecifier
        | TypeSpecifier
        | TypeQualifier
        | FunctionSpecifier
        | AlignmentSpecifier
        | StorageClassSpecifier DeclarationSpecifiers
        | TypeSpecifier         DeclarationSpecifiers
        | TypeQualifier         DeclarationSpecifiers
        | FunctionSpecifier     DeclarationSpecifiers
        | AlignmentSpecifier    DeclarationSpecifiers
        ;  // TODO left recursion?

InitDeclaratorList
        :                          InitDeclarator
        | InitDeclaratorList COMMA InitDeclarator
        ;

InitDeclarator
        : Declarator
        | Declarator ASSIGN Initializer
        ;

StorageClassSpecifier
        : TYPEDEF
        | EXTERN
        | STATIC
        | THREAD_LOCAL
        | AUTO
        | REGISTER
        ;

TypeSpecifier
        : VOID
        | CHAR
        | SHORT
        | INT
        | LONG
        | FLOAT
        | DOUBLE
        | SIGNED
        | UNSIGNED
        | BOOL
        | COMPLEX
        | IMAGINARY  // TODO check (reserved for future)
        | AtomicTypeSpecifier
        | StructOrUnionSpecifier
        | EnumSpecifier
        | TypedefName
        ;

StructOrUnionSpecifier
        : StructOrUnion            LBRACE StructDeclarationList RBRACE
        | StructOrUnion IDENTIFIER LBRACE StructDeclarationList RBRACE
        | StructOrUnion IDENTIFIER
        ;

StructOrUnion
        : STRUCT
        | UNION
        ;

StructDeclarationList
        :                       StructDeclaration
        | StructDeclarationList StructDeclaration
        ;

StructDeclaration
        : SpecifierQualifierList                      SEMICOLON
        | SpecifierQualifierList StructDeclaratorList SEMICOLON
        | StaticAssertDeclaration
        ;

SpecifierQualifierList
        : TypeSpecifier
        | TypeQualifier
        | AlignmentSpecifier
        | TypeSpecifier      SpecifierQualifierList
        | TypeQualifier      SpecifierQualifierList
        | AlignmentSpecifier SpecifierQualifierList
        ;  // TODO left recursion?

StructDeclaratorList
        :                            StructDeclarator
        | StructDeclaratorList COMMA StructDeclarator
        ;

StructDeclarator
        : Declarator
        |            COLON ConstantExpression
        | Declarator COLON ConstantExpression
        ;

EnumSpecifier
        : ENUM            LBRACE EnumeratorList       RBRACE
        | ENUM            LBRACE EnumeratorList COMMA RBRACE
        | ENUM IDENTIFIER LBRACE EnumeratorList       RBRACE
        | ENUM IDENTIFIER LBRACE EnumeratorList COMMA RBRACE
        | ENUM IDENTIFIER
        ;

EnumeratorList
        :                      Enumerator
        | EnumeratorList COMMA Enumerator
        ;

Enumerator
        : IDENTIFIER  // EnumerationConstant, reduce/reduce with PrimaryExpression
        | IDENTIFIER ASSIGN ConstantExpression
        ;

AtomicTypeSpecifier
        : ATOMIC LPAREN TypeName RPAREN
        ;

TypeQualifier
        : CONST
        | RESTRICT
        | VOLATILE
        | ATOMIC
        ;

FunctionSpecifier
        : INLINE
        | NORETURN
        ;

AlignmentSpecifier
        : ALIGNAS LPAREN TypeName           RPAREN
        | ALIGNAS LPAREN ConstantExpression RPAREN
        ;

Declarator
        :         DirectDeclarator
        | Pointer DirectDeclarator
        ;

DirectDeclarator
        : IDENTIFIER
        | LPAREN Declarator RPAREN
        | DirectDeclarator LBRACKET                                               RBRACKET
        | DirectDeclarator LBRACKET                          AssignmentExpression RBRACKET
        | DirectDeclarator LBRACKET TypeQualifierList                             RBRACKET
        | DirectDeclarator LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        | DirectDeclarator LBRACKET                   STATIC AssignmentExpression RBRACKET
        | DirectDeclarator LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        | DirectDeclarator LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        | DirectDeclarator LBRACKET                   ASTERISK                    RBRACKET
        | DirectDeclarator LBRACKET TypeQualifierList ASTERISK                    RBRACKET
        | DirectDeclarator LPAREN ParameterTypeList RPAREN
        | DirectDeclarator LPAREN                   RPAREN
        | DirectDeclarator LPAREN IdentifierList    RPAREN
        ;

Pointer
        : ASTERISK
        | ASTERISK TypeQualifierList
        | ASTERISK                   Pointer
        | ASTERISK TypeQualifierList Pointer
        ;  // TODO left recursion?

TypeQualifierList
        :                   TypeQualifier
        | TypeQualifierList TypeQualifier
        ;

ParameterTypeList
        : ParameterList
        | ParameterList COMMA ELLIPSIS
        ;

ParameterList
        :                     ParameterDeclaration
        | ParameterList COMMA ParameterDeclaration
        ;

ParameterDeclaration
        : DeclarationSpecifiers Declarator
        | DeclarationSpecifiers
        | DeclarationSpecifiers AbstractDeclarator
        ;

IdentifierList
        :                      IDENTIFIER
        | IdentifierList COMMA IDENTIFIER
        ;

TypeName
        : SpecifierQualifierList
        | SpecifierQualifierList AbstractDeclarator
        ;

AbstractDeclarator
        : Pointer
        |         DirectAbstractDeclarator
        | Pointer DirectAbstractDeclarator
        ;

DirectAbstractDeclarator
        : LPAREN AbstractDeclarator RPAREN
        |                          LBRACKET                                               RBRACKET
        |                          LBRACKET                          AssignmentExpression RBRACKET
        |                          LBRACKET TypeQualifierList                             RBRACKET
        |                          LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        |                          LBRACKET                   STATIC AssignmentExpression RBRACKET
        |                          LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        |                          LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        |                          LBRACKET ASTERISK RBRACKET
        |                          LPAREN                   RPAREN
        |                          LPAREN ParameterTypeList RPAREN
        | DirectAbstractDeclarator LBRACKET                                               RBRACKET
        | DirectAbstractDeclarator LBRACKET                          AssignmentExpression RBRACKET
        | DirectAbstractDeclarator LBRACKET TypeQualifierList                             RBRACKET
        | DirectAbstractDeclarator LBRACKET TypeQualifierList        AssignmentExpression RBRACKET
        | DirectAbstractDeclarator LBRACKET                   STATIC AssignmentExpression RBRACKET
        | DirectAbstractDeclarator LBRACKET STATIC TypeQualifierList AssignmentExpression RBRACKET
        | DirectAbstractDeclarator LBRACKET TypeQualifierList STATIC AssignmentExpression RBRACKET
        | DirectAbstractDeclarator LBRACKET ASTERISK RBRACKET
        | DirectAbstractDeclarator LPAREN                   RPAREN
        | DirectAbstractDeclarator LPAREN ParameterTypeList RPAREN
        ; // TODO DirectAbstractDeсlaratorOpt

TypedefName
        : TYPEDEF_NAME
    //  | IDENTIFIER  // reduce/reduce with PrimaryExpression, resolved using lexical analyzer
        ; // TODO reduce/reduce, ISO/IEC 9899:2017, p. 99 (in PDF - 118)

Initializer
        : AssignmentExpression
        | LBRACE InitializerList       RBRACE
        | LBRACE InitializerList COMMA RBRACE
        ;

InitializerList
        :                                   Initializer
        |                       Designation Initializer
        | InitializerList COMMA             Initializer
        | InitializerList COMMA Designation Initializer
        ;

Designation
        : DesignatorList ASSIGN
        ;

DesignatorList
        :                Designator
        | DesignatorList Designator
        ;

Designator
        : LBRACKET ConstantExpression RBRACKET
        | DOT IDENTIFIER
        ;

StaticAssertDeclaration
        : STATIC_ASSERT LPAREN ConstantExpression COMMA STRING_LITERAL RPAREN SEMICOLON
        ;

// ISO/IEC 9899:2017, 6.8 Statements, p. 106-112

Statement
        : LabeledStatement
        | CompoundStatement
        | ExpressionStatement
        | SelectionStatement
        | IterationStatement
        | JumpStatement
        ;

LabeledStatement
        : IDENTIFIER COLON Statement
        | CASE ConstantExpression COLON Statement
        | DEFAULT COLON Statement
        ;

CompoundStatement
        : LBRACE               RBRACE
        | LBRACE BlockItemList RBRACE
        ;

BlockItemList
        :               BlockItem
        | BlockItemList BlockItem
        ;

BlockItem
        : Declaration
        | Statement
        ;

ExpressionStatement
        :            SEMICOLON
        | Expression SEMICOLON
        ;

SelectionStatement
        : IF     LPAREN Expression RPAREN Statement %prec NO_ELSE
        | IF     LPAREN Expression RPAREN Statement ELSE Statement
        | SWITCH LPAREN Expression RPAREN Statement
        ;

IterationStatement
        : WHILE LPAREN Expression RPAREN Statement
        | DO Statement WHILE LPAREN Expression RPAREN SEMICOLON
        | FOR LPAREN            SEMICOLON            SEMICOLON            RPAREN Statement
        | FOR LPAREN            SEMICOLON            SEMICOLON Expression RPAREN Statement
        | FOR LPAREN            SEMICOLON Expression SEMICOLON            RPAREN Statement
        | FOR LPAREN            SEMICOLON Expression SEMICOLON Expression RPAREN Statement
        | FOR LPAREN Expression SEMICOLON            SEMICOLON            RPAREN Statement
        | FOR LPAREN Expression SEMICOLON            SEMICOLON Expression RPAREN Statement
        | FOR LPAREN Expression SEMICOLON Expression SEMICOLON            RPAREN Statement
        | FOR LPAREN Expression SEMICOLON Expression SEMICOLON Expression RPAREN Statement
        | FOR LPAREN Declaration                     SEMICOLON            RPAREN Statement
        | FOR LPAREN Declaration                     SEMICOLON Expression RPAREN Statement
        | FOR LPAREN Declaration Expression          SEMICOLON            RPAREN Statement
        | FOR LPAREN Declaration Expression          SEMICOLON Expression RPAREN Statement
        ; // TODO ExpressionOpt

JumpStatement
        : GOTO IDENTIFIER   SEMICOLON
        | CONTINUE          SEMICOLON
        | BREAK             SEMICOLON
        | RETURN            SEMICOLON
        | RETURN Expression SEMICOLON
        ;

// ISO/IEC 9899:2017, 6.6 Constant expressions, p. 76-77

ConstantExpression
        : ConditionalExpression
        ;

// ISO/IEC 9899:2017, 6.5 Expressions, p. 55-75

Expression
        :                  AssignmentExpression
        | Expression COMMA AssignmentExpression
        ;

AssignmentExpression
        : ConditionalExpression
        | UnaryExpression AssignmentOperator AssignmentExpression
        ;

AssignmentOperator
        : ASSIGN
        | MUL_ASSIGN
        | DIV_ASSIGN
        | MOD_ASSIGN
        | ADD_ASSIGN
        | SUB_ASSIGN
        | LEFT_ASSIGN
        | RIGHT_ASSIGN
        | AND_ASSIGN
        | XOR_ASSIGN
        | OR_ASSIGN
        ;

ConditionalExpression
        : ArithmeticalExpression
        | ArithmeticalExpression QUESTION Expression COLON ConditionalExpression
        ;

ArithmeticalExpression
        : CastExpression
        | ArithmeticalExpression LOG_OR    ArithmeticalExpression
        | ArithmeticalExpression LOG_AND   ArithmeticalExpression
        | ArithmeticalExpression VERTICAL  ArithmeticalExpression
        | ArithmeticalExpression CARET     ArithmeticalExpression
        | ArithmeticalExpression AMPERSAND ArithmeticalExpression
        | ArithmeticalExpression EQ        ArithmeticalExpression
        | ArithmeticalExpression NE        ArithmeticalExpression
        | ArithmeticalExpression LS        ArithmeticalExpression
        | ArithmeticalExpression GR        ArithmeticalExpression
        | ArithmeticalExpression LE        ArithmeticalExpression
        | ArithmeticalExpression GE        ArithmeticalExpression
        | ArithmeticalExpression LSHIFT    ArithmeticalExpression
        | ArithmeticalExpression RSHIFT    ArithmeticalExpression
        | ArithmeticalExpression PLUS      ArithmeticalExpression
        | ArithmeticalExpression MINUS     ArithmeticalExpression
        | ArithmeticalExpression ASTERISK  ArithmeticalExpression
        | ArithmeticalExpression SLASH     ArithmeticalExpression
        | ArithmeticalExpression PERCENT   ArithmeticalExpression
        ;

CastExpression
        : UnaryExpression
        | LPAREN TypeName RPAREN CastExpression
        ;

UnaryExpression
        : PostfixExpression
        | DBL_PLUS  UnaryExpression
        | DBL_MINUS UnaryExpression
        | UnaryOperator CastExpression
        | SIZEOF UnaryExpression
        | SIZEOF LPAREN TypeName RPAREN
        | ALIGNOF LPAREN TypeName RPAREN
        ;

UnaryOperator
        : AMPERSAND
        | ASTERISK
        | PLUS
        | MINUS
        | TILDE
        | BANG
        ;

PostfixExpression
        : PrimaryExpression
        | PostfixExpression LBRACKET Expression RBRACKET
        | PostfixExpression LPAREN                        RPAREN
        | PostfixExpression LPAREN ArgumentExpressionList RPAREN
        | PostfixExpression DOT   IDENTIFIER
        | PostfixExpression ARROW IDENTIFIER
        | PostfixExpression DBL_PLUS
        | PostfixExpression DBL_MINUS
        | LPAREN TypeName RPAREN LBRACE InitializerList       RBRACE
        | LPAREN TypeName RPAREN LBRACE InitializerList COMMA RBRACE
        ;

ArgumentExpressionList
        :                              AssignmentExpression
        | ArgumentExpressionList COMMA AssignmentExpression
        ;

PrimaryExpression
        : IDENTIFIER
        | Constant
        | STRING_LITERAL
        | LPAREN Expression RPAREN
        | GenericSelection
        ;

Constant
        : INTEGER_CONSTANT
        | FLOATING_CONSTANT
    //  | EnumerationConstant  // reduce/reduce with PrimaryExpression, identical to IDENTIFIER
        | CHARACTER_CONSTANT
        ;

GenericSelection
        : GENERIC LPAREN AssignmentExpression COMMA GenericAssocList RPAREN
        ;

GenericAssocList
        :                        GenericAssociation
        | GenericAssocList COMMA GenericAssociation
        ;

GenericAssociation
        : TypeName COLON AssignmentExpression
        | DEFAULT  COLON AssignmentExpression
        ;

%%

/// Called when parse error was detected.
char const *yyerror(const char *str) {
    fprintf(stderr, "yyerror: %s\n", str);
}

/// Program entry point.
int main() {
    yydebug = 1;  // TODO: REMOVE IN PROD, set 0 for no debug info.
    return yyparse();
}