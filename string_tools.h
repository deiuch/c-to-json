/**
 * Tools for string processing.
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#ifndef C_PARSER_STRING_TOOLS_H
#define C_PARSER_STRING_TOOLS_H

/// Concatenate an array of strings into one string.
/// Needs to be freed.
///
/// \param array Array of strings
/// \param n Number of strings in array
/// \param delimiter Delimiter to be placed between strings
/// \return String of concatenated strings
char *concat_array(char **array, int n, char *delimiter);

/// Repeat given source `n' times.
/// Needs to be freed.
///
/// \param n Number of repetitions
/// \param str String pattern to repeat
/// \return `str' repeated `n' times
char *repeat(int n, char *str);

#endif //C_PARSER_STRING_TOOLS_H
