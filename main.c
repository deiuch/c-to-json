/**
 * Entry point for parer for C Programming Language
 * (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

#include <stdio.h>
#include <stdlib.h>
#include "alloc_wrap.h"
#include "ast.h"
#include "string_tools.h"
#include "typedef_name.h"
#include "y.tab.h"

/// Input file for Flex.
extern FILE *yyin;

/// Conversion function for AST node content.
///
/// \param obj Object of AST content
/// \return String representation of the given node's content
char *content_to_str(AST_NODE *node)
{
    if (node->type == IntegerConstant)
    {
        return (char *) node->content.value;  // TODO constant types support
    }
    if (node->type == FloatingConstant)
    {
        return (char *) node->content.value;  // TODO constant types support
    }
    if (node->type == CharacterConstant)
    {
        char *res = (char *) my_malloc(sizeof(char) * 2,
            "character-constant representation");
        res[0] = *(char *) node->content.value;
        res[1] = '\0';
        return res;
    }
    if (node->type == Identifier || node->type == StringLiteral)
    {
        return (char *) node->content.value;
    }
    switch (node->content.token)
    {
        case AUTO: return "AUTO";
        case BREAK: return "BREAK";
        case CASE: return "CASE";
        case CHAR: return "CHAR";
        case CONST: return "CONST";
        case CONTINUE: return "CONTINUE";
        case DEFAULT: return "DEFAULT";
        case DO: return "DO";
        case DOUBLE: return "DOUBLE";
        case ELSE: return "ELSE";
        case ENUM: return "ENUM";
        case EXTERN: return "EXTERN";
        case FLOAT: return "FLOAT";
        case FOR: return "FOR";
        case GOTO: return "GOTO";
        case IF: return "IF";
        case INLINE: return "INLINE";
        case INT: return "INT";
        case LONG: return "LONG";
        case REGISTER: return "REGISTER";
        case RESTRICT: return "RESTRICT";
        case RETURN: return "RETURN";
        case SHORT: return "SHORT";
        case SIGNED: return "SIGNED";
        case SIZEOF: return "SIZEOF";
        case STATIC: return "STATIC";
        case STRUCT: return "STRUCT";
        case SWITCH: return "SWITCH";
        case TYPEDEF: return "TYPEDEF";
        case UNION: return "UNION";
        case UNSIGNED: return "UNSIGNED";
        case VOID: return "VOID";
        case VOLATILE: return "VOLATILE";
        case WHILE: return "WHILE";
        case ALIGNAS: return "ALIGNAS";
        case ALIGNOF: return "ALIGNOF";
        case ATOMIC: return "ATOMIC";
        case BOOL: return "BOOL";
        case COMPLEX: return "COMPLEX";
        case GENERIC: return "GENERIC";
        case IMAGINARY: return "IMAGINARY";
        case NORETURN: return "NORETURN";
        case STATIC_ASSERT: return "STATIC_ASSERT";
        case THREAD_LOCAL: return "THREAD_LOCAL";
        default: return NULL;
    }
}

/// Program entry point.
///
/// \param argc Size of `argv'
/// \param argv Arguments passed to the program
/// \return 0 - OK, 1 - processing error, 2 - args error, 3 - I/O error
int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        printf("Usage: %s <out_file> OR %s <in_file> <out_file>\n",
                argv[0], argv[0]);
        return 2;
    }

    int res;  // For results of I/O functions

    char *in_name = argc > 2 ? argv[1] : NULL;
    char *out_name = argc > 2 ? argv[2] : argv[1];

    yyin = in_name ? fopen(in_name, "r") : stdin;
    if (!yyin)
    {
        fprintf(stderr, "Cannot open for reading: %s\n", in_name);
        return 3;
    }

    AST_NODE *root = NULL;
    if (!in_name) printf("Input your code here (Ctrl+Z for EOF):\n");
    int yyres = yyparse((void **) &root);
    free_typedef_name();
    res = argc > 2 ? fclose(yyin) : 0;

    if (yyres || !root)
    {
        fprintf(stderr, "Parsing failed! No output will be provided.\n");
        return 1;
    }

    if (res == EOF)
    {
        fprintf(stderr, "Cannot close opened source file: %s\n", in_name);
        return 3;
    }

    char *json = ast_to_json(root, 0, "    ", &content_to_str);
    ast_free(root);
    if (!json)
    {
        fprintf(stderr, "JSON generation failure!\n");
        return 1;
    }

    FILE *out = fopen(argv[in_name ? 2 : 1], "w");
    if (!out)
    {
        fprintf(stderr, "Cannot open for writing: %s\n", out_name);
        return 3;
    }

    res = fputs(json, out);
    free(json);
    if (res == EOF)
    {
        fprintf(stderr, "Cannot write into opened target file: %s\n", out_name);
        return 3;
    }

    res = fclose(out);
    if (res == EOF)
    {
        fprintf(stderr, "Cannot close opened target file: %s\n", out_name);
        return 3;
    }

    return 0;
}
