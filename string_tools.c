/**
 * Tools for string processing.
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdlib.h>
#include <string.h>
#include "string_tools.h"

char *concat_array(char **array, char *delimiter)
{
    return *array;  // TODO
}

char *repeat(int n, char *str)
{
    if (n < 0)
    {
        return NULL;
    }
    if (n == 0)
    {
        return "";
    }
    if (n == 1)
    {
        return str;
    }
    size_t src_len = strlen(str);
    size_t res_len = src_len * n;
    char *res = (char *) malloc(sizeof(char) * res_len);
    int i;
    for (i = 0; i < res_len; ++i)
    {
        res[i] = str[i % src_len];
    }
    return res;
}
