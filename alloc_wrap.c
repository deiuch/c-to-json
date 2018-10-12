/**
 * Wrapping for memory allocation functions
 * to exit on a failure with corresponding message.
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include "alloc_wrap.h"

void *my_malloc(size_t size, char *description)
{
    void *res = malloc(size);
    if (!res)
    {
        fprintf(stderr, "FATAL ERROR!\n"
                        "Memory for %s cannot be allocated!\n", description);
        exit(-1);
    }
    return res;
}

void *my_realloc(void *memory, size_t size, char *description)
{
    void *res = realloc(memory, size);
    if (!res)
    {
        fprintf(stderr, "FATAL ERROR!\n"
                        "Memory for %s cannot be reallocated!\n", description);
        exit(-1);
    }
    return res;
}
