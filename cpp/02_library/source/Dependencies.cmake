include(cmake/DependencyUtil.cmake)

dependency(
    DEPENDENCY_NAME         gtest
    DEPENDENCY_RESOURCE     google/googletest
    DEPENDENCY_VERSION      release-1.11.0
    DEPENDENCY_SCOPE        TEST
)
