# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}
# ${{VAR_PROJECT_NAME}}: ${{VAR_PROJECT_DESCRIPTION}}

cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(
    ${{VAR_PROJECT_NAME_LOWER}}
    VERSION 0.0.1
    DESCRIPTION "${{VAR_PROJECT_DESCRIPTION}}"
    HOMEPAGE_URL "${{VAR_PROJECT_ORGANISATION_URL}}"
)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD ${{VAR_CPP_VERSION}})
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Options
option(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS "Enable/disable tests" OFF)
option(
    ${{VAR_PROJECT_NAME_UPPER}}_IGNORE_WARNINGS
    "Specifies whether compiler warnings should let the build \
    process fail (OFF) or whether they should be ignored (ON)"
    OFF
)
option(BUILD_SHARED_LIBS "Build shared libraries" OFF)
option(${{VAR_PROJECT_NAME_UPPER}}_USE_SANITIZERS "Enable/disable the use of sanitizers" OFF)
option(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TEST_COVERAGE "Enable/disable test coverage instrumentation" OFF)

# Set CMAKE_PREFIX_PATH from file
if(EXISTS "${PROJECT_SOURCE_DIR}/.cmakeprefixpath")
    message(STATUS "Setting CMake prefix path")
    file(READ ".cmakeprefixpath" _VAR_CMAKE_PREFIX_PATH)
    list(APPEND CMAKE_PREFIX_PATH ${_VAR_CMAKE_PREFIX_PATH})
endif()

include(cmake/BuildUtil.cmake)
include(cmake/TestUtil.cmake)
include(cmake/TestCoverageUtil.cmake)
include(cmake/SanitizerUtil.cmake)
include(Dependencies.cmake)

add_subdirectory(src/main main)
