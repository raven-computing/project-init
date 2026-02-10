${{VAR_COPYRIGHT_HEADER}}

#include <iostream>

#include "${{VAR_NAMESPACE_PATH}}/Application.h"

using ${{VAR_NAMESPACE_COLON}}::Application;

int main(int argc, char** argv) {
    std::cout << Application::getTitle() << std::endl;
    return Application::run();
}
