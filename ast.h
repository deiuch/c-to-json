/**
 * Abstract Syntax Tree building functions for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#ifndef C_PARSER_AST_BUILDER_H_INCLUDED
#define C_PARSER_AST_BUILDER_H_INCLUDED

typedef struct {} astnode;  // TODO node struct

// TODO node building functions

void ast_free(astnode *root);

char *ast_to_json(astnode *root);

#endif //C_PARSER_AST_BUILDER_H_INCLUDED
