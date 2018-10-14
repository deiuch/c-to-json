#!/bin/bash
command -v bison -y -d -v yacc_syntax.y >/dev/null 2>&1 || { echo >&2 "`bison' required but not installed. Aborting."; exit 1; }
command -v flex flex_tokens.l >/dev/null 2>&1 || { echo >&2 "`flex' required but not installed. Aborting."; rm y.tab.c y.tab.h; exit 1; }
gcc main.c lex.yy.c y.tab.c alloc_wrap.c ast.c string_tools.c typedef_name.c -o c_parser
rm y.tab.c y.tab.h lex.yy.c
set /p in="Enter input filename (leave empty for `stdin'): "
c_parser $in out.txt
rm c_parser.exe
pause
