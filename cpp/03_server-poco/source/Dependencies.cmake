include(cmake/DependencyUtil.cmake)

dependency(
    DEPENDENCY_NAME         poco
    DEPENDENCY_RESOURCE     pocoproject/poco
    DEPENDENCY_VERSION      poco-1.14.2-release
    DEPENDENCY_LINK_TARGETS Poco::XML Poco::JSON Poco::Net Poco::Util
)

${{INCLUDE:cpp/cmake/DependenciesCommon.cmake}}
