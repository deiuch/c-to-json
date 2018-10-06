/**
 * Typedef name conflicts resolver for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdbool.h>
#include "typedef_name.h"

_Bool is_allocated = true;

_Bool is_typedef_name(char *id)
{
    return false;  // TODO Typedef table search
}

void put_typedef_name(char *id)
{
    if (!is_allocated)
    {
        // TODO allocate typedef-name symbol table
    }
    // TODO add typedef-name, no check
}
