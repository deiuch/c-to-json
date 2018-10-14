/**
 * Unit tests for parser of the
 * C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stddef.h>
#include <stdio.h>
#include "ast.h"
#include "string_tools.h"
#include "typedef_name.h"

/// Conversion function for AST node content.
/// Copied from `main.c'.
///
/// \param obj Object of AST content
/// \return String representation of the given object, NULL if not AST_NODE
char *content_to_str(AST_NODE *node)
{
    return alloc_const_str((char *) node->content);
}

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
    pass_test(str_eq(concat_array((char *[]) {"a", "b", "c", "d"}, 4, ", "), "a, b, c, d"),
        "concat_array((char*[]){\"a\", \"b\", \"c\", \"d\"}, 4, \", \")");
    pass_test(str_eq(concat_array((char *[]) {"a", "", "c"}, 3, ", "), "a, , c"),
        "concat_array((char*[]){\"a\", \"\", \"c\"}, 3, \", \")");
    pass_test(str_eq(concat_array((char *[]) {"a", NULL}, 2, ", "), "a, "),
        "concat_array((char*[]){\"a\", NULL}, 2, \", \")");
    pass_test(str_eq(concat_array(NULL, 2, ", "), NULL),
         "concat_array(NULL, 2, \", \")");
    pass_test(str_eq(concat_array((char *[]) {"a", NULL}, -1, ", "), NULL),
         "concat_array((char*[]){\"a\", NULL}, 2, \", \")");
    pass_test(str_eq(concat_array((char *[]) {"a", NULL}, 2, NULL), NULL),
         "concat_array((char*[]){\"a\", NULL}, 2, NULL)");
    pass_test(str_eq(concat_array((char *[]) {"a"}, 0, ", "), ""),
         "concat_array((char*[]){\"a\", NULL}, 2, NULL)");

    // Test `wrap_by_quotes'
    pass_test(str_eq(wrap_by_quotes("\" \\ \b \f \n \r \t"), "\"\\\" \\\\ \\b \\f \\n \\r \\t\""),
         "wrap_by_quotes(\"\\\" \\\\ \\b \\f \\n \\r \\t\")");
    pass_test(str_eq(wrap_by_quotes(NULL), NULL), "wrap_by_quotes(NULL)");
    pass_test(str_eq(wrap_by_quotes(""), "\"\""), "wrap_by_quotes(\"\")");

    // Test `ast_create_node'
    AST_NODE *node1 = ast_create_node(Identifier, "node1", 0);
    pass_test(node1->type == Identifier,
        "ast_create_node(Identifier, \"node1\", 0); node1->type == Identifier;");
    pass_test(str_eq(node1->content, "node1"),
        "ast_create_node(Identifier, \"node1\", 0); node1->content == \"node1\";");
    pass_test(node1->children_number == 0,
        "ast_create_node(Identifier, \"node1\", 0); node1->children_number == 0;");
    pass_test(node1->children == NULL,
        "ast_create_node(Identifier, \"node1\", 0); node1->children == NULL;");

    AST_NODE *node2 = ast_create_node(Identifier, "node2", 1, node1);
    pass_test(node2->children_number == 1,
        "ast_create_node(Identifier, \"node2\", 1, node1); node2->children_number == 1;");
    pass_test(node2->children != NULL,
        "ast_create_node(Identifier, \"node2\", 1, node1); node2->children != NULL;");
    pass_test(node2->children[0] == node1,
        "ast_create_node(Identifier, \"node2\", 1, node1); node2->children[0] == node1;");

    AST_NODE *node3 = ast_create_node(Identifier, "node3", 2, node1, node2);
    pass_test(node3->children_number == 2,
        "ast_create_node(Identifier, \"node3\", 2, node1, node2); node3->children_number == 2;");
    pass_test(node3->children != NULL,
        "ast_create_node(Identifier, \"node3\", 2, node1, node2); node3->children != NULL;");
    pass_test(node3->children[0] == node1,
        "ast_create_node(Identifier, \"node3\", 2, node1, node2); node3->children[0] == node1;");
    pass_test(node3->children[1] == node2,
        "ast_create_node(Identifier, \"node3\", 2, node1, node2); node3->children[1] == node2;");

    // Test `ast_expand_node'

    // Test `ast_type_to_str'

    // Test `ast_to_json'
    char *json1 = "{\n"
                  "    \"type\": \"Identifier\",\n"
                  "    \"content\": \"node1\",\n"
                  "    \"children_number\": 0,\n"
                  "    \"children\": null\n"
                  "}";
    pass_test(str_eq(ast_to_json(node1, 0, "    ", content_to_str), json1),
        "ast_to_json(node1, 0, \"    \", content_to_str)");
    char *json2 = "        {\n"
                  "            \"type\": \"Identifier\",\n"
                  "            \"content\": \"node1\",\n"
                  "            \"children_number\": 0,\n"
                  "            \"children\": null\n"
                  "        }";
    pass_test(str_eq(ast_to_json(node1, 2, "    ", content_to_str), json2),
        "ast_to_json(node1, 2, \"    \", content_to_str)");

    printf("\nResults:\n Total number of tests: %d\n Passed: %d\n Failed: %d\n",
        passed + failed, passed, failed);
    return 0;
}
