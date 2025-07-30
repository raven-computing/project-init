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
# The minimum CMake version required by this code is v3.14.
#
#==============================================================================

# Adds code test coverage support to a given CMake target.
#
# Appends the appropriate compiler flags to enable code test
# coverage instrumentation for the specified target.
# Code coverage should only be enabled for Debug builds.
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
    string(TOUPPER ${CMAKE_BUILD_TYPE} PROJECT_BUILD_TYPE)
    message(STATUS "Adding code coverage instrumentation to target ${target_name}")
    if(NOT ${PROJECT_BUILD_TYPE} STREQUAL "DEBUG")
        message(
            WARNING
            "Code test coverage measurements should only be performed "
            "with a non-optimized Debug build"
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
