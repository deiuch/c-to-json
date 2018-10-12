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

/// typedef-name table.
char **typedef_table;

/// Size of typedef-name table.
int typedef_table_size = 0;

_Bool is_typedef_name(char *id)
{
    if (!typedef_table_size) return false;
    int i, j;
    char *cur;
    for (i = 0; i < typedef_table_size; ++i)
    {
        cur = typedef_table[i];
        for (j = 0; cur[j] != '\0' && id[j] != '\0'; ++j)
        {
            if (cur[j] != id[j]) break;
        }
        if (cur[j] != id[j]) continue;  // Both could be '\0'
        return true;
    }
    return false;
}

void put_typedef_name(char *id)
{
    typedef_table = my_realloc(typedef_table,
            (typedef_table_size + 1) * sizeof(char *),
            "typedef-name symbol table");
    typedef_table[typedef_table_size] = (char *) my_malloc(
            sizeof(char) * (strlen(id) + 1),
            "new typedef-name");
    strcpy(typedef_table[typedef_table_size - 1], id);
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
