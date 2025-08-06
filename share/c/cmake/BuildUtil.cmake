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
