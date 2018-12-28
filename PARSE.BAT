@echo off
cd src
..\Bison\bin\yacc.exe -y -d parser.y
..\Flex\bin\lex.exe scanner.l
gcc main.c lex.yy.c y.tab.c alloc_wrap.c ast.c literal_conversion.c preprocessing.c string_tools.c typedef_name.c -o ..\c_parser.exe
del y.tab.c y.tab.h lex.yy.c
cd ..
set /p in="Enter input filename (leave empty for 'stdin'): "
c_parser.exe %in% out.txt
del c_parser.exe
pause
