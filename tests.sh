#!/bin/bash
gcc unit_tests.c alloc_wrap.c ast.c string_tools.c typedef_name.c -o unit_tests
./unit_tests
rm unit_tests
read -p "Press any key to continue . . ."
