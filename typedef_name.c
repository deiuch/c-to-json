/**
 * Typedef name conflicts resolver for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "typedef_name.h"
#include "alloc_wrap.h"
#include "string_tools.h"

/// typedef-name table.
char **typedef_table;

/// Size of typedef-name table.
int typedef_table_size = 0;

_Bool is_typedef_name(char *id)
{
    if (!typedef_table_size) return false;
    for (int i = 0; i < typedef_table_size; ++i)
    {
        if (str_eq(id, typedef_table[i])) return true;
    }
    return false;
}

void put_typedef_name(char *id)
{
    typedef_table = (char **) my_realloc(typedef_table,
            sizeof(char *) * (typedef_table_size + 1),
            "typedef-name symbol table");
    typedef_table[typedef_table_size] = (char *) my_malloc(
            sizeof(char) * (strlen(id) + 1),
            "new typedef-name");
    strcpy(typedef_table[typedef_table_size], id);
    ++typedef_table_size;
}

void free_typedef_name()
{
    for (int i = 0; i < typedef_table_size; ++i)
    {
        free(typedef_table[i]);
    }
    free(typedef_table);
    typedef_table_size = 0;
}
