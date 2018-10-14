#!/bin/bash
bison -y -d -v yacc_syntax.y
flex flex_tokens.l
gcc main.c lex.yy.c y.tab.c alloc_wrap.c ast.c string_tools.c typedef_name.c -o c_parser
rm y.tab.c y.tab.h lex.yy.c
read -p "Enter input filename (leave empty for `stdin'): " in
c_parser $in out.txt
rm c_parser.exe
pause
