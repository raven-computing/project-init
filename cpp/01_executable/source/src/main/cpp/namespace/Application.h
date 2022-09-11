${{VAR_COPYRIGHT_HEADER}}

#ifndef ${{VAR_NAMESPACE_INCLUDE_GUARD}}_APPLICATION_H
#define ${{VAR_NAMESPACE_INCLUDE_GUARD}}_APPLICATION_H

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
#endif // ${{VAR_NAMESPACE_INCLUDE_GUARD}}_APPLICATION_H
