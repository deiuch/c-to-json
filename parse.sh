#!/bin/bash
cd src
bison -y -d parser.y
flex scanner.l
gcc main.c lex.yy.c y.tab.c alloc_wrap.c ast.c literal_conversion.c preprocessing.c string_tools.c typedef_name.c -o ../c_parser
rm y.tab.c y.tab.h lex.yy.c
cd ..
read -p "Enter input filename (leave empty for 'stdin'): " in
./c_parser $in out.txt
rm c_parser
read -p "Press any key to continue . . ."
