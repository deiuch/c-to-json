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
    // TODO content types
} AST_NODE_TYPE;

/// Structure for storing AST node data.
typedef struct AST_NODE
{
    AST_NODE_TYPE type;
    int children_number;
    struct AST_NODE **children;
} AST_NODE;

/// Root of built AST after parsing.
AST_NODE *ast_root;

// TODO node building functions

/// Free memory associated with node and it's children.
void ast_free(AST_NODE *node);

/// Get JSON string representation of an AST.
char *ast_to_json(AST_NODE *root);

#endif //C_PARSER_AST_BUILDER_H_INCLUDED
