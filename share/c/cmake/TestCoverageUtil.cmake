# Copyright (C) 2025 Raven Computing
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#==============================================================================
#
# Contains a function for adding compiler options to targets in CMake-based
# projects to add support for code test coverage instrumentation.
# The minimum CMake version required by this code is 3.22.
#
#==============================================================================

# Adds code test coverage support to a given CMake target.
#
# Appends the appropriate compiler flags to enable code test
# coverage instrumentation for the specified target.
# Code coverage should only be enabled for debug builds.
#
# Arguments:
#
#   target_name:
#       The name of the target to which code coverage support will be added.
#       This argument is mandatory.
#
# Example:
#   add_code_coverage(mytarget)
#
function(add_code_coverage target_name)
    if(WIN32 AND CMAKE_GENERATOR MATCHES "^Visual Studio")
        message(
            WARNING
            "Building code with test coverage instrumentation "
            "is not available on Windows with the Visual Studio generator. "
            "If you want to enable the use of code coverage metrics "
            "on Windows, please build with GCC via MSYS2/MinGW."
        )
        return()
    endif()
    if((DEFINED CMAKE_C_COMPILER_ID AND NOT CMAKE_C_COMPILER_ID STREQUAL "GNU")
        OR (DEFINED CMAKE_CXX_COMPILER_ID
            AND NOT CMAKE_CXX_COMPILER_ID STREQUAL "GNU"))
        if(MSYS)
            message(
                WARNING
                "When building with code test coverage support on Windows "
                "with MSYS2/MinGW, GCC must be used as the compiler."
            )
        else()
            message(
                WARNING
                "When building with code test coverage support, "
                "only GCOV via GCC is currently supported."
            )
        endif()
        return()
    endif()

    string(TOUPPER ${CMAKE_BUILD_TYPE} PROJECT_BUILD_TYPE)
    message(
        STATUS "Adding code coverage instrumentation to target ${target_name}"
    )
    if(NOT ${PROJECT_BUILD_TYPE} STREQUAL "DEBUG")
        message(
            WARNING
            "Code test coverage measurements should only be performed "
            "with a non-optimized debug build"
        )
    endif()

    target_compile_options(
        ${target_name}
        PRIVATE
        -ftest-coverage -fprofile-arcs -fno-default-inline
        $<$<COMPILE_LANGUAGE:CXX>:-fno-elide-constructors>
    )
    target_link_libraries(
        ${target_name}
        PRIVATE
        gcov
    )

endfunction()
