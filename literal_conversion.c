/**
 * Tools for literal values conversion for parser
 * for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

#include <stdbool.h>
#include <stdlib.h>
#include <string.h>
#include "alloc_wrap.h"
#include "literal_conversion.h"
#include "string_tools.h"

_Bool are_ucns_correct(char *source, size_t len)
{
    return true;  // TODO ISO/IEC 9899:2017, page 44
}

INT_CONST *translate_integer_constant(char *source, size_t len)
{
    return (INT_CONST *) alloc_const_str(source);  // TODO value conversion, ISO/IEC 9899:2017, page 45-46
}

FLT_CONST *translate_floating_constant(char *source, size_t len)
{
    return (FLT_CONST *) alloc_const_str(source);  // TODO value conversion, ISO/IEC 9899:2017, page 47-48
}

CHR_CONST *translate_character_constant(char *source, size_t len)
{
    // TODO prefix considering, ISO/IEC 9899:2017, page 48-50
    // TODO own algorithm
    STR_LITERAL *str = translate_string_literal(source, len);
    if (!str || strlen(*str) != 1)  // FIXME length of... what?
    {
        free(*str);
        return NULL;
    }
    return (CHR_CONST *) *str;
}

STR_LITERAL *translate_string_literal(char *source, size_t len)
{
    size_t i = 0, j = 0;
    if (source[0] == 'L' || source[0] == 'U' || source[0] == 'u')
    {
        // TODO prefix considering, ISO/IEC 9899:2017, page 50-52
        if (source[0] == 'u' && source[1] == '8')
        {
            i = 2;
        }
        else
        {
            i = 1;
        }
    }
    if (source[i] != '"' && source[i] != '\'') return NULL;
    ++i;
    char *res = (char *) my_malloc(sizeof(char) * (len + 1),
        "string-literal content");
    char to_put;
    while (source[i] != '"')
    {
        if (source[i] == '\\')
        {
            ++i;
            if (i == len - 1)
            {
                free(res);
                return NULL;
            }
            switch (source[i])
            {
                case '?':  to_put = '?'; break;
                case '\'': to_put = '\''; break;
                case '\"': to_put = '\"'; break;
                case '\\': to_put = '\\'; break;
                case 'a':  to_put = '\a'; break;
                case 'b':  to_put = '\b'; break;
                case 'f':  to_put = '\f'; break;
                case 'n':  to_put = '\n'; break;
                case 'r':  to_put = '\r'; break;
                case 't':  to_put = '\t'; break;
                case 'v':  to_put = '\v'; break;
                case '0':
                case '1':
                case '2':
                case '3':
                case '4':
                case '5':
                case '6':
                case '7':
                    to_put = '\x1A'; // TODO: up to 3 octal
                    break;
                case 'x':
                    ++i;
                    to_put = '\x1A'; // TODO: closest hexes
                    break;
                case 'u':
                    ++i;
                    to_put = '\x1A'; // TODO: 4 hexes
                    i += 3;
                    break;
                case 'U':
                    ++i;
                    to_put = '\x1A'; // TODO: 8 hexes
                    i += 7;
                    break;
                default:
                    free(res);
                    return NULL;
            }
        }
        else
        {
            to_put = source[i];
        }
        res[j] = to_put;
        ++i;
        ++j;
    }
    res[j] = '\0';
    my_realloc(res, j + 1, "cut memory for string-literal");
    return (STR_LITERAL *) res;
}
