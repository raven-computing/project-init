${{VAR_COPYRIGHT_HEADER}}

${{VAR_CPP_HEADER_BEGIN}}

#include <string>

${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * An object that processes strings.
 *
 */
class StringProcessor {

    std::string val;

public:

    /**
     * Constructs a new StringProcessor.
     */
    StringProcessor(const std::string& value);

    /**
     * Reverses the string.
     *
     * @return The reversed string of this StringProcessor.
     */
    std::string reverse();

}; // END CLASS StringProcessor

${{VAR_NAMESPACE_DECL_END}}
${{VAR_CPP_HEADER_END}}
