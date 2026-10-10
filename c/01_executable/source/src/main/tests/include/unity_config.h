${{VAR_COPYRIGHT_HEADER}}

${{VAR_C_HEADER_BEGIN}}

#ifndef _WIN32

#ifndef UNITY_EXCLUDE_SETJMP_H
#include <setjmp.h>
#else
#error "Cannot use UNITY_EXCLUDE_SETJMP_H compile definition in this project"
#endif

// Global flag to track if any test has failed
extern int APP_ASSERTION_FAILURE_DISABLE_LSAN;

static void onUnityTestAbort(void) {
    APP_ASSERTION_FAILURE_DISABLE_LSAN = 1;
}

#define UNITY_TEST_ABORT() \
    do { \
        onUnityTestAbort(); \
        longjmp(Unity.AbortFrame, 1); \
    } while(0)

#endif

${{VAR_C_HEADER_END}}
