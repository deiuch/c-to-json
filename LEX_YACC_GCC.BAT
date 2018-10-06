Bison\bin\yacc.exe -y -d -v -t yacc_syntax.y
Lex\bin\lex.exe -d lex_tokens.l
gcc main.c lex.yy.c y.tab.c ast.c typedef_name.c -o c_parser.exe
c_parser.exe
pause
