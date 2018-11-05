/**
 * Wrapping for memory allocation functions
 * to exit on a failure with corresponding message.
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#ifndef C_PARSER_MALLOC_WRAP_H_INCLUDED
#define C_PARSER_MALLOC_WRAP_H_INCLUDED

#include <stddef.h>

/// Wrapping for `malloc' function. Exits application if `NULL'.
///
/// \param size Size to allocate
/// \param description String to output inside warning, type of content
/// \return New allocated memory
void *my_malloc(size_t size, char *description);

/// Wrapping for `realloc' function. Exits application if `NULL'.
///
/// \param memory Pointer to a memory to reallocate
/// \param size Size to reallocate
/// \param description String to output inside warning, type of content
/// \return New allocated memory
void *my_realloc(void *memory, size_t size, char *description);

#endif //C_PARSER_MALLOC_WRAP_H_INCLUDED
