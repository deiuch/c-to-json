/**
 * Preprocessing utils for parser
 * for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

#ifndef C_PARSER_PREPROCESSING_H_INCLUDED
#define C_PARSER_PREPROCESSING_H_INCLUDED

#include <stdio.h>

/// Get next character after preprocessing analysis.
///
/// \param stream Input stream to read from
/// \return Next character from the given stream
int prep_getc(FILE *stream);

/// Read pointed number of characters from
/// the specified input after preprocessing.
///
/// \param ptr Destination array
/// \param size Size of reading members
/// \param nmemb Maximum number of elements to read
/// \param stream Stream to read from
/// \return
size_t prep_fread(void * restrict ptr,
      size_t size, size_t nmemb,
      FILE * restrict stream);

#endif //C_PARSER_PREPROCESSING_H_INCLUDED
