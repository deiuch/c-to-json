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
        printf("Failed test #%d:\n", passed + failed + 1);
        printf(label);
        printf("\n");
        ++failed;
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
    pass_test(str_eq(repeat(4, "a"), "aaaa"), "str_eq(repeat(4, \"a\"), \"aaaa\")"); // Test repeat
    pass_test(str_eq(repeat(0, "a"), ""), "str_eq(repeat(0, \"a\"), \"\")");
    pass_test(str_eq(repeat(-10, "a"), NULL), "str_eq(repeat(-10, \"a\"), NULL)");
    pass_test(str_eq(repeat(1, "a"), "a"), "str_eq(repeat(1, \"a\"), \"a\")");
    pass_test(str_eq(repeat(3, ""), ""), "str_eq(repeat(3, \"\"), \"\")");
    pass_test(str_eq(repeat(2, NULL), NULL), "str_eq(repeat(2, NULL), NULL)");


    if (!failed) printf("All tests has passed successfully!\n");
    return 0;
}


