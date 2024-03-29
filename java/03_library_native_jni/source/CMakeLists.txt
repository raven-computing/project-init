# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}
# ${{VAR_PROJECT_NAME}}: ${{VAR_PROJECT_DESCRIPTION}}

cmake_minimum_required(VERSION 3.14 FATAL_ERROR)

project(
    ${{VAR_PROJECT_NAME_LOWER}}
    VERSION 0.0.1
    DESCRIPTION "Native JNI library for the ${{VAR_PROJECT_NAME}} Java library"
    HOMEPAGE_URL "${{VAR_PROJECT_ORGANISATION_URL}}"
${{VAR_CMAKE_PROJECT_LANG_SPEC}}
)

${{VAR_CMAKE_LANG_SPEC}}

# Options
option(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS "Enable/disable tests" ON)

# Set CMAKE_PREFIX_PATH from file
if(EXISTS "${PROJECT_SOURCE_DIR}/.cmakeprefixpath")
    message(STATUS "Setting CMake prefix path")
    file(READ ".cmakeprefixpath" _VAR_CMAKE_PREFIX_PATH)
    list(APPEND CMAKE_PREFIX_PATH ${_VAR_CMAKE_PREFIX_PATH})
endif()

# Process dependencies
include(Dependencies.cmake)

# Enable testing project-wide
include(cmake/TestUtil.cmake)

add_subdirectory(src/main native)
