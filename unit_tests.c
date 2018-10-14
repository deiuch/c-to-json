/**
 * Unit tests for parser of the
 * C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include "ast.h"
#include "string_tools.h"
#include "typedef_name.h"

int passed = 0;
int failed = 0;

void pass_test(_Bool result, char *label)
{
    if (result)
    {
        ++passed;
    }
    else
    {
        ++failed;
        printf("Failed test #%d:\n%s\n", passed + failed, label);
    }
}

int main()
{
    // Test `str_eq'
    printf("Start of testing.\n\n");
    pass_test(str_eq(NULL, NULL), "str_eq(NULL, NULL)");
    pass_test(!str_eq(NULL, ""), "!str_eq(NULL, \"\")");
    pass_test(str_eq("", ""), "str_eq(\"\", \"\")");
    pass_test(!str_eq("b", "a"), "!str_eq(\"b\", \"a\")");
    pass_test(str_eq("aaa", "aaa"), "str_eq(\"aaa\", \"aaa\")");

    // Test `repeat'
    pass_test(str_eq(repeat(4, "a"), "aaaa"), "repeat(4, \"a\")");
    pass_test(str_eq(repeat(0, "a"), ""), "repeat(0, \"a\")");
    pass_test(str_eq(repeat(-10, "a"), NULL), "repeat(-10, \"a\")");
    pass_test(str_eq(repeat(1, "a"), "a"), "repeat(1, \"a\")");
    pass_test(str_eq(repeat(3, ""), ""), "repeat(3, \"\")");
    pass_test(str_eq(repeat(2, NULL), NULL), "repeat(2, NULL)");

    // Test `concat_array'
    pass_test(str_eq(concat_array((char*[]) {"a", "b", "c", "d"}, 4, ", "), "a, b, c, d"),
        "concat_array((char*[]){\"a\", \"b\", \"c\", \"d\"}, 4, \", \")");
    pass_test(str_eq(concat_array((char*[]) {"a", "", "c"}, 3, ", "), "a, , c"),
        "concat_array((char*[]){\"a\", \"\", \"c\"}, 3, \", \")");
    pass_test(str_eq(concat_array((char*[]) {"a", NULL}, 2, ", "), "a, "),
        "concat_array((char*[]){\"a\", NULL}, 2, \", \")");
    pass_test(str_eq(concat_array(NULL, 2, ", "), NULL),
         "concat_array(NULL, 2, \", \")");
    pass_test(str_eq(concat_array((char*[]) {"a", NULL}, -1, ", "), NULL),
         "concat_array((char*[]){\"a\", NULL}, 2, \", \")");
    pass_test(str_eq(concat_array((char*[]) {"a", NULL}, 2, NULL), NULL),
         "concat_array((char*[]){\"a\", NULL}, 2, NULL)");
    pass_test(str_eq(concat_array((char*[]) {"a"}, 0, ", "), ""),
         "concat_array((char*[]){\"a\", NULL}, 2, NULL)");

    // Test `wrap_by_quotes'
    pass_test(str_eq(wrap_by_quotes("\" \\ \b \f \n \r \t"), "\"\\\" \\\\ \\b \\f \\n \\r \\t\""),
         "wrap_by_quotes(\"\\\" \\\\ \\b \\f \\n \\r \\t\")");
    pass_test(str_eq(wrap_by_quotes(NULL), NULL), "wrap_by_quotes(NULL)");
    pass_test(str_eq(wrap_by_quotes(""), "\"\""), "wrap_by_quotes(\"\")");

    // Test `is_typedef_name'
    put_typedef_name("a");
    pass_test(is_typedef_name("a"), "put_typedef_name(\"a\");\nis_typedef_name(\"a\")");
    pass_test(!is_typedef_name("b"), "put_typedef_name(\"a\");\nis_typedef_name(\"b\")");
    add_std_typedef("math.h");
    pass_test(is_typedef_name("float_t"), "add_std_typedef(\"math.h\");\nis_typedef_name(\"float_t\")");
    pass_test(!is_typedef_name("real_t"), "add_std_typedef(\"math.h\");\nis_typedef_name(\"real_t\")");

    // Test `ast_type_to_str'
    pass_test(str_eq(ast_type_to_str(TranslationUnit), "TranslationUnit"), "ast_type_to_str(TranslationUnit)");
    pass_test(str_eq(ast_type_to_str(-1),NULL), "ast_type_to_str(-1)");

    //Test `ast_expand_node'
    AST_NODE* ast_node = ast_create_node(TranslationUnit, NULL, 0);
    AST_NODE* ast_node_to_add = ast_create_node(TranslationUnit, NULL, 0);
    AST_NODE* ast_node_expanded = ast_create_node(TranslationUnit, NULL, 0);
    ast_expand_node(ast_node, ast_node_to_add);
    pass_test(ast_expand_node(ast_node, ast_node_to_add)->type == ast_node->type,
         "AST_NODE* ast_node = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_to_add = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_expanded = ast_expand_node(ast_node, ast_node_to_add);\n"
         "ast_expand_node(ast_node, ast_node_to_add)->type == ast_node->type");
    ast_node = ast_create_node(TranslationUnit, NULL, 0);
    pass_test(ast_expand_node(ast_node, ast_node_to_add)->content == ast_node->content,
         "AST_NODE* ast_node = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_to_add = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_expanded = ast_expand_node(ast_node, ast_node_to_add);\n"
         "ast_expand_node(ast_node, ast_node_to_add)->content == ast_node->content");
    ast_node = ast_create_node(TranslationUnit, NULL, 0);
    pass_test(ast_expand_node(ast_node, ast_node_to_add)->children_number == ast_node->children_number,
         "AST_NODE* ast_node = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_to_add = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_expanded = ast_expand_node(ast_node, ast_node_to_add);\n"
         "ast_expand_node(ast_node, ast_node_to_add)->children_number == ast_node->children_number");
    ast_node = ast_create_node(TranslationUnit, NULL, 0);
    pass_test(ast_expand_node(ast_node, ast_node_to_add)->children == ast_node->children,
         "AST_NODE* ast_node = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_to_add = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_expanded = ast_expand_node(ast_node, ast_node_to_add);\n"
         "ast_expand_node(ast_node, ast_node_to_add)->children == ast_node->children");
    pass_test(ast_expand_node(NULL, ast_node_to_add) == NULL,
         "AST_NODE* ast_node = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_to_add = ast_create_node(TranslationUnit, NULL, 0);\n"
         "ast_expand_node(NULL, ast_node_to_add) == NULL");
    ast_node = ast_create_node(TranslationUnit, NULL, 0);
    pass_test(ast_expand_node(ast_node, NULL)->children_number == 0,
         "AST_NODE* ast_node = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_to_add = ast_create_node(TranslationUnit, NULL, 0);\n"
         "ast_expand_node(ast_node, NULL)->children_number == 0");
    ast_node = ast_create_node(TranslationUnit, NULL, 0);
    pass_test(ast_expand_node(ast_node, NULL)->children == NULL,
         "AST_NODE* ast_node = ast_create_node(TranslationUnit, NULL, 0);\n"
         "AST_NODE* ast_node_to_add = ast_create_node(TranslationUnit, NULL, 0);\n"
         "ast_expand_node(ast_node, NULL)->children == NULL");
    // TODO ast: ast_create_node, ast_to_json.

    printf("\nResults:\n Total number of tests: %d\n Passed: %d\n Failed: %d\n",
        passed + failed, passed, failed);
    return 0;
}
