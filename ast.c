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

char *ast_to_json(AST_NODE *root, int shift, char *tab, char *(*cont_to_str)(void *)) {
    char *json;
    char *act_tab = repeat(shift, tab);
    int res;

    // If given NULL root
    if (!root)
    {
        json = (char *) my_malloc(sizeof(char) * (shift * strlen(tab) + 5),
                "JSON representation");
        res = sprintf(json, "%snull", act_tab);
        free(act_tab);
        if (res < 0)
        {
            fprintf(stderr,
                "FATAL ERROR! String formatting cannot be applied!\n");
            free(json);
            free(act_tab);
            exit(-1);
        }
        return json;
    }

    // Get string representation of type field
    char *type_str = ast_type_to_str(root->type);

    // Get string representation of node content
    char *content_str;
    if (root->content)
    {
        content_str = (*cont_to_str)(root->content);
        if (!content_str)
        {
            goto null_content;
        }
    }
    else
    {
        null_content:
        content_str = (char *) my_malloc(sizeof(char) * 5, "JSON null");
        res = sprintf(content_str, "null");
        if (res < 0)
        {
            fprintf(stderr,
                    "FATAL ERROR! String formatting cannot be applied!\n");
            free(act_tab);
            free(type_str);
            free(content_str);
            exit(-1);
        }
    }

    // Get string representation of children amount
    char *children_num_str = (char *) my_malloc(7, "number representation");  // TODO size
    itoa(root->children_number, children_num_str, 10);

    // Get string representation of children array
    int i;
    char **children = (char **) malloc(sizeof(char *) * root->children_number);
    for (i = 0; i < root->children_number; ++i)
    {
        children[i] = ast_to_json(root->children[i], shift + 2, tab, cont_to_str);
    }
    char *children_str;
    if (root->children)
    {
        char *arr = concat_array(children, root->children_number, ",\n");
        size_t size = strlen(arr) + strlen(tab) * (shift + 1) + sizeof(char) * (5 + 1);
        children_str = (char *) my_malloc(size, "children array string");
        res = sprintf(children_str, "[\n%s\n%s%s]\n", arr, act_tab, tab);
        free(arr);
        if (res < 0)
        {
            fprintf(stderr,
                    "FATAL ERROR! String formatting cannot be applied!\n");
            free(act_tab);
            free(type_str);
            free(content_str);
            free(children_num_str);
            free(children_str);
            exit(-1);
        }
        for (i = 0; i < root->children_number; ++i)
        {
            free(children[i]);
        }
        free(children);
    }
    else
    {
        children_str = (char *) my_malloc(sizeof(char) * 5, "JSON null");
        res = sprintf(children_str, "null");
        if (res < 0)
        {
            fprintf(stderr,
                    "FATAL ERROR! String formatting cannot be applied!\n");
            free(act_tab);
            free(type_str);
            free(content_str);
            free(children_num_str);
            free(children_str);
            exit(-1);
        }
    }

    // Concatenate the resulting JSON object
    size_t json_size
            = strlen(type_str)
            + strlen(content_str)
            + strlen(children_num_str)
            + strlen(children_str)
            + strlen(tab) * (shift * 6 + 4)
            + sizeof(char) * (62 + 1);  // TODO check
    json = (char *) my_malloc(json_size, "JSON representation");
    res = sprintf(json,
                  "%s{\n"
                  "%s%s\"type\": \"%s\",\n"
                  "%s%s\"content\": %s,\n"
                  "%s%s\"children_number\": %s,\n"
                  "%s%s\"children\": %s\n"
                  "%s}",
                  act_tab,
                  act_tab, tab, type_str,
                  act_tab, tab, content_str,
                  act_tab, tab, children_num_str,
                  act_tab, tab, children_str,
                  act_tab);
    free(act_tab);
    free(type_str);
    free(content_str);
    free(children_num_str);
    free(children_str);
    if (res < 0)
    {
        fprintf(stderr,
            "FATAL ERROR! String formatting cannot be applied!\n");
        exit(-1);
    }
    return json;
}
