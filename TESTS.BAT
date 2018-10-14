@echo off
gcc unit_tests.c string_tools.c alloc_wrap.c -o unit_tests.exe
unit_tests.exe
rm unit_tests.exe
pause
