${{VAR_COPYRIGHT_HEADER}}

${{VAR_CPP_HEADER_BEGIN}}

#include <string>

#include "GLFW/glfw3.h"

${{VAR_NAMESPACE_DECL_BEGIN}}
/**
 * Main Window class.
 */
class Window {

    std::string title;
    GLFWwindow* glfwWindow;

public:

    /**
     * Constructs a new Window.
     *
     * @param title The title of the Window.
     */
    Window(std::string title);

    /**
     * Setup for the window.
     *
     * @return An int indicating the exit status of the setup procedure.
     */
    int setup();

    /**
     * Creates the GUI window.
     *
     * @return An int indicating the exit status of the window creation.
     */
    int create();

    /**
     * Shows the GUI window on the screen.
     * This contains the main loop.
     */
    void show();

    /**
     * Terminates the GUI window and releases resouces.
     */
    void terminate();

}; // END CLASS Window

${{VAR_NAMESPACE_DECL_END}}
${{VAR_CPP_HEADER_END}}
