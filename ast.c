/**
 * Abstract Syntax Tree building functions for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ast.h"
#include "string_tools.h"

AST_NODE *ast_root = NULL;

AST_NODE *ast_create_node(AST_NODE_TYPE type, void *content, int n_children, ...)
{
    AST_NODE *res = malloc(sizeof(AST_NODE));
    if (!res)
    {
        fprintf(stderr,
            "FATAL ERROR! Memory for AST node cannot be allocated!\n");
        exit(-1);
    }
    *res = (AST_NODE) {type, content, n_children, NULL};
    va_list ap;
    int i = 0;
    if (n_children > 0)
    {
        res->children = (AST_NODE **) malloc(sizeof(AST_NODE *) * n_children);
        if (!res->children)
        {
            fprintf(stderr,
                    "FATAL ERROR! Memory for AST node's children cannot be allocated!\n");
            exit(-1);
        }
        va_start(ap, n_children);
        while (i < n_children)
        {
            res->children[i++] = va_arg(ap, AST_NODE *);
        }
        va_end(ap);
    }
    return (AST_NODE *) malloc(0);  // TODO, see ISO/IEC 9899:2017, page 197 (in PDF - 216)
}

AST_NODE *ast_expand_node(AST_NODE *node, AST_NODE *to_append)
{
    if (!node)
    {
        return node;
    }
    ++node->children_number;
    realloc(node->children, sizeof(AST_NODE *) * node->children_number);
    if (!node->children)
    {
        fprintf(stderr,
            "FATAL ERROR! Memory for AST node's children cannot be reallocated!\n");
        exit(-1);
    }
    node->children[node->children_number - 1] = to_append;
    return node;
}

char *ast_type_to_str(AST_NODE_TYPE type)
{
    switch (type)
    {
        default: return NULL;  // TODO
    }
}

void ast_free(AST_NODE *root) {
    free(root->content);
    for (int i = 0; i < root->children_number; ++i)
    {
        ast_free(root->children[i]);
    }
    free(root);
}

char *ast_to_json(AST_NODE *root, int shift, char *tab) {
    int i;
    char **children = (char **) malloc(sizeof(char *) * root->children_number);
    for (i = 0; i < root->children_number; ++i)
    {
        children[i] = ast_to_json(root->children[i], shift + 2, tab);
    }

    char *conc_children = concat_array(children, root->children_number, ",\n");
    for (i = 0; i < root->children_number; ++i)
    {
        free(children[i]);
    }
    free(children);

    char *json = (char *) malloc(/* TODO */);
    if (!json)
    {
        fprintf(stderr,
            "FATAL ERROR! Memory for JSON representation cannot be allocated!\n");
        exit(-1);
    }
    char *act_tab = repeat(shift, tab);
    int res = sprintf(json,
                      "%s{\n"
                      "%s%s\"type\": \"%s\",\n"
                      "%s%s\"content\": \"%s\",\n"
                      "%s%s\"children_number\": %d,\n"
                      "%s%s\"children\": [\n"
                      "%s"
                      "%s%s]"
                      "%s}",
                      act_tab,
                      act_tab, tab, ast_type_to_str(root->type),
                      act_tab, tab, "", // TODO
                      act_tab, tab, root->children_number,
                      act_tab, tab,
                      conc_children,
                      act_tab, tab,
                      act_tab);
    free(conc_children);
    free(act_tab);
    if (res < 0)
    {
        fprintf(stderr,
            "FATAL ERROR! String formatting cannot be applied!\n");
        exit(-1);
    }
    return json;
}
