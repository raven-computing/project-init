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
# this code is 3.22.
#
#==============================================================================

include(CTest)

# This function is used to register a test suite with CTest. It will create
# a new target for the test executable and pass it to CTest's add_test()
# function. It is assumed that the source code of both the application and the
# tests are organised in the standard directory structure.
# The created test executable is automatically linked to both gtest and gmock.
# Please note that this is different from gtest_main and gmock_main
# respectively, which means that each test suite needs to implement a standard
# main function. If you wish to link against gtest_main and gmock_main, then
# you must specify the TEST_SUITE_LINK_MAIN option to this function.
# It is assumed that gtest and gmock dependencies are available
# to the underlying project.
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
#   [options]
#
#   TEST_SUITE_LINK_MAIN:
#       This option will cause the created test executable to be linked
#       against gtest_main and gmock_main respectively, instead
#       of gtest and gmock.
#
# Example usage:
#
# add_test_suite(
#     TEST_SUITE_NAME      MyTestSuite
#     TEST_SUITE_TARGET    test_mylib
#     TEST_SUITE_SOURCE    cpp/MyLibTest.cpp
#     TEST_SUITE_LINK      mylibtarget
# )
#
function(add_test_suite)

    set(options
        TEST_SUITE_LINK_MAIN
    )
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

    # Check options
    if(TEST_SUITE_ARGS_TEST_SUITE_LINK_MAIN)
        set(TEST_SUITE_GTEST_LINK_ARGS gtest_main gmock_main)
    else()
        set(TEST_SUITE_GTEST_LINK_ARGS gtest gmock)
    endif()

    # Create test target
    add_executable(
        ${TEST_SUITE_ARGS_TEST_SUITE_TARGET}
        ${TEST_SUITE_ARGS_TEST_SUITE_SOURCE}
    )

    # Include source header files
    target_include_directories(
        ${TEST_SUITE_ARGS_TEST_SUITE_TARGET}
        PRIVATE
        ../cpp
    )

    # Link against gtest and gmock dependency targets,
    # and user provided ones
    target_link_libraries(
        ${TEST_SUITE_ARGS_TEST_SUITE_TARGET}
        ${TEST_SUITE_ARGS_TEST_SUITE_LINK}
        ${TEST_SUITE_GTEST_LINK_ARGS}
    )

    # Register the test suite
    add_test(
        NAME ${TEST_SUITE_ARGS_TEST_SUITE_NAME}
        COMMAND ${TEST_SUITE_ARGS_TEST_SUITE_TARGET}
    )

endfunction()
