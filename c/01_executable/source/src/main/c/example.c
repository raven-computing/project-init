${{VAR_COPYRIGHT_HEADER}}

#include <stdio.h>

#include "example.h"


int getFortyTwo(void) {
    return 42;
}

void printText(void) {
    printf("%s\n", "${{VAR_PROJECT_SLOGAN_STRING}}");
}
