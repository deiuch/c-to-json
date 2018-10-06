/**
 * Entry point for parer for C Programming Language
 * (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdio.h>
#include "ast.h"
#include "y.tab.h"

extern FILE *yyin, *yyout;  // Flex in/out

/// Program entry point.
int main(int argc, char *argv[])
{
    yydebug = 1;  // Set 0 for no debug info TODO remove in production

    if (argc < 2)
    {
        printf("Usage: %s <out_file> OR %s <in_file> <out_file>", argv[0], argv[0]);
        return 1;
    }

    yyin = argc > 2 ? fopen(argv[1], "r") : stdin;
    if (!yyin)  /* TODO error */;
    FILE *out = argc > 2 ? fopen(argv[2], "w+") : fopen(argv[1], "w+");
    if (!out) /* TODO error */;

//    astnode *astroot = TODO allocate astroot memory
    if (yyparse(/*astroot*/)) return 1;  // TODO param, error
    char *json = NULL;
//    if (json = ast_to_json(astroot)) return 1;  // TODO error
//    ast_free(astroot);  // TODO

    fputs(json, out);
    if (argc > 2) fclose(yyin);
    return 0;
}
