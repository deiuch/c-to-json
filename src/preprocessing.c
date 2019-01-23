/**
 * Preprocessing utils for parser
 * for C Programming Language (ISO/IEC 9899:2018).
 *
 * @author: Denis Chernikov
 */

#include <stdio.h>
#include "preprocessing.h"
#include "typedef_name.h"

#define UNDEF_CHAR -2

/// Defined in `flex_tokens.l'.
/// Change source file to read next.
///
/// \param name Name of new source file
extern void change_source(char *name);

/* TODO ISO/IEC 9899:2017:
 * 5.2.1.1 Trigraph sequences, page 18 (PDF: 37);
 * 6.4 Lexical elements, page 41 (PDF: 60);
 * 6.4.5 String literals, pages 50-51 (PDF: 69-70);
 * 6.4.6 Punctuators, page 52 (PDF: 71) (digraphs `%:' and `%:%:');
 * 6.4.7 Header names, page 53 (PDF: 72);
 * 6.4.8 Preprocessing numbers, pages 53-54 (PDF: 72-73);
 * 6.10 Preprocessing directives, pages 117-129 (PDF: 136-148);
 * A.3 Preprocessing directives, pages 344-345 (PDF: 363-364).
 *
 * Also use `add_std_typedef' and `change_source' procedures.
 */

int translation_phase_1(FILE *stream)
{  // TODO: map physical source file multibyte characters to the source character set.
    static int buffer[3] = {UNDEF_CHAR, UNDEF_CHAR, UNDEF_CHAR};

    if (buffer[0] == UNDEF_CHAR)
    {
        buffer[0] = getc(stream);
        buffer[1] = getc(stream);
    }
    else
    {
        buffer[0] = buffer[1];
        buffer[1] = buffer[2];
    }
    buffer[2] = getc(stream);

    if (buffer[0] == '?' && buffer[1] == '?')
    {
        switch (buffer[2])
        {
            case '=': buffer[0] = '#'; break;
            case '(': buffer[0] = '['; break;
            case '/': buffer[0] = '\\'; break;
            case ')': buffer[0] = ']'; break;
            case '\'': buffer[0] = '^'; break;
            case '<': buffer[0] = '{'; break;
            case '!': buffer[0] = '|'; break;
            case '>': buffer[0] = '}'; break;
            case '-': buffer[0] = '~'; break;
            default: goto end;
        }
        buffer[1] = getc(stream);
        buffer[2] = getc(stream);
    }
    end:
    return buffer[0];
}

int translation_phase_2(FILE *stream)
{
    static int buffer = UNDEF_CHAR;
    int cur;

    if (buffer == EOF)
    {
        return EOF;
    }

    if (buffer != UNDEF_CHAR)
    {
        cur = buffer;
        buffer = UNDEF_CHAR;
    }
    else
    {
        cur = translation_phase_1(stream);
    }

    check:
    if (cur == '\\')
    {
        if ((cur = translation_phase_1(stream)) == '\n')
        {
            cur = translation_phase_1(stream);
            goto check;
        }
        buffer = cur;
        return '\\';
    }

    if (cur == EOF)  // Add new-line at the end of the file; TODO: check
    {
        buffer = EOF;
        cur = '\n';
    }
    return cur;
}

int prep_getc(FILE *stream)
{
    return getc(stream);  // TODO
}

size_t prep_fread(void * restrict ptr,
                  size_t size, size_t nmemb,
                  FILE * restrict stream)
{
    return fread(ptr, size, nmemb, stream);  // TODO
}
