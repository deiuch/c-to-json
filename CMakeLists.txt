cmake_minimum_required(VERSION 3.9)
project(c_parser C)

set(CMAKE_C_STANDARD 99)

add_executable(yacc lex.yy.c y.tab.c)