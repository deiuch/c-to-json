CC = gcc

all: execute clean_sources

make_yacc: yacc_syntax.y
	bison -y -d yacc_syntax.y

make_flex: flex_tokens.l
	flex flex_tokens.l

compile: make_yacc make_flex
	$(CC) main.c lex.yy.c y.tab.c alloc_wrap.c ast.c string_tools.c typedef_name.c -o c_parser

clean_sources:
	-rm y.tab.c y.tab.h lex.yy.c

execute: compile
	./c_parser in.txt out.txt