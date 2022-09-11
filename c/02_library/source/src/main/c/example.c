${{VAR_COPYRIGHT_HEADER}}

#include <stdio.h>

#include "example.h"


static const char* TEXT = "${{VAR_PROJECT_SLOGAN_STRING}}\n";

int addFortyTwo(const int number){
    return number + 42;
}

const char* getText(){
    return TEXT;
}
