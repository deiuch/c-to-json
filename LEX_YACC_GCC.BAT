@echo off
Bison\bin\yacc.exe -y -d -v -t yacc_syntax.y
Flex\bin\lex.exe -d flex_tokens.l
gcc main.c lex.yy.c y.tab.c ast.c typedef_name.c string_tools.c alloc_wrap.c -o c_parser.exe
c_parser.exe out.txt
rm c_parser.exe
pause
