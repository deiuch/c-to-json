@echo off
Bison\bin\yacc.exe -y -d yacc_syntax.y
Flex\bin\lex.exe flex_tokens.l
gcc main.c lex.yy.c y.tab.c alloc_wrap.c ast.c string_tools.c typedef_name.c -o c_parser.exe
del y.tab.c y.tab.h lex.yy.c
set /p in="Enter input filename (leave empty for `stdin'): "
c_parser.exe %in% out.txt
del c_parser.exe
pause
