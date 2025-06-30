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
# Contains a function for adding compile and link options to targets in
# CMake-based projects to add support for sanitizers, for example address
# and memory leak sanitizers.
# The minimum CMake version required by this code is v3.14.
#
#==============================================================================

# Adds sanitizer support to a given CMake target.
#
# Appends the appropriate compiler and linker flags to enable the requested
# sanitizers for the specified target.
#
# Arguments:
#
#   target_name:
#       The name of the target to which sanitizers will be added.
#       This argument is mandatory.
#
#   sanitizers:
#       The types of sanitizers to enable. At least one sanitizer type must
#       be specified. More than one can be specified by separating them
#       with spaces. Supported sanitizers are: 'address', 'leak', 'undefined'.
#
# Usage:
#   add_sanitizers(<target_name> <sanitizer1> [<sanitizer2> ...])
#
# Example:
#   add_sanitizers(mytarget address leak undefined)
#
function(add_sanitizers target_name)
    set(SAN_TARGET_NAME "${target_name}")
    set(SAN_SANITIZERS ${ARGN})
    set(SAN_COMPILE_FLAGS "")
    set(SAN_LINK_FLAGS "")
    set(SAN_COMPILER_ARG "-fsanitize")
    set(SAN_LINKER_ARG "-fsanitize")

    if("${SAN_SANITIZERS}" STREQUAL "")
        message(
            FATAL_ERROR
            "No sanitizers specified for target ${SAN_TARGET_NAME}. "
            "Please specify at least one sanitizer type."
        )
    endif()

    foreach(SANITIZER_TYPE ${SAN_SANITIZERS})
        if(SANITIZER_TYPE STREQUAL "address")
            list(APPEND SAN_COMPILE_FLAGS "${SAN_COMPILER_ARG}=address")
            list(APPEND SAN_LINK_FLAGS "${SAN_LINKER_ARG}=address")
        elseif(SANITIZER_TYPE STREQUAL "leak")
            list(APPEND SAN_COMPILE_FLAGS "${SAN_COMPILER_ARG}=leak")
            list(APPEND SAN_LINK_FLAGS "${SAN_LINKER_ARG}=leak")
        elseif(SANITIZER_TYPE STREQUAL "undefined")
            list(APPEND SAN_COMPILE_FLAGS "${SAN_COMPILER_ARG}=undefined")
            list(APPEND SAN_LINK_FLAGS "${SAN_LINKER_ARG}=undefined")
        else()
            message(FATAL_ERROR "Unsupported sanitizer type: ${SANITIZER_TYPE}")
        endif()
    endforeach()

    list(APPEND SAN_COMPILE_FLAGS "-fno-omit-frame-pointer")

    target_compile_options(${SAN_TARGET_NAME} PUBLIC ${SAN_COMPILE_FLAGS})
    target_link_options(${SAN_TARGET_NAME} PUBLIC ${SAN_LINK_FLAGS})

endfunction()
