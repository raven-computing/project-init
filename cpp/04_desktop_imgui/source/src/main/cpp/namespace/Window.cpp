${{VAR_COPYRIGHT_HEADER}}

#include <string>

#include "imgui.h"
// ImGUI backend to be used
#include "imgui_impl_glfw.h"
#include "imgui_impl_opengl3.h"
// GLFW includes OpenGL headers
#include "GLFW/glfw3.h"

#include "${{VAR_NAMESPACE_PATH}}/Window.h"

${{VAR_NAMESPACE_DECL_BEGIN}}
using std::string;

static void glfwErrorCallback(int error, const char* description) {
    fprintf(stderr, "GLFW Error %d: %s\n", error, description);
}

Window::Window(string title) {
    this->title = title;
}

int Window::setup() {
    // Setup error callback and init GLFW
    glfwSetErrorCallback(glfwErrorCallback);
    if (!glfwInit()) {
        return 127;
    }
    // GL 3.0
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 0);

    return 0;
}

int Window::create() {
    // Create GLFW window with graphics context
    int width = 1280;
    int height = 800;
    GLFWwindow* window = glfwCreateWindow(
        width, height,
        this->title.c_str(),
        NULL, NULL
    );
    if (window == NULL) {
        return 1;
    }
    this->glfwWindow = window;

    glfwMakeContextCurrent(window);
    // Enable vsync
    glfwSwapInterval(1);

    // ImGUI context
    IMGUI_CHECKVERSION();
    ImGui::CreateContext();

    // ImGUI styles
    ImGui::StyleColorsDark();
    // ImGui::StyleColorsLight();
    // ImGui::StyleColorsClassic();

    // Setup renderer backend
    ImGui_ImplGlfw_InitForOpenGL(window, true);
    ImGui_ImplOpenGL3_Init("#version 130");
    return 0;
}

void Window::show() {
    bool showDemoWindow = true;
    ImVec4 colors = ImVec4(0.45f, 0.55f, 0.60f, 1.00f);

    // Main loop
    while (!glfwWindowShouldClose(this->glfwWindow)) {
        glfwPollEvents();

        // Start ImGUI frame
        ImGui_ImplOpenGL3_NewFrame();
        ImGui_ImplGlfw_NewFrame();
        ImGui::NewFrame();

        // This place is where you can put your own stuff.
        // Currently, we just show the ImGUI demo window
        ImGui::ShowDemoWindow(&showDemoWindow);

        ImGui::Render();

        int displayWidth;
        int displayHeight;
        glfwGetFramebufferSize(
            this->glfwWindow,
            &displayWidth,
            &displayHeight
        );
        glViewport(0, 0, displayWidth, displayHeight);
        glClearColor(
            colors.x * colors.w,
            colors.y * colors.w,
            colors.z * colors.w,
            colors.w
        );
        glClear(GL_COLOR_BUFFER_BIT);
        ImGui_ImplOpenGL3_RenderDrawData(ImGui::GetDrawData());

        glfwSwapBuffers(this->glfwWindow);
    }
}

void Window::terminate() {
    // ImGUI backend
    ImGui_ImplOpenGL3_Shutdown();
    ImGui_ImplGlfw_Shutdown();

    // ImGUI core
    ImGui::DestroyContext();

    // GLFW
    glfwDestroyWindow(this->glfwWindow);
    glfwTerminate();
}

${{VAR_NAMESPACE_DECL_END}}
