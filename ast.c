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

AST_NODE *ast_create_node(AST_NODE_TYPE type, AST_CONTENT content, int n_children, ...)
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
    if (!node || !to_append)
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
        case TranslationUnit: return "TranslationUnit";
        case FunctionDefinition: return "FunctionDefinition";
        case DeclarationList: return "DeclarationList";
        case Declaration: return "Declaration";
        case DeclarationSpecifiers: return "DeclarationSpecifiers";
        case InitDeclaratorList: return "InitDeclaratorList";
        case InitDeclarator: return "InitDeclarator";
        case StorageClassSpecifier: return "StorageClassSpecifier";
        case TypeSpecifier: return "TypeSpecifier";
        case StructSpecifier: return "StructSpecifier";
        case UnionSpecifier: return "UnionSpecifier";
        case StructDeclarationList: return "StructDeclarationList";
        case StructDeclaration: return "StructDeclaration";
        case SpecifierQualifierList: return "SpecifierQualifierList";
        case StructDeclaratorList: return "StructDeclaratorList";
        case StructDeclarator: return "StructDeclarator";
        case EnumSpecifier: return "EnumSpecifier";
        case EnumeratorList: return "EnumeratorList";
        case Enumerator: return "Enumerator";
        case AtomicTypeSpecifier: return "AtomicTypeSpecifier";
        case TypeQualifier: return "TypeQualifier";
        case FunctionSpecifier: return "FunctionSpecifier";
        case AlignmentSpecifier: return "AlignmentSpecifier";
        case Declarator: return "Declarator";
        case DirectDeclarator: return "DirectDeclarator";
        case DirectDeclaratorBrackets: return "DirectDeclaratorBrackets";
        case DirectDeclaratorParen: return "DirectDeclaratorParen";
        case Pointer: return "Pointer";
        case TypeQualifierList: return "TypeQualifierList";
        case ParameterList: return "ParameterList";
        case ParameterDeclaration: return "ParameterDeclaration";
        case IdentifierList: return "IdentifierList";
        case TypeName: return "TypeName";
        case AbstractDeclarator: return "AbstractDeclarator";
        case DirectAbstractDeclarator: return "DirectAbstractDeclarator";
        case DirectAbstractDeclaratorBrackets: return "DirectAbstractDeclaratorBrackets";
        case DirectAbstractDeclaratorParen: return "DirectAbstractDeclaratorParen";
        case Initializer: return "Initializer";
        case InitializerList: return "InitializerList";
        case InitializerListElem: return "InitializerListElem";
        case DesignatorList: return "DesignatorList";
        case StaticAssertDeclaration: return "StaticAssertDeclaration";
        case LabeledStatement: return "LabeledStatement";
        case BlockItemList: return "BlockItemList";
        case SelectionStatement: return "SelectionStatement";
        case IterationStatement: return "IterationStatement";
        case JumpStatement: return "JumpStatement";
        case Expression: return "Expression";
        case AssignmentExpression: return "AssignmentExpression";
        case AssignmentOperator: return "AssignmentOperator";
        case ConditionalExpression: return "ConditionalExpression";
        case ArithmeticalExpression: return "ArithmeticalExpression";
        case CastExpression: return "CastExpression";
        case UnaryExpression: return "UnaryExpression";
        case UnaryOperator: return "UnaryOperator";
        case PostfixExpression: return "PostfixExpression";
        case ArgumentExpressionList: return "ArgumentExpressionList";
        case GenericSelection: return "GenericSelection";
        case GenericAssocList: return "GenericAssocList";
        case GenericAssociation: return "GenericAssociation";
        case Identifier: return "Identifier";
        case StringLiteral: return "StringLiteral";
        case IntegerConstant: return "IntegerConstant";
        case FloatingConstant: return "FloatingConstant";
        case CharacterConstant: return "CharacterConstant";
        default: return NULL;
    }
}

void ast_free(AST_NODE *root)
{
    if (root == NULL) return;
    if (root->type == CharacterConstant || root->type == Identifier || root->type == StringLiteral
        || root->type == IntegerConstant || root->type == FloatingConstant) {
        free(root->content.value);
    }
    for (int i = 0; i < root->children_number; ++i)
    {
        ast_free(root->children[i]);
    }
    free(root);
}

char *ast_to_json(AST_NODE *root, int shift, char *tab, char *(*cont_to_str)(AST_NODE *))
{
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

    // Get string representation of `type' field
    char *type_str = ast_type_to_str(root->type);

    // Get string representation of `node' content
    char *content_str;
    if (root->content.value)
    {
        char *tmp = (*cont_to_str)(root);
        if (!tmp)
        {
            goto null_content;
        }
        content_str = wrap_by_quotes(tmp);
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
            free(content_str);
            exit(-1);
        }
    }

    // Get string representation of `children_number' field
    char *children_num_str = (char *) my_malloc(7, "number representation");
    itoa(root->children_number, children_num_str, 10);

    // Get string representation of `children' array field
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
        for (i = 0; i < root->children_number; ++i) free(children[i]);
        size_t size = strlen(arr) + strlen(tab) * (shift + 1) + sizeof(char) * (4 + 1);
        children_str = (char *) my_malloc(size, "children array string");
        res = sprintf(children_str, "[\n%s\n%s%s]", arr, act_tab, tab);
        free(arr);
        if (res < 0)
        {
            fprintf(stderr,
                    "FATAL ERROR! String formatting cannot be applied!\n");
            free(act_tab);
            free(content_str);
            free(children_num_str);
            free(children_str);
            exit(-1);
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
            + sizeof(char) * (62 + 1);
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
