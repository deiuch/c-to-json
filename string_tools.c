/**
 * Tools for string processing.
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include "stdio.h"
#include <stdlib.h>
#include <string.h>
#include "string_tools.h"

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
    int i, j;
    size_t d_len = strlen(delimiter);
    size_t len = d_len * (n - 1);
    for (i = 0; i < n; ++i)
    {
        len += strlen(array[i]);
    }
    char *res = (char *) malloc(len);
    if (!res)
    {
        fprintf(stderr,
            "FATAL ERROR! Memory for string concatenation cannot be allocated!\n");
        exit(-1);
    }
    size_t cur_len;
    for (i = 0; i < n;)
    {
        cur_len = strlen(array[i]);
        for (j = 0; j < cur_len; ++j)
        {
            res[i + j] = array[i][j];
        }
        i += j;
        if (i == len - 1) break;
        for (j = 0; j < d_len; ++j)
        {
            res[i + j] = delimiter[j];
        }
        i += j;
    }
    res[i] = '\0';
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
    char *res = (char *) malloc(sizeof(char) * res_len + 1);
    if (!res)
    {
        fprintf(stderr,
                "FATAL ERROR! Memory for string repetition cannot be allocated!\n");
        exit(-1);
    }
    int i;
    for (i = 0; i < res_len; ++i)
    {
        res[i] = str[i % src_len];
    }
    res[i] = '\0';
    return res;
}
