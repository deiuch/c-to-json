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
int main()
{
    yydebug = 1;  // Set 0 for no debug info TODO remove in production
    // TODO set up the input file
//    astnode *astroot = TODO allocate astroot memory
    if (yyparse(/*astroot*/)) return 1;  // TODO param, error
//    char *json = asttojson(astroot);  // TODO
//    astfree(astroot);  // TODO
    // TODO write JSON
    return 0;
}
