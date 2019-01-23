/**
 * Preprocessing utils for parser
 * for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

#ifndef C_PARSER_PREPROCESSING_H_INCLUDED
#define C_PARSER_PREPROCESSING_H_INCLUDED

#include <stdio.h>

/// Perform phase 1 of the translation on a given input stream.
///
/// ISO/IEC 9899:2017, 5.1.1.2 Translation phases
/// 1. Physical source file multibyte characters are mapped, in an implementation-defined manner, to
///    the source character set (introducing new-line characters for end-of-line indicators) if necessary.
///    Trigraph sequences are replaced by corresponding single-character internal representations.
int translation_phase_1(FILE *stream);

/// Perform phase 2 of the translation on a given input stream.
///
/// ISO/IEC 9899:2017, 5.1.1.2 Translation phases
/// 2. Each instance of a backslash character (\) immediately followed by a new-line character is
///    deleted, splicing physical source lines to form logical source lines. Only the last backslash on
///    any physical source line shall be eligible for being part of such a splice. A source file that is
///    not empty shall end in a new-line character, which shall not be immediately preceded by a
///    backslash character before any such splicing takes place.
int translation_phase_2(FILE *stream);

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
