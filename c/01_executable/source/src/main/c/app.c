${{VAR_COPYRIGHT_HEADER}}

#include <stdio.h>

#include "app.h"

int getFortyTwo(void) {
    return 42;
}

ExitStatus printText(void) {
    logStdout("${{VAR_PROJECT_SLOGAN_STRING}}\n");
    return APP_EXIT_SUCCESS;
}
