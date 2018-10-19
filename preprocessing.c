/**
 * Preprocessing utils for parser
 * for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

#include <stdio.h>
#include "preprocessing.h"

/// Defined in `flex_tokens.l'.
/// Change source file to read next.
///
/// \param name Name of new source file
extern void change_source(char *name);

int prep_getc(FILE *stream)
{
    return getc(stream);  // TODO
}

size_t prep_fread(void * restrict ptr,
      size_t size, size_t nmemb,
      FILE * restrict stream)
{
    return fread(ptr, size, nmemb, stream);  // TODO
}
