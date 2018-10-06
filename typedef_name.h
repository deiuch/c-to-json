/*
 * Typedef name conflicts resolver for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * Authors: Denis Chernikov, Vladislav Kuleykin
 */

#ifndef C_PARSER_TYPEDEF_NAME_H_H_INCLUDED
#define C_PARSER_TYPEDEF_NAME_H_H_INCLUDED

// TODO typedef-name symbol table struct

// TODO table global variable

/// Is given identifier - Typedef name?
_Bool istypedefname(char *);

/// Put this string into typedef-name symbol table. Repetitions allowed.
void puttypedefname(char *);

#endif //C_PARSER_TYPEDEF_NAME_H_H_INCLUDED
