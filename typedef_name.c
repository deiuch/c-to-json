/*
 * Typedef name conflicts resolver for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * Authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdbool.h>
#include "typedef_name.h"

_Bool isallocated = true;

_Bool istypedefname(char *id)
{
    return false;  // TODO Typedef table search
}

void puttypedefname(char *id)
{
    if (!isallocated)
    {
        // TODO allocate typedef-name symbol table
    }
    // TODO add typedef-name, no check
}
