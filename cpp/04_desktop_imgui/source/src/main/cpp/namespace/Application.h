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
     * Returns the title string of the application.
     *
     * @return The title of the application.
     */
    static std::string getTitle();

    /**
     * Starts and runs the GUI application.
     *
     * @return The application exit status.
     */
    static int run();

}; // END CLASS Application

${{VAR_NAMESPACE_DECL_END}}
#endif // ${{VAR_NAMESPACE_INCLUDE_GUARD}}_APPLICATION_H
