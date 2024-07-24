include(cmake/DependencyUtil.cmake)

dependency(
    DEPENDENCY_NAME         imgui
    DEPENDENCY_RESOURCE     ocornut/imgui
    DEPENDENCY_VERSION      v1.90.9
    DEPENDENCY_NO_CACHE
)

dependency(
    DEPENDENCY_NAME         glfw
    DEPENDENCY_RESOURCE     glfw/glfw
    DEPENDENCY_VERSION      3.4
)

${{INCLUDE:cpp/cmake/DependenciesCommon.cmake}}
