${{VAR_COPYRIGHT_HEADER}}

int APP_ASSERTION_FAILURE_DISABLE_LSAN = 0;

#if defined(__has_include) && __has_include(<sanitizer/lsan_interface.h>)
int __lsan_is_turned_off(void) { // NOLINT
    return APP_ASSERTION_FAILURE_DISABLE_LSAN;
}
#endif
