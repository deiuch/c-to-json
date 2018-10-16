/**
 * Abstract Syntax Tree building functions for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#ifndef C_PARSER_AST_BUILDER_H_INCLUDED
#define C_PARSER_AST_BUILDER_H_INCLUDED

/// Types of AST node content.
typedef enum
{
    TranslationUnit,
    FunctionDefinition,
    DeclarationList,
    Declaration,
    DeclarationSpecifiers,
    InitDeclaratorList,
    InitDeclarator,
    StorageClassSpecifier,
    TypeSpecifier,
    StructSpecifier,
    UnionSpecifier,
    StructDeclarationList,
    StructDeclaration,
    SpecifierQualifierList,
    StructDeclaratorList,
    StructDeclarator,
    EnumSpecifier,
    EnumeratorList,
    Enumerator,
    AtomicTypeSpecifier,
    TypeQualifier,
    FunctionSpecifier,
    AlignmentSpecifier,
    Declarator,
    DirectDeclarator,
    DirectDeclaratorBrackets,
    DirectDeclaratorParen,
    Pointer,
    TypeQualifierList,
    ParameterList,
    ParameterDeclaration,
    IdentifierList,
    TypeName,
    AbstractDeclarator,
    DirectAbstractDeclarator,
    DirectAbstractDeclaratorBrackets,
    DirectAbstractDeclaratorParen,
    Initializer,
    InitializerList,
    InitializerListElem,
    DesignatorList,
    StaticAssertDeclaration,
    LabeledStatement,
    BlockItemList,
    SelectionStatement,
    IterationStatement,
    JumpStatement,
    Expression,
    AssignmentExpression,
    AssignmentOperator,
    ConditionalExpression,
    ArithmeticalExpression,
    CastExpression,
    UnaryExpression,
    UnaryOperator,
    PostfixExpression,
    ArgumentExpressionList,
    GenericSelection,
    GenericAssocList,
    GenericAssociation,
    Identifier,
    StringLiteral,
    IntegerConstant,
    FloatingConstant,
    CharacterConstant,
}
AST_NODE_TYPE;

typedef union
{
    int token;
    void *value;
}
AST_CONTENT;

/// Structure for storing AST node data.
typedef struct AST_NODE
{
    AST_NODE_TYPE type;
    AST_CONTENT content;
    int children_number;
    struct AST_NODE **children;
}
AST_NODE;

/// Root of built AST after parsing.
AST_NODE *ast_root;

/// Create node with a given set of children.
/// Needs to be freed.
///
/// \param type Type of AST node
/// \param content Content to store in the node
/// \param n_children Number of children
/// \param ... List of children
/// \return New AST node
AST_NODE *ast_create_node(AST_NODE_TYPE type, AST_CONTENT content, int n_children, ...);

/// Append given child to the given AST node.
///
/// \param node Node to append child to
/// \param to_append Child to append to the node
/// \return New node after expansion
AST_NODE *ast_expand_node(AST_NODE *node, AST_NODE *to_append);

/// Convert enum AST_NODE_TYPE to string.
///
/// \param type Enum value to convert
/// \return Actual string representation of a value
char *ast_type_to_str(AST_NODE_TYPE type);

/// Free memory associated with node and it's children.
///
/// \param root Root of the tree to be freed recursively
void ast_free(AST_NODE *root);

/// Get JSON string representation of an AST. Needs to be freed.
///
/// \param root Root of the tree to be converted to JSON
/// \param shift Shift size at the beginning of line
/// \param tab String representation of the tabulation
/// \param cont_to_str Function for printing the content of the node
/// \return JSON representation of a tree
char *ast_to_json(AST_NODE *root, int shift, char *tab, char *(*cont_to_str)(AST_NODE *));

#endif //C_PARSER_AST_BUILDER_H_INCLUDED
