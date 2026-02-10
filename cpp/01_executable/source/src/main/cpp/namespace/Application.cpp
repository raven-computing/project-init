${{VAR_COPYRIGHT_HEADER}}

#include <string>

#include "${{VAR_NAMESPACE_PATH}}/Application.h"

${{VAR_NAMESPACE_DECL_BEGIN}}
using std::string;

string Application::getValue() {
    return "${{VAR_PROJECT_SLOGAN_STRING}}";
}

${{VAR_NAMESPACE_DECL_END}}
