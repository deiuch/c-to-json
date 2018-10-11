/**
 * Typedef name conflicts resolver for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#ifndef C_PARSER_TYPEDEF_NAME_H_H_INCLUDED
#define C_PARSER_TYPEDEF_NAME_H_H_INCLUDED

/// Is given identifier - typedef-name?
///
/// \param id Identifier to check
/// \return `true' - there is such typedef-name table entry, `false' - otherwise
_Bool is_typedef_name(char *id);

/// Put this string into typedef-name symbol table. Repetitions allowed.
///
/// \param id Identifier to put to the typedef-name table
void put_typedef_name(char *id);

/// Free memory allocated by typedef-name symbol table.
void free_typedef_name();

#endif //C_PARSER_TYPEDEF_NAME_H_H_INCLUDED
