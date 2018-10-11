cmake_minimum_required(VERSION 3.9)
project(c_parser C)

set(CMAKE_C_STANDARD 11)

add_executable(c_parser main.c lex.yy.c y.tab.c ast.c typedef_name.c string_tools.c)