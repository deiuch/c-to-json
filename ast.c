/**
 * Abstract Syntax Tree building functions for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdio.h>
#include <stdlib.h>
#include "ast.h"

// TODO node building functions

void ast_free(ast_node *node) {
    // TODO tree free
}

char *ast_to_json(ast_node *root) {
    char *res = (char *) malloc(0);
    if (!res)
    {
        fprintf(stderr,
                "FATAL ERROR! Memory for JSON string cannot be allocated!\n");
        exit(-1);
    }
    // TODO JSON representation
    return res;
}
