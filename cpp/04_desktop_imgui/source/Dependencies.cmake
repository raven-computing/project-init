include(cmake/DependencyUtil.cmake)

dependency(
    DEPENDENCY_NAME         imgui
    DEPENDENCY_RESOURCE     ocornut/imgui
    DEPENDENCY_VERSION      v1.89.8
    DEPENDENCY_NO_CACHE
)

dependency(
    DEPENDENCY_NAME         glfw
    DEPENDENCY_RESOURCE     glfw/glfw
    DEPENDENCY_VERSION      3.3.8
)

${{INCLUDE:cpp/cmake/DependenciesCommon.cmake}}
