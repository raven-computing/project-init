${{VAR_COPYRIGHT_HEADER}}

${{VAR_CPP_HEADER_BEGIN}}

#include <string>


${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * Main application class.
 */
class Application {

public:

    /**
     * Returns the string produced by the application.
     *
     * @return The string value of the application.
     */
    static std::string getValue();

}; // END CLASS Application

${{VAR_NAMESPACE_DECL_END}}
${{VAR_CPP_HEADER_END}}
