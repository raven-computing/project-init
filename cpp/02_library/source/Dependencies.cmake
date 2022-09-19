include(cmake/DependencyUtil.cmake)

dependency(
    DEPENDENCY_NAME         gtest
    DEPENDENCY_RESOURCE     google/googletest
    DEPENDENCY_VERSION      release-1.12.1
    DEPENDENCY_SCOPE        TEST
)
