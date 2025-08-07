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
# Contains functions providing build utilities.
# The minimum CMake version required by this code is v3.14.
#
#==============================================================================

# Enables all compiler warnings for the specified target.
#
# Sets non-default warning flags for the given target to help identify
# potential issues during compilation. The `inform_only` argument specifies
# whether all warnings should be treated as errors (`OFF`) or whether warnings
# should only be shown but the build should not fail (`ON`).
#
# Arguments:
#
#   target_name:
#       The name of the target to enable all compiler warnings for.
#
#   inform_only:
#       Whether to treat warnings as errors or only inform about them and
#       not cause the build to fail.
#
# Example:
#   enable_compiler_warnings(mytarget OFF)
#
function(enable_compiler_warnings target_name inform_only)
    set(WARN_AS_ERROR ON)
    if(inform_only STREQUAL "ON")
        set(WARN_AS_ERROR OFF)
    endif()

    set(FLAGS_GCC "-Wall" "-Wextra" "-pedantic")
    set(FLAGS_MSVC "/W4" "/permissive-")
    target_compile_options(
        ${target_name}
        PRIVATE
        $<$<C_COMPILER_ID:GNU>:${FLAGS_GCC}>
        $<$<C_COMPILER_ID:MSVC>:${FLAGS_MSVC}>
        $<$<CXX_COMPILER_ID:GNU>:${FLAGS_GCC}>
        $<$<CXX_COMPILER_ID:MSVC>:${FLAGS_MSVC}>
    )

    if(WARN_AS_ERROR)
        set(FLAGS_GCC "-Werror")
        set(FLAGS_MSVC "/WX")
        target_compile_options(
            ${target_name}
            PRIVATE
            $<$<C_COMPILER_ID:GNU>:${FLAGS_GCC}>
            $<$<C_COMPILER_ID:MSVC>:${FLAGS_MSVC}>
            $<$<CXX_COMPILER_ID:GNU>:${FLAGS_GCC}>
            $<$<CXX_COMPILER_ID:MSVC>:${FLAGS_MSVC}>
        )
    endif()
endfunction()

# Enables compile-time source code checks for a given CMake target.
#
# Appends the appropriate compiler flags, if available, to let the compiler
# perform static analysis on the source code at compile time.
#
# This feature is currently only available when compiling with GCC and only
# applicable for C source code. For source files written in C++, this feature
# has currently no effect.
#
# Arguments:
#
#   target_name:
#       The name of the target for which to enable source code checks.
#       This argument is mandatory.
#
# Example:
#   enable_source_compile_checks(mytarget)
#
function(enable_source_compile_checks target_name)
    if(NOT CMAKE_C_COMPILER_ID STREQUAL "GNU")
        message(
            WARNING
            "Cannot enable compile-time source code checks. "
            "This is only available when using GCC."
        )
        return()
    endif()

    target_compile_options(
        ${target_name}
        PRIVATE
        $<$<COMPILE_LANGUAGE:C>:-fanalyzer>
    )

endfunction()
