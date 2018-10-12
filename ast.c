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
#include "alloc_wrap.h"
#include "ast.h"
#include "string_tools.h"

AST_NODE *ast_root = NULL;

AST_NODE *ast_create_node(AST_NODE_TYPE type, void *content, int n_children, ...)
{
    AST_NODE *res = (AST_NODE *) my_malloc(sizeof(AST_NODE), "AST node");
    *res = (AST_NODE) {type, content, n_children, NULL};
    va_list ap;
    int i = 0;
    if (n_children > 0)
    {
        res->children = (AST_NODE **)
            my_malloc(sizeof(AST_NODE *) * n_children, "AST node's children");
        va_start(ap, n_children);
        while (i < n_children)
        {
            res->children[i++] = va_arg(ap, AST_NODE *);
        }
        va_end(ap);
    }
    return res;
}

AST_NODE *ast_expand_node(AST_NODE *node, AST_NODE *to_append)
{
    if (!node)
    {
        return node;
    }
    ++node->children_number;
    node->children = my_realloc(node->children,
            sizeof(AST_NODE *) * node->children_number, "AST node's children");
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
    if (root == NULL) return;
    free(root->content);
    for (int i = 0; i < root->children_number; ++i)
    {
        ast_free(root->children[i]);
    }
    free(root);
}

char *ast_to_json(AST_NODE *root, int shift, char *tab) {
    char *json;
    char *act_tab = repeat(shift, tab);
    int res;
    if (!root)
    {
        json = (char *) my_malloc(sizeof(char) * (shift * strlen(tab) + 5),
                "JSON representation");
        res = sprintf(json, "%snull", act_tab);
        free(act_tab);
        if (!res)
        {
            fprintf(stderr,
                "FATAL ERROR! String formatting cannot be applied!\n");
            exit(-1);
        }
        return json;
    }
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

    json = (char *) my_malloc(sizeof(char) * (0 + 1),  // TODO strlen(json) after `sprintf' instead 0
            "JSON representation");
    res = sprintf(json,
                  "%s{\n"
                  "%s%s\"type\": \"%s\",\n"
                  "%s%s\"content\": %s,\n"
                  "%s%s\"children_number\": %d,\n"
                  "%s%s\"children\": %s\n"
                  "%s}",
                  act_tab,
                  act_tab, tab, ast_type_to_str(root->type),
                  act_tab, tab, root->content ? "\"content\"" : "null",  // TODO content representation
                  act_tab, tab, root->children_number,
                  act_tab, tab, root->children ? "[\nconc_children\n%s%s]" : "null",  // TODO array
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
