${{VAR_COPYRIGHT_HEADER}}

#include <string>

#include "${{VAR_NAMESPACE_PATH}}/StringGenerator.h"

${{VAR_NAMESPACE_DECL_BEGIN}}
using std::string;

StringGenerator::StringGenerator()
    :count(0) { }


string StringGenerator::generate() {
    return "${{VAR_PROJECT_SLOGAN_STRING}} " + std::to_string(count++);
}

${{VAR_NAMESPACE_DECL_END}}
