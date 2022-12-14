${{VAR_COPYRIGHT_HEADER}}

#ifndef ${{VAR_NAMESPACE_INCLUDE_GUARD}}_STRING_GENERATOR_H
#define ${{VAR_NAMESPACE_INCLUDE_GUARD}}_STRING_GENERATOR_H

#include <string>

#include "${{VAR_ARTIFACT_BINARY_NAME}}_export.h"


${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * A dummy implementation of an object generating strings.
 *
 */
class ${{VAR_ARTIFACT_BINARY_NAME_UPPER}}_EXPORT StringGenerator {

    std::string val;
    int count;

public:

    /**
     * Constructs a new StringGenerator for generating dummy strings.
     */
    StringGenerator();

    /**
     * Generates a dummy string.
     *
     * @return A string of this StringGenerator
     */
    std::string generate();

}; // END CLASS StringGenerator

${{VAR_NAMESPACE_DECL_END}}
#endif // ${{VAR_NAMESPACE_INCLUDE_GUARD}}_STRING_GENERATOR_H
