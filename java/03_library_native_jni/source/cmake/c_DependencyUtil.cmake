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
# This file contains a function for specifying dependencies in CMake-based
# projects. It is a thin wrapper around the FetchContent machinery provided
# by CMake. The minimum CMake version required by this code is v3.14.
#
#==============================================================================

include(FetchContent)

# This function can be used by CMake projects to declare dependencies as
# either Git repositories or source archive files. It is a thin wrapper
# around the FetchContent machinery provided by CMake. By using this function,
# a dependency becomes available to the underlying project in a
# declarative way. There are three steps involved in processing a dependency:
# First, the specified dependency is passed to the CMake FetchContent_Declare()
# function. The caller does not need to take care of the different arguments
# as used by FetchContent_Declare(), as they are handled entirely by
# this function. Secondly, an additional configuration file is potentially
# included by this function. The purpose of such a file is to configure the
# dependency to be made available to the underlying project. The configuration
# file can contain arbitrary CMake code. Lastly, the dependency is made
# available by means of the CMake FetchContent_MakeAvailable() function.
#
# The configuration file for a dependency is an ordinary CMake file, i.e. it
# must contain syntactically valid CMake code. Each dependency configuration
# file is included by this function. It can be used to set variables or do any
# other kind of processing in order to properly configure the dependency to
# be used by the underlying project. If no concrete config file is
# specified by the DEPENDENCY_CONFIG_FILE argument, then this function will
# look for a dependency config file in the "cmake" directory relative
# to CMAKE_CURRENT_SOURCE_DIR. The corresponding config file must be
# named "Config${DEPENDENCY_NAME}.cmake", where ${DEPENDENCY_NAME} is the
# value of the mandatory dependency name argument. Please note that the
# first character of the otherwise lowercase dependency name is always
# capitalised, resulting in a camelcase-style file name. For example, if a
# concrete dependency is named "mydep", then the conventional config file
# has to be named "ConfigMydep.cmake". The inclusion of any dependency config
# file can be disabled by using the DEPENDENCY_NO_CONFIG option.
#
# Every dependency has a scope. A dependency is only used if its scope
# is active. The following scopes are available: "ANY", "RELEASE", "TEST"
# and "DEBUG". The "ANY" scope is the default scope and will cause the
# dependency to be used in any case. The "RELEASE" scope is active if the
# project is configured to produce a release build. This is true when the
# standard CMake variable CMAKE_BUILD_TYPE is equal to "Release". Please note
# that other release build types like "RelWithDebInfo" or "MinSizeRel" are not
# considered by this scope. The "TEST" scope can be used for dependencies only
# needed to run the project tests. This scope is active if the *_BUILD_TESTS
# variable is true, where the "*" represents the project name as given to the
# CMake project() function, in all upper case. The project name is taken from
# the standard PROJECT_NAME CMake variable. The "DEBUG" scope is active if the
# project is configured to produce a debug build. This is true when the
# standard CMake variable CMAKE_BUILD_TYPE is equal to "Debug".
#
# Arguments:
#
#   [oneValueArgs]
#
#   DEPENDENCY_NAME:
#       The name of the dependency, as a lowercase string. Must be unique
#       throughout the entire project. This argument is mandatory.
#
#   DEPENDENCY_RESOURCE:
#       The source code resource of the dependency.
#       This can be specified in two ways. It can either point to a Git
#       repository or a remote/local archive file containg the source.
#       In the case of a Git repository, it can be specified as the entire URL
#       pointing to the Git repository (long form), or simply specified as the
#       organisation and repository name separated with a slash ('/')
#       delimiter (short form). The short form, e.g. 'myorga/myrepo', will be
#       autocompleted to a full GitHub repository URL.
#       In the case of a file, it must represent a valid archive file
#       in either ZIP or TAR format. An archive file can be specified as
#       a URL, in which case the file will be fetched from that URL.
#       Supported protocols for archive file URLs are "http://", "https://"
#       and "file://" (for files within the local filesystem).
#       This argument is mandatory.
#
#   DEPENDENCY_VERSION:
#       The version specifier of the dependency.
#       If the dependency resource is a Git repository, then this argument
#       must be specified. It can then either represent a Git branch,
#       a Git tag or a Git commit hash. If the dependency resource is an
#       archive file, then this argument is optional and has purely
#       declarative purposes without any real effects.
#
#   DEPENDENCY_SCOPE:
#       The scope of the dependency. Supported scopes are "ANY", "RELEASE",
#       "TEST" and "DEBUG". This determines whether the dependency is used
#       or not, depending on whether the specified scope is active. This
#       argument is optional and can be omitted.
#       The default scope is "ANY".
#
#   DEPENDENCY_FILE_HASH:
#       The SHA256 hash value of the dependency resource archive file.
#       This argument must only be used when the dependency resource represents
#       an archive file. The hash must be specified as a hex string. It is used
#       to verify the integrity of the fetched file. It is a mandatory argument
#       for archive file dependency resources.
#
#   DEPENDENCY_CONFIG_FILE:
#       The relative path to the file containing CMake instructions to be used
#       to configure the dependency. This argument can optionally be used to
#       specify a file which deviates from the convention.
#
#   [options]
#
#   DEPENDENCY_QUIET:
#       Suppresses all output with regard to setting up the dependecy,
#       except fatal errors.
#
#   DEPENDENCY_VERBOSE:
#       Shows verbose output with regard to setting up the dependecy.
#       This option does not usually need to be used but can be helpful
#       to troubleshoot a failing dependency.
#
#   DEPENDENCY_NO_CONFIG:
#       Disables the inclusion of any dependency config files.
#
# Example usage:
#
# dependency(
#     DEPENDENCY_NAME         unity
#     DEPENDENCY_RESOURCE     https://github.com/ThrowTheSwitch/Unity.git
#     DEPENDENCY_VERSION      v2.5.2
#     DEPENDENCY_SCOPE        TEST
# )
#
function(dependency)

    set(options
        DEPENDENCY_QUIET
        DEPENDENCY_NO_CONFIG
        DEPENDENCY_VERBOSE
    )
    set(oneValueArgs
        DEPENDENCY_NAME
        DEPENDENCY_RESOURCE
        DEPENDENCY_VERSION
        DEPENDENCY_SCOPE
        DEPENDENCY_FILE_HASH
        DEPENDENCY_CONFIG_FILE
    )
    set(multiValueArgs "")

    cmake_parse_arguments(
        DEP_ARGS
        "${options}"
        "${oneValueArgs}"
        "${multiValueArgs}"
        ${ARGN}
    )

    # The default URL to use for dependencies declared
    # with the DEPENDENCY_RESOURCE short form
    set(DEPENDENCY_BASE_URL_DEFAULT "https://github.com")

    # Check debug scope
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Debug")
        set(SCOPE_DEBUG_ACTIVE 1)
    else()
        set(SCOPE_DEBUG_ACTIVE 0)
    endif()

    string(TOUPPER ${PROJECT_NAME} PROJECT_NAME_UPPER)

    # Check test scope
    if(${${PROJECT_NAME_UPPER}_BUILD_TESTS})
        set(SCOPE_TEST_ACTIVE 1)
    else()
        set(SCOPE_TEST_ACTIVE 0)
    endif()

    # Check release scope
    if("${CMAKE_BUILD_TYPE}" STREQUAL "Release")
        set(SCOPE_RELEASE_ACTIVE 1)
    else()
        set(SCOPE_RELEASE_ACTIVE 0)
    endif()

    if(NOT DEP_ARGS_DEPENDENCY_SCOPE)
        set(DEPENDENCY_SCOPE ANY)
    else()
       set(DEPENDENCY_SCOPE ${DEP_ARGS_DEPENDENCY_SCOPE})
    endif()

    set(DEP_ALLOWED_SCOPES ANY RELEASE TEST DEBUG)

    if(NOT "${DEPENDENCY_SCOPE}" IN_LIST DEP_ALLOWED_SCOPES)
        message(
            FATAL_ERROR
            "Invalid scope argument for "
            "dependency ${DEP_ARGS_DEPENDENCY_NAME}: "
            "Expected any of ${DEP_ALLOWED_SCOPES} but "
            "found ${DEPENDENCY_SCOPE}"
        )
    endif()

    # Check if specified scope is active
    if("${DEPENDENCY_SCOPE}" STREQUAL "DEBUG")
        if(NOT ${SCOPE_DEBUG_ACTIVE})
            return()
        endif()
    endif()

    if("${DEPENDENCY_SCOPE}" STREQUAL "TEST")
        if(NOT ${SCOPE_TEST_ACTIVE})
            return()
        endif()
    endif()

    if("${DEPENDENCY_SCOPE}" STREQUAL "RELEASE")
        if(NOT ${SCOPE_RELEASE_ACTIVE})
            return()
        endif()
    endif()

    if(NOT DEP_ARGS_DEPENDENCY_QUIET)
        message(STATUS "Processing dependency ${DEP_ARGS_DEPENDENCY_NAME}")
    endif()

    if(DEP_ARGS_DEPENDENCY_VERBOSE)
        set(FETCHCONTENT_QUIET OFF)
    endif()

    # Check if dependency resource was specified in a short form
    set(_DEP_INTEGRATION_URL_PATTERN
        "^[A-Za-z0-9]+[A-Za-z0-9-]*\/[A-Za-z0-9]+[A-Za-z0-9-]*$"
    )
    if(${DEP_ARGS_DEPENDENCY_RESOURCE} MATCHES ${_DEP_INTEGRATION_URL_PATTERN})
        set(_DEP_SRC_RES "${DEP_ARGS_DEPENDENCY_RESOURCE}.git")
        # Check if the environment overrides the default base URL to be used
        if(DEFINED ENV{PROJECTS_CMAKE_DEPENDENCIES_INTEGRATION_URL})
            set(_DEP_BASE_URL
                "$ENV{PROJECTS_CMAKE_DEPENDENCIES_INTEGRATION_URL}"
            )
        else()
            set(_DEP_BASE_URL "${DEPENDENCY_BASE_URL_DEFAULT}")
        endif()
        # Overwrite resource arg
        set(DEP_ARGS_DEPENDENCY_RESOURCE "${_DEP_BASE_URL}/${_DEP_SRC_RES}")
    endif()

    if(${DEP_ARGS_DEPENDENCY_RESOURCE} MATCHES "\.git$")
        # Git repository
        FetchContent_Declare(
            ${DEP_ARGS_DEPENDENCY_NAME}
            GIT_REPOSITORY ${DEP_ARGS_DEPENDENCY_RESOURCE}
            GIT_TAG        ${DEP_ARGS_DEPENDENCY_VERSION}
        )
    else()
        if(${DEP_ARGS_DEPENDENCY_RESOURCE} MATCHES "^(http|https|file)://")
            # Source archive file
            if(NOT DEFINED DEP_ARGS_DEPENDENCY_FILE_HASH)
                message(
                    FATAL_ERROR
                    "Dependency ${DEP_ARGS_DEPENDENCY_NAME} has a missing "
                    "argument. Please provide argument DEPENDENCY_FILE_HASH "
                    "for archive file dependency resources."
                )
            endif()
            FetchContent_Declare(
                ${DEP_ARGS_DEPENDENCY_NAME}
                URL ${DEP_ARGS_DEPENDENCY_RESOURCE}
                URL_HASH SHA256=${DEP_ARGS_DEPENDENCY_FILE_HASH}
            )
        else()
            message(
                FATAL_ERROR
                "Dependency ${DEP_ARGS_DEPENDENCY_NAME} resource value "
                "must either represent a Git repository "
                "(ending with '.git'), or a file resource in either "
                "'.zip' or 'tar.gz' format accessible over HTTP(S) or as "
                "a local file resource."
            )
        endif()
    endif()

    # Check if a config file needs to be included
    if(NOT ${DEP_ARGS_DEPENDENCY_NO_CONFIG})
        if(DEFINED DEP_ARGS_DEPENDENCY_CONFIG_FILE)
            # Specific file provided by function arg
            set(DEPENDENCY_CONFIG_FILE "${CMAKE_CURRENT_SOURCE_DIR}/")
            string(
                APPEND
                DEPENDENCY_CONFIG_FILE
                "${DEP_ARGS_DEPENDENCY_CONFIG_FILE}"
            )
            if(EXISTS "${DEPENDENCY_CONFIG_FILE}")
                include("${DEPENDENCY_CONFIG_FILE}")
            else()
                message(
                    WARNING
                    "No configuration file found for "
                    "dependency ${DEPENDENCY_CONFIG_FILE}"
                )
            endif()
        else()
            # Use the conventional file
            string(
                TOLOWER
                ${DEP_ARGS_DEPENDENCY_NAME}
                DEPENDENCY_NAME_LOWER
            )
            string(
                SUBSTRING
                ${DEPENDENCY_NAME_LOWER} 1 -1
                DEPENDENCY_NAME_LOWER
            )
            string(
                SUBSTRING
                ${DEP_ARGS_DEPENDENCY_NAME} 0 1
                DEPENDENCY_NAME_FIRST
            )
            string(
                TOUPPER
                ${DEPENDENCY_NAME_FIRST}
                DEPENDENCY_NAME_FIRST
            )
            set(DEPENDENCY_CONFIG_FILE "cmake/Config")
            string(APPEND DEPENDENCY_CONFIG_FILE ${DEPENDENCY_NAME_FIRST})
            string(APPEND DEPENDENCY_CONFIG_FILE ${DEPENDENCY_NAME_LOWER})
            string(APPEND DEPENDENCY_CONFIG_FILE ".cmake")
            string(
                PREPEND
                DEPENDENCY_CONFIG_FILE
                "${CMAKE_CURRENT_SOURCE_DIR}" "/"
            )
            if(EXISTS "${DEPENDENCY_CONFIG_FILE}")
                include("${DEPENDENCY_CONFIG_FILE}")
            endif()
        endif()
    endif()

    FetchContent_MakeAvailable(${DEP_ARGS_DEPENDENCY_NAME})

endfunction()