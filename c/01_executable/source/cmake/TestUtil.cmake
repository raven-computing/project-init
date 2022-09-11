# Copyright (C) 2022 Raven Computing
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
# This file contains a function for specifying test suites in
# a declarative way. Eventually, a test suite is registered with CTest by
# making a call to the add_test() function provided by CTest. The utility
# function in this file takes care of the boilerplate setup required
# to register a new test. The minimum CMake version required by
# this code is v3.14.
#
#==============================================================================

include(CTest)

# This function is used to register a test suite with CTest. It will create
# a new target for the test executable and pass it to CTest's add_test()
# function. It is assumed that the source code of both the application and the
# tests are organised in the standard directory structure.
# The created test executable is automatically linked to unity (the used
# testing framework for C projects). It is assumed that the unity dependency
# is available to the underlying project.
#
# Arguments:
#
#   [oneValueArgs]
#
#   TEST_SUITE_NAME:
#       The name of the test suite to be created. This is the name by which
#       the test can be identified when running all tests via
#       the ctest command. This argument is mandatory.
#
#   TEST_SUITE_TARGET:
#       The target name for the test executable to be created. This argument
#       is passed on to the add_executable() function.
#       This argument is mandatory.
#
#   [multiValueArgs]
#
#   TEST_SUITE_SOURCE:
#       The paths to the source files of the test suite.
#       This argument is mandatory.
#
#   TEST_SUITE_LINK:
#       The targets that the test executable should be linked against.
#       This argument is optional.
#
# Example usage:
#
# add_test_suite(
#     TEST_SUITE_NAME      MyTestSuite
#     TEST_SUITE_TARGET    test_mylib
#     TEST_SUITE_SOURCE    c/test_myfile.c
#     TEST_SUITE_LINK      mylibtarget
# )
#
function(add_test_suite)

    set(oneValueArgs
        TEST_SUITE_NAME
        TEST_SUITE_TARGET
    )
    set(multiValueArgs
        TEST_SUITE_SOURCE
        TEST_SUITE_LINK
    )

    cmake_parse_arguments(
        TEST_SUITE_ARGS
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
    )

    # Check mandatory arguments
    if(NOT DEFINED TEST_SUITE_ARGS_TEST_SUITE_NAME)
        message(
            FATAL_ERROR
            "Missing argument 'TEST_SUITE_NAME' in call "
            "to add_test_suite() function"
        )
    endif()

    if(NOT DEFINED TEST_SUITE_ARGS_TEST_SUITE_TARGET)
        message(
            FATAL_ERROR
            "Missing argument 'TEST_SUITE_TARGET' in call "
            "to add_test_suite() function"
        )
    endif()

    if(NOT DEFINED TEST_SUITE_ARGS_TEST_SUITE_SOURCE)
        message(
            FATAL_ERROR
            "Missing argument 'TEST_SUITE_SOURCE' in call "
            "to add_test_suite() function"
        )
    endif()

    # Link against the unity target
    set(TEST_SUITE_UNITY_LINK_ARGS unity)

    # Create test target
    add_executable(
        ${TEST_SUITE_ARGS_TEST_SUITE_TARGET}
        ${TEST_SUITE_ARGS_TEST_SUITE_SOURCE}
    )

    # Include source header files
    target_include_directories(
        ${TEST_SUITE_ARGS_TEST_SUITE_TARGET}
        PRIVATE
        ../c
    )

    # Link against unity dependency targets,
    # and user provided ones
    target_link_libraries(
        ${TEST_SUITE_ARGS_TEST_SUITE_TARGET}
        ${TEST_SUITE_ARGS_TEST_SUITE_LINK}
        ${TEST_SUITE_UNITY_LINK_ARGS}
    )

    # Register the test suite
    add_test(
        NAME ${TEST_SUITE_ARGS_TEST_SUITE_NAME}
        COMMAND ${TEST_SUITE_ARGS_TEST_SUITE_TARGET}
    )

endfunction()
