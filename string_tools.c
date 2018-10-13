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
    if (!str1 && !str2) return true;
    if (!str1 || !str2) return false;
    int i;
    for (i = 0; str1[i] != '\0' && str2[i] != '\0'; ++i)
    {
        if (str1[i] != str2[i]) return false;
    }
    return str1[i] == str2[i];  // Both could be '\0'
}

char *wrap_by_quotes(char *str)
{
    if (!str) return NULL;
    char *res = (char *) my_malloc(strlen(str) + 3, "quoted string");
    int r = sprintf(res, "\"%s\"", str);
    if (r < 0)
    {
        fprintf(stderr,
                "FATAL ERROR! String formatting cannot be applied!\n");
        free(res);
        exit(-1);
    }
    return res;
}

char *concat_array(char **array, int n, char *delimiter)
{
    if (n < 0)
    {
        return NULL;
    }
    if (n == 0)
    {
        return (char *) calloc(1, sizeof(char));
    }
    if (n == 1)
    {
        return *array;
    }
    int i, j, k;
    size_t d_len = strlen(delimiter);
    size_t len = d_len * (n - 1);
    for (i = 0; i < n; ++i)
    {
        len += strlen(array[i]);
    }
    char *res = (char *) my_malloc(sizeof(char) * (len + 1),
            "string concatenation");
    size_t cur_len;
    k = 0;
    for (i = 0; i < n; ++i)
    {
        j = 0;
        while (array[i][j] != '\0')
        {
            res[k++] = array[i][j++];
        }
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
    if (n < 0)
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
