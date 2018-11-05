/**
 * Preprocessing utils for parser
 * for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

#include <stdio.h>
#include "preprocessing.h"
#include "typedef_name.h"

/// Defined in `flex_tokens.l'.
/// Change source file to read next.
///
/// \param name Name of new source file
extern void change_source(char *name);

/* TODO ISO/IEC 9899:2017:
 * 5.2.1.1 Trigraph sequences, page 18 (PDF: 37);
 * 6.4 Lexical elements, page 41 (PDF: 60);
 * 6.4.5 String literals, pages 50-51 (PDF: 69-70);
 * 6.4.6 Punctuators, page 52 (PDF: 71) (digraphs `%:' and `%:%:');
 * 6.4.7 Header names, page 53 (PDF: 72);
 * 6.4.8 Preprocessing numbers, pages 53-54 (PDF: 72-73);
 * 6.10 Preprocessing directives, pages 117-129 (PDF: 136-148);
 * A.3 Preprocessing directives, pages 344-345 (PDF: 363-364).
 *
 * Also use `add_std_typedef' and `change_source' procedures.
 */

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
