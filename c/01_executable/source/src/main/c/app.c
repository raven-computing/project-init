${{VAR_COPYRIGHT_HEADER}}

#include <stdio.h>

#include "app.h"

int getFortyTwo(void) {
    /* NOLINTBEGIN(readability-magic-numbers) */
    return 42;
    /* NOLINTEND(readability-magic-numbers) */
}

ExitStatus printText(void) {
    logStdout("${{VAR_PROJECT_SLOGAN_STRING}}\n");
    return APP_EXIT_SUCCESS;
}
