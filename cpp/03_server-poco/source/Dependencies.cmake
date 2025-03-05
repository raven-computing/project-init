include(cmake/DependencyUtil.cmake)

dependency(
    DEPENDENCY_NAME         poco
    DEPENDENCY_RESOURCE     pocoproject/poco
    DEPENDENCY_VERSION      poco-1.14.1-release
)

${{INCLUDE:cpp/cmake/DependenciesCommon.cmake}}
