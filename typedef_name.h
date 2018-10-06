/**
 * Typedef name conflicts resolver for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#ifndef C_PARSER_TYPEDEF_NAME_H_H_INCLUDED
#define C_PARSER_TYPEDEF_NAME_H_H_INCLUDED

// TODO typedef-name symbol table struct

// TODO table global variable

/// Is given identifier - Typedef name?
_Bool is_typedef_name(char *);

/// Put this string into typedef-name symbol table. Repetitions allowed.
void put_typedef_name(char *);

#endif //C_PARSER_TYPEDEF_NAME_H_H_INCLUDED
