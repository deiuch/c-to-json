/**
 * Unit tests for parser of the
 * C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#include "string_tools.h"

int passed = 0;
int failed = 0;

void pass_test(_Bool result, char *label)
{
    if (result) {
        ++passed;
    } else {
        ++failed;
        printf("Failed test #%d:\n", passed + failed);
        printf(label);
        printf("\n");
    }
}

int main()
{
    printf("Start of testing.\n\n");
    pass_test(str_eq(NULL, NULL), "str_eq(NULL, NULL)"); // Test str_eq
    pass_test(!str_eq(NULL, ""), "!str_eq(NULL, \"\")");
    pass_test(str_eq("", ""), "str_eq(\"\", \"\")");
    pass_test(!str_eq("b", "a"), "!str_eq(\"b\", \"a\")");
    pass_test(str_eq("aaa", "aaa"), "str_eq(\"aaa\", \"aaa\")");
    pass_test(str_eq(repeat(4, "a"), "aaaa"), "repeat(4, \"a\")"); // Test repeat
    pass_test(str_eq(repeat(0, "a"), ""), "repeat(0, \"a\")");
    pass_test(str_eq(repeat(-10, "a"), NULL), "repeat(-10, \"a\")");
    pass_test(str_eq(repeat(1, "a"), "a"), "repeat(1, \"a\")");
    pass_test(str_eq(repeat(3, ""), ""), "repeat(3, \"\")");
    pass_test(str_eq(repeat(2, NULL), NULL), "repeat(2, NULL)");
    pass_test(str_eq(concat_array((char*[]) {"a", "b", "c", "d"}, 4, ", "), "a, b, c, d"),   // Test concat_array
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
    pass_test(str_eq(wrap_by_quotes("\" \\ \b \f \n \r \t"), "\"\\\" \\\\ \\b \\f \\n \\r \\t\""), // Test wrap_by_quotes
         "wrap_by_quotes(\"\\\" \\\\ \\b \\f \\n \\r \\t\")");
    pass_test(str_eq(wrap_by_quotes(NULL), NULL), "wrap_by_quotes(NULL)");
    pass_test(str_eq(wrap_by_quotes(""), "\"\""), "wrap_by_quotes(\"\")");

    //TODO: typedef : is_typedef_name, put_typedef_name, add_str_typedef.
    //TODO: ast : ast_create_node, ast_expand_node, ast_type_to_str, ast_to_json.

    printf("\nResults:\n Total number of tests: %d\n Passed: %d\n Failed: %d\n", passed + failed, passed, failed);
    return 0;
}


