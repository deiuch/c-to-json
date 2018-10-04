Bison\bin\yacc.exe -y -dy -v -t yacc_syntax.y
Lex\bin\lex.exe -d lex_tokens.l
gcc lex.yy.c y.tab.c -o lex_yacc.exe
lex_yacc.exe
pause