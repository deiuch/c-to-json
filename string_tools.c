/**
 * Tools for string processing.
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "alloc_wrap.h"
#include "string_tools.h"

_Bool str_eq(char *str1, char *str2)
{
    if (str1 == str2) return true;  // Same pointed memory
    if (!str1 || !str2) return false;  // At least one is NULL
    int i;
    for (i = 0; str1[i] != '\0' && str2[i] != '\0'; ++i)
    {
        if (str1[i] != str2[i]) return false;
    }
    return str1[i] == str2[i];  // Both could be '\0'
}

/// Checks if provided character is needed to be escaped.
///
/// \param ch character to check
/// \return `true' - it is to be escaped, `false' - otherwise
_Bool is_to_escape(char ch)
{
    return ch == '"' || ch == '\\' || ch == '\b' || ch == '\f'
        || ch == '\n' || ch == '\r' || ch == '\t';
}

char *wrap_by_quotes(char *str)
{
    if (!str) return NULL;
    int counter = 0;
    for (int i = 0; i < strlen(str); ++i)
    {
        if (is_to_escape(str[i])) ++counter;
    }
    size_t new_size = strlen(str) + counter + 3;
    char *res = (char *) my_malloc(new_size, "quoted string");
    res[0] = '"'; res[new_size-2] = '"'; res[new_size-1] = '\0';
    int j = 1;
    for (int i = 0; i < strlen(str); ++i)
    {
        switch (str[i])
        {
            case '\\' : res[j++] = '\\'; res[j++] = '\\'; break;
            case '\"' : res[j++] = '\\'; res[j++] = '"'; break;
            case '\b' : res[j++] = '\\'; res[j++] = 'b'; break;
            case '\f' : res[j++] = '\\'; res[j++] = 'f'; break;
            case '\n' : res[j++] = '\\'; res[j++] = 'n'; break;
            case '\r' : res[j++] = '\\'; res[j++] = 'r'; break;
            case '\t' : res[j++] = '\\'; res[j++] = 't'; break;
            default: res[j++] = str[i];
        }
    }
    return res;
}

char *alloc_const_str(const char *str)
{
    char *buf = (char *) my_malloc(sizeof(char) * (strlen(str) + 1),
        "constant character allocation buffer");
    strcpy(buf, str);
    return buf;
}

char *concat_array(char **array, int n, char *delimiter)
{
    if (!array || !delimiter || n < 0)
    {
        return NULL;
    }
    if (n == 0)
    {
        return (char *) calloc(1, sizeof(char));
    }
    if (n == 1)
    {
        return alloc_const_str(*array);
    }
    int i, j, k;
    size_t d_len = strlen(delimiter);
    size_t len = d_len * (n - 1);
    for (i = 0; i < n; ++i)
    {
        if (!array[i]) continue;
        len += strlen(array[i]);
    }
    char *res = (char *) my_malloc(sizeof(char) * (len + 1),
        "string concatenation");
    k = 0;
    for (i = 0; i < n; ++i)
    {
        if (!array[i]) goto arr_i_null;
        j = 0;
        while (array[i][j] != '\0')
        {
            res[k++] = array[i][j++];
        }
        arr_i_null:
        if (k == len) break;
        j = 0;
        while (delimiter[j] != '\0')
        {
            res[k++] = delimiter[j++];
        }
    }
    res[k] = '\0';
    return res;
}

char *repeat(int n, char *str)
{
    if (!str || n < 0)
    {
        return NULL;
    }
    if (n == 0)
    {
        return (char *) calloc(1, sizeof(char));
    }
    if (n == 1)
    {
        return str;
    }
    size_t src_len = strlen(str);
    size_t res_len = src_len * n;
    char *res = (char *) my_malloc(sizeof(char) * (res_len + 1),
        "string repetition");
    int i;
    for (i = 0; i < res_len; ++i)
    {
        res[i] = str[i % src_len];
    }
    res[i] = '\0';
    return res;
}
