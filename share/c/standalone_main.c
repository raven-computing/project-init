//
// Compile with:  gcc main.c -o main
//

#include <stdio.h>

int main(int argc, char** argv) {
    printf("%s\n", "${{VAR_PROJECT_SLOGAN_STRING}}");
    return 0;
}
