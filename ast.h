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
} ast_content;

/// Structure for storing AST node data.
typedef struct ast_node
{
    ast_content type;
    int children_number;
    struct ast_node *children;
} ast_node;

/// Root of built AST after parsing.
ast_node *ast_root;

// TODO node building functions

/// Free memory associated with node and it's children.
void ast_free(ast_node *node);

/// Get JSON string representation of an AST.
char *ast_to_json(ast_node *root);

#endif //C_PARSER_AST_BUILDER_H_INCLUDED
