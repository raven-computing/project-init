include(cmake/DependencyUtil.cmake)

dependency(
    DEPENDENCY_NAME         poco
    DEPENDENCY_RESOURCE     pocoproject/poco
    DEPENDENCY_VERSION      poco-1.13.3-release
)

${{INCLUDE:cpp/cmake/DependenciesCommon.cmake}}
