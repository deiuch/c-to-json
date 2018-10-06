/*
 * Entry point for parer for C Programming Language
 * (ISO/IEC 9899:2018).
 *
 * Authors: Denis Chernikov, Vladislav Kuleykin
 */

#include "y.tab.h"

/// Program entry point.
int main()
{
    yydebug = 1;  // TODO remove in prod, set 0 for no debug info
    if (yyparse()) return 1;  // TODO error
    // TODO operate on AST
    return 0;
}
