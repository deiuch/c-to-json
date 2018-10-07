/**
 * Abstract Syntax Tree building functions for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#ifndef C_PARSER_AST_BUILDER_H_INCLUDED
#define C_PARSER_AST_BUILDER_H_INCLUDED

/// Structure for storing AST node data.
typedef struct
{
    // TODO node struct
} astnode;

/// Root of built AST after parsing.
astnode *astroot;

// TODO node building functions

/// Free memory associated with node and it's children.
void ast_free(astnode *node);

/// Get JSON string representation of an AST.
char *ast_to_json(astnode *root);

#endif //C_PARSER_AST_BUILDER_H_INCLUDED
