@echo off
gcc unit_tests.c alloc_wrap.c ast.c string_tools.c typedef_name.c -o unit_tests.exe
unit_tests.exe
rm unit_tests.exe
pause
