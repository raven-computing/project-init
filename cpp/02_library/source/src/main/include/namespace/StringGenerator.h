${{VAR_COPYRIGHT_HEADER}}

${{VAR_CPP_HEADER_BEGIN}}

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
${{VAR_CPP_HEADER_END}}
