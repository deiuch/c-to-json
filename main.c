/**
 * Entry point for parer for C Programming Language
 * (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdio.h>
#include <stdlib.h>
#include "ast.h"
#include "typedef_name.h"
#include "y.tab.h"

/// Input file for Flex.
extern FILE *yyin;

/// Program entry point.
///
/// \param argc Size of `argv'
/// \param argv Arguments passed to the program
/// \return 0 - OK, 1 - logic error, 2 - args error, 3 - I/O error
int main(int argc, char *argv[])
{
    yydebug = 1;  // Set 0 for no debug info. TODO remove in production

    if (argc < 2)
    {
        printf("Usage: %s <out_file> OR %s <in_file> <out_file>\n",
                argv[0], argv[0]);
        return 2;
    }

    int res;  // For results of I/O functions

    char *in_name = argc > 2 ? argv[1] : NULL;
    char *out_name = argc > 2 ? argv[2] : argv[1];

    yyin = in_name != NULL ? fopen(in_name, "r") : stdin;
    if (!yyin)
    {
        fprintf(stderr, "Cannot open for reading: %s\n", in_name);
        return 3;
    }

    int yyres = yyparse();
    free_typedef_name();

    res = argc > 2 ? fclose(yyin) : 0;
    if (res == EOF)
    {
        fprintf(stderr, "Cannot close opened source file: %s\n", in_name);
        return 3;
    }

    if (yyres || !ast_root)
    {
        fprintf(stderr, "Parsing failed! No output will be provided.\n");
        return 1;
    }

    char *json = ast_to_json(ast_root);
    ast_free(ast_root);
    if (!json)
    {
        fprintf(stderr, "JSON generation failure!\n");
        return 1;
    }

    FILE *out = fopen(argv[2], "w");
    if (!out)
    {
        fprintf(stderr, "Cannot open for writing: %s\n", out_name);
        free(json);
        return 3;
    }

    res = fputs(json, out);
    free(json);
    if (res == EOF)
    {
        fprintf(stderr, "Cannot write into opened target file: %s\n", out_name);
        return 3;
    }

    res = fclose(out);
    if (res == EOF)
    {
        fprintf(stderr, "Cannot close opened target file: %s\n", out_name);
        return 3;
    }

    return 0;
}
