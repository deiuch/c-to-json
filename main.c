/**
 * Entry point for parer for C Programming Language
 * (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include "ast.h"
#include "y.tab.h"

/// Program entry point.
int main()
{
    yydebug = 1;  // TODO remove in production, set 0 for no debug info
//  astnode *astroot = TODO allocate astroot memory
    if (yyparse(/*astroot*/)) return 1;  // TODO param, error
    // TODO operate on AST
    return 0;
}
