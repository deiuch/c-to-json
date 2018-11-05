/**
 * Tools for literal values conversion for parser
 * for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

#ifndef C_PARSER_LITERAL_CONVERSION_H_INCLUDED
#define C_PARSER_LITERAL_CONVERSION_H_INCLUDED

#include <stddef.h>

/// Integer-constant internal representation type.
typedef char *INT_CONST;  // FIXME type

/// Floating-constant internal representation type.
typedef char *FLT_CONST;  // FIXME type

/// Character-constant internal representation type.
typedef char CHR_CONST;

/// String-literal internal representation type.
typedef char *STR_LITERAL;

/// Check if Universal Character Names at `len' first symbols are correct.
///
/// \param source Source to check the validity of
/// \param len Maximum number of characters to check
/// \return `true' - all UCNs are correct, `false' - otherwise
_Bool are_ucns_correct(char *source, size_t len);

/// Get integer-constant's internal representation.
///
/// \param source Source string for conversion
/// \param len Size of the `source'
/// \return Internal representation of integer-constant
INT_CONST *translate_integer_constant(char *source, size_t len);

/// Get floating-constant's internal representation.
///
/// \param source Source string for conversion
/// \param len Size of the `source'
/// \return Internal representation of floating-constant
FLT_CONST *translate_floating_constant(char *source, size_t len);

/// Get character-constant's internal representation.
///
/// \param source Source string for conversion
/// \param len Size of the `source'
/// \return Internal representation of character-constant
CHR_CONST *translate_character_constant(char *source, size_t len);

/// Get string-literal's internal representation.
///
/// \param source Source string for conversion
/// \param len Size of the `source'
/// \return Internal representation of string-literal
STR_LITERAL *translate_string_literal(char *source, size_t len);

#endif //C_PARSER_LITERAL_CONVERSION_H_INCLUDED
