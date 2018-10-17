# C Programming Language parser (ISO/IEC 9899:2018)
Basic C parser (ISO/IEC 9899:2018 standard review) on Flex/Yacc converting programs to JSON.\
**Authors:** Denis Chernikov, Vladislav Kuleykin
## Purposes
This project was done during the Compiler Construction course (primary instructor: *Eugene Zouev*) at *Fall 2018* semester at *Innopolis University* (Innopolis, Russia).\
This one does very basic things:
* Parsing some basic programs on C Programming Language;
* Telling if a given program is syntactically correct or not;
* If the program is correct, printing generated AST to the specified file in JSON format.
## How to run the parser
Download and unzip the content of a repository.\
**On Windows:** start `PARSE.BAT` file.\
**On Unix (not tested):** start `parse.sh` file.

***Note:*** On **Windows**, we assume that you have a `gcc` compiler accessible via command `gcc source.c -o source.exe`, also all the required tools can be downloaded by [this link](https://yadi.sk/d/aVlUjb13y2HDhA) (put `flex` and `bison` folders near the batch file). On **Unix**, we assume that you have `gcc` compiler, and also that you have already installed tools `flex` and `bison`. If you don't, you can install them simply using commands:
```shell
sudo apt install flex
sudo apt install bison
```
## How to run tests
Download and unzip the content of a repository.\
**On Windows:** start `TESTS.BAT` file.\
**On Unix (not tested):** start `tests.sh` file.
## Project assumptions
* Our lexical analyzer is done using Flex tool (not just Lex because of using start conditions `%x`). But we do not have a corresponding preprocessor. That's why lexical analyzer is a bit complicated (digraphs, trigraphs and newline escapes are considered and `#include` directives are handeled, but `#define`, `#undef`, `#if`, `#else` and other conditional directives are just ommited).
* Lexical analyzer is required to convert all literals to the correct internal representation (like correct sequence of bits). In our case, only string literals and character constants are converted (de-escaped).
* Error recovery in syntax is not complete (more detailed analyzis is required to put nonterminal `error` without conflicts). Parsing stops at the first found syntax error.
* If syntax (or lexical) error occured - nothing will be printed to the specified output file. Actually, this file will not be opened for writing at all.
* In case of error, no concrete description is printed yet. Easier to see errors in "debug mode" (add flag `-t` to `bison` command, `-d` to `flex` command, and in `main` function set `yydebug = 1;`).
* Syntax analyzis is done for the whole set of possible programs that are written according to the *ISO/IEC 9899:2018*. As a reference, [2017's draft](http://www.open-std.org/jtc1/sc22/wg14/www/abq/c17_updated_proposed_fdis.pdf) was used, but since that version no critical changes were applied. Just some obvious mistakes in standard were fixed (like `-` used as decrement).
* Complete memory management has failed (not all the memory may be freed for unknown reasons).
* There is no official code style convention for the C Programming Language. We wanted to follow a convention about maximum 80 characters per line and code style from the examples from the standard. Actually, some cases required to use much more than 80 characters in a single line (separation looked worse sometimes), that's why our code style convention is about 130 characters per line.
## Additional notes
* Despite the fact that we use `bison` tool (which is for C++), actually the project is implemented in terms of classical Yacc (flag `-y`). Therefore our project is written fully on C Programming Language (note some bootstrapping possibilities). Actually, do NOT try to bootstrap the project on this stage (regards to weak preprocessing).
* Actual executable's usage is with one or two arguments to it's call:
`c_parser.exe %input_file_name% %output_file_name%`
OR with just one argument, assuming the input from the command line:
`c_parser.exe %output_file_name%`
* To see a PDA description of Yacc's automata add `-v` flag to the `bison` call. See generated file `y.output`.
* In ISO/IEC 9899:2018 there is no preprocessing directive called `#warning`, but a lot of resources do note it, that's why we enabled this small feature in our lexical analyzer.
## BNF description
Actually, the whole syntax description without code is placed in `pure_c_grammar.y`. It is too huge to convert it into the original BNF notation. Lexical units are explained good enough almost... everywhere! We will ommit it...
