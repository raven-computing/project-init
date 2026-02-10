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
${{VAR_CPP_HEADER_END}}
