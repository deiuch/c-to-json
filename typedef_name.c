/**
 * Typedef name conflicts resolver for parser
 * of the C Programming Language (ISO/IEC 9899:2018).
 *
 * @authors: Denis Chernikov, Vladislav Kuleykin
 */

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "typedef_name.h"
#include "alloc_wrap.h"
#include "string_tools.h"

/// typedef-name table.
char **typedef_table;

/// Size of typedef-name table.
int typedef_table_size = 0;

_Bool is_typedef_name(char *id)
{
    if (!typedef_table_size) return false;
    for (int i = 0; i < typedef_table_size; ++i)
    {
        if (str_eq(id, typedef_table[i])) return true;
    }
    return false;
}

void put_typedef_name(char *id)
{
    typedef_table = (char **) my_realloc(typedef_table,
            sizeof(char *) * (typedef_table_size + 1),
            "typedef-name symbol table");
    typedef_table[typedef_table_size] = (char *) my_malloc(
            sizeof(char) * (strlen(id) + 1),
            "new typedef-name");
    strcpy(typedef_table[typedef_table_size], id);
    ++typedef_table_size;
}

void free_typedef_name()
{
    for (int i = 0; i < typedef_table_size; ++i)
    {
        free(typedef_table[i]);
    }
    free(typedef_table);
    typedef_table_size = 0;
}

void add_std_typedef(char *header_name)
{
    if (str_eq(header_name, "assert.h"))
    {
        // Nothing
    }
    else if (str_eq(header_name, "complex.h"))
    {
        put_typedef_name(alloc_const_str("complex"));
        put_typedef_name(alloc_const_str("_Complex_I"));
        put_typedef_name(alloc_const_str("imaginary"));
        put_typedef_name(alloc_const_str("_Imaginary_I"));
        put_typedef_name(alloc_const_str("I"));
    }
    else if (str_eq(header_name, "ctype.h"))
    {
        // Nothing
    }
    else if (str_eq(header_name, "errno.h"))
    {
        put_typedef_name(alloc_const_str("errno_t"));
    }
    else if (str_eq(header_name, "fenv.h"))
    {
        put_typedef_name(alloc_const_str("fenv_t"));
        put_typedef_name(alloc_const_str("fexcept_t"));
    }
    else if (str_eq(header_name, "float.h"))
    {
        // Nothing
    }
    else if (str_eq(header_name, "inttypes.h"))
    {
        if (!is_typedef_name("wchar_t")) add_str_typedef("stddef.h");
        if (!is_typedef_name("intmax_t")) add_str_typedef("stdint.h");
        put_typedef_name(alloc_const_str("imaxdiv_t"));
    }
    else if (str_eq(header_name, "iso646.h"))
    {
        // Nothing
    }
    else if (str_eq(header_name, "limits.h"))
    {
        // Nothing
    }
    else if (str_eq(header_name, "locale.h"))
    {
        // Nothing
    }
    else if (str_eq(header_name, "math.h"))
    {
        put_typedef_name(alloc_const_str("float_t"));
        put_typedef_name(alloc_const_str("double_t"));
    }
    else if (str_eq(header_name, "setjmp.h"))
    {
        put_typedef_name(alloc_const_str("jmp_buf"));
    }
    else if (str_eq(header_name, "signal.h"))
    {
        put_typedef_name(alloc_const_str("sig_atomic_t"));
    }
    else if (str_eq(header_name, "stdalign.h"))
    {
        put_typedef_name(alloc_const_str("alignas"));
        put_typedef_name(alloc_const_str("alignof"));
    }
    else if (str_eq(header_name, "stdarg.h"))
    {
        put_typedef_name(alloc_const_str("va_list"));
    }
    else if (str_eq(header_name, "stdatomic.h"))
    {
        put_typedef_name(alloc_const_str("memory_order"));
        put_typedef_name(alloc_const_str("atomic_flag"));
        put_typedef_name(alloc_const_str("atomic_bool"));
        put_typedef_name(alloc_const_str("atomic_char"));
        put_typedef_name(alloc_const_str("atomic_schar"));
        put_typedef_name(alloc_const_str("atomic_uchar"));
        put_typedef_name(alloc_const_str("atomic_short"));
        put_typedef_name(alloc_const_str("atomic_ushort"));
        put_typedef_name(alloc_const_str("atomic_int"));
        put_typedef_name(alloc_const_str("atomic_uint"));
        put_typedef_name(alloc_const_str("atomic_long"));
        put_typedef_name(alloc_const_str("atomic_ulong"));
        put_typedef_name(alloc_const_str("atomic_llong"));
        put_typedef_name(alloc_const_str("atomic_ullong"));
        put_typedef_name(alloc_const_str("atomic_char16_t"));
        put_typedef_name(alloc_const_str("atomic_char32_t"));
        put_typedef_name(alloc_const_str("atomic_wchar_t"));
        put_typedef_name(alloc_const_str("atomic_int_least8_t"));
        put_typedef_name(alloc_const_str("atomic_uint_least8_t"));
        put_typedef_name(alloc_const_str("atomic_int_least16_t"));
        put_typedef_name(alloc_const_str("atomic_uint_least16_t"));
        put_typedef_name(alloc_const_str("atomic_int_least32_t"));
        put_typedef_name(alloc_const_str("atomic_uint_least32_t"));
        put_typedef_name(alloc_const_str("atomic_int_least64_t"));
        put_typedef_name(alloc_const_str("atomic_uint_least64_t"));
        put_typedef_name(alloc_const_str("atomic_int_fast8_t"));
        put_typedef_name(alloc_const_str("atomic_uint_fast8_t"));
        put_typedef_name(alloc_const_str("atomic_int_fast16_t"));
        put_typedef_name(alloc_const_str("atomic_uint_fast16_t"));
        put_typedef_name(alloc_const_str("atomic_int_fast32_t"));
        put_typedef_name(alloc_const_str("atomic_uint_fast32_t"));
        put_typedef_name(alloc_const_str("atomic_int_fast64_t"));
        put_typedef_name(alloc_const_str("atomic_uint_fast64_t"));
        put_typedef_name(alloc_const_str("atomic_intptr_t"));
        put_typedef_name(alloc_const_str("atomic_uintptr_t"));
        put_typedef_name(alloc_const_str("atomic_size_t"));
        put_typedef_name(alloc_const_str("atomic_ptrdiff_t"));
        put_typedef_name(alloc_const_str("atomic_intmax_t"));
        put_typedef_name(alloc_const_str("atomic_uintmax_t"));
    }
    else if (str_eq(header_name, "stdbool.h"))
    {
        put_typedef_name(alloc_const_str("bool"));
    }
    else if (str_eq(header_name, "stddef.h"))
    {
        put_typedef_name(alloc_const_str("ptrdiff_t"));
        put_typedef_name(alloc_const_str("size_t"));
        put_typedef_name(alloc_const_str("max_align_t"));
        put_typedef_name(alloc_const_str("wchar_t"));
        put_typedef_name(alloc_const_str("rsize_t"));
    }
    else if (str_eq(header_name, "stdint.h"))
    {
        put_typedef_name(alloc_const_str("int8_t"));
        put_typedef_name(alloc_const_str("int16_t"));
        put_typedef_name(alloc_const_str("int32_t"));
        put_typedef_name(alloc_const_str("int64_t"));
        put_typedef_name(alloc_const_str("uint8_t"));
        put_typedef_name(alloc_const_str("uint16_t"));
        put_typedef_name(alloc_const_str("uint32_t"));
        put_typedef_name(alloc_const_str("uint64_t"));
        put_typedef_name(alloc_const_str("int_least8_t"));
        put_typedef_name(alloc_const_str("int_least16_t"));
        put_typedef_name(alloc_const_str("int_least32_t"));
        put_typedef_name(alloc_const_str("int_least64_t"));
        put_typedef_name(alloc_const_str("uint_least8_t"));
        put_typedef_name(alloc_const_str("uint_least16_t"));
        put_typedef_name(alloc_const_str("uint_least32_t"));
        put_typedef_name(alloc_const_str("uint_least64_t"));
        put_typedef_name(alloc_const_str("int_fast8_t"));
        put_typedef_name(alloc_const_str("int_fast16_t"));
        put_typedef_name(alloc_const_str("int_fast32_t"));
        put_typedef_name(alloc_const_str("int_fast64_t"));
        put_typedef_name(alloc_const_str("uint_fast8_t"));
        put_typedef_name(alloc_const_str("uint_fast16_t"));
        put_typedef_name(alloc_const_str("uint_fast32_t"));
        put_typedef_name(alloc_const_str("uint_fast64_t"));
        put_typedef_name(alloc_const_str("intptr_t"));
        put_typedef_name(alloc_const_str("uintptr_t"));
        put_typedef_name(alloc_const_str("intmax_t"));
        put_typedef_name(alloc_const_str("uintmax_t"));
    }
    else if (str_eq(header_name, "stdio.h"))
    {
        if (!is_typedef_name("errno_t")) add_str_typedef("errno.h");
        if (!is_typedef_name("size_t")) add_str_typedef("stddef.h");
        put_typedef_name(alloc_const_str("FILE"));
        put_typedef_name(alloc_const_str("fpos_t"));
    }
    else if (str_eq(header_name, "stdlib.h"))
    {
        if (!is_typedef_name("errno_t")) add_str_typedef("errno.h");
        if (!is_typedef_name("size_t")) add_str_typedef("stddef.h");
        put_typedef_name(alloc_const_str("div_t"));
        put_typedef_name(alloc_const_str("ldiv_t"));
        put_typedef_name(alloc_const_str("lldiv_t"));
        put_typedef_name(alloc_const_str("constraint_handler_t"));
    }
    else if (str_eq(header_name, "stdnoreturn.h"))
    {
        put_typedef_name(alloc_const_str("noreturn"));
    }
    else if (str_eq(header_name, "string.h"))
    {
        if (!is_typedef_name("errno_t")) add_str_typedef("errno.h");
        if (!is_typedef_name("size_t")) add_str_typedef("stddef.h");
    }
    else if (str_eq(header_name, "tgmath.h"))
    {
        add_str_typedef("math.h");
        add_str_typedef("complex.h");
    }
    else if (str_eq(header_name, "threads.h"))
    {
        put_typedef_name(alloc_const_str("thread_local"));
        put_typedef_name(alloc_const_str("cnd_t"));
        put_typedef_name(alloc_const_str("thrd_t"));
        put_typedef_name(alloc_const_str("tss_t"));
        put_typedef_name(alloc_const_str("mtx_t"));
        put_typedef_name(alloc_const_str("tss_dtor_t"));
        put_typedef_name(alloc_const_str("thrd_start_t"));
        put_typedef_name(alloc_const_str("once_flag"));
    }
    else if (str_eq(header_name, "time.h"))
    {
        if (!is_typedef_name("errno_t")) add_str_typedef("errno.h");
        if (!is_typedef_name("size_t")) add_str_typedef("stddef.h");
        put_typedef_name(alloc_const_str("clock_t"));
        put_typedef_name(alloc_const_str("time_t"));
    }
    else if (str_eq(header_name, "uchar.h"))
    {
        if (!is_typedef_name("mbstate_t")) add_str_typedef("wchar.h");
        if (!is_typedef_name("size_t")) add_str_typedef("stddef.h");
        put_typedef_name(alloc_const_str("char16_t"));
        put_typedef_name(alloc_const_str("char32_t"));
    }
    else if (str_eq(header_name, "wchar.h"))
    {
        if (!is_typedef_name("errno_t")) add_str_typedef("errno.h");
        if (!is_typedef_name("size_t")) add_str_typedef("stddef.h");
        if (!is_typedef_name("FILE")) add_str_typedef("stdio.h");
        put_typedef_name(alloc_const_str("mbstate_t"));
        put_typedef_name(alloc_const_str("wint_t"));
    }
    else if (str_eq(header_name, "wctype.h"))
    {
        if (!is_typedef_name("wint_t")) add_str_typedef("wchar.h");
        put_typedef_name(alloc_const_str("wctrans_t"));
        put_typedef_name(alloc_const_str("wctype_t"));
    }
}
