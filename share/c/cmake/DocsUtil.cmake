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
# Contains functions providing utilities for documentation resource generation.
# The minimum CMake version required by this code is v3.14.
#
#==============================================================================

# Performs setup for Doxygen builds.
#
# Downloads and configures a Doxygen theme if not already available in the
# build tree. The theme is downloaded into a cache directory to avoid repeated
# downloads. If the environment variable `A_CMAKE_DEPENDENCY_NO_CACHE` is set
# to '1', then the theme will be downloaded directly into the build directory.
#
function(setup_doxygen_build)
    set(THEME_DEPENDENCY "doxygen-theme")
    set(THEME_VERSION "v2.4.0")
    set(CACHE_PATH "$ENV{HOME}/.cache/cmake_deps_src")
    set(THEME_CACHE_PATH "${CACHE_PATH}/${THEME_DEPENDENCY}/${THEME_VERSION}")
    set(THEME_RESOURCE_PATH "${FETCHCONTENT_BASE_DIR}/${THEME_DEPENDENCY}")
    set(THEME_DOWNLOAD OFF)

    if("$ENV{A_CMAKE_DEPENDENCY_NO_CACHE}" STREQUAL "1"
        OR NOT DEFINED ENV{HOME})
        set(THEME_DOWNLOAD ON)
    else()
        if(NOT EXISTS "${THEME_RESOURCE_PATH}")
            if(NOT EXISTS "${THEME_CACHE_PATH}")
                set(THEME_DOWNLOAD ON)
            endif()
        endif()
    endif()

    if(${THEME_DOWNLOAD})
        message(STATUS "Downloading Doxygen theme")
        dependency(
            DEPENDENCY_NAME     "${THEME_DEPENDENCY}"
            DEPENDENCY_RESOURCE jothepro/doxygen-awesome-css
            DEPENDENCY_VERSION  "${THEME_VERSION}"
            DEPENDENCY_QUIET
        )
    endif()

    if(NOT EXISTS "${THEME_RESOURCE_PATH}")
        if(EXISTS "${THEME_RESOURCE_PATH}-src")
            file(RENAME "${THEME_RESOURCE_PATH}-src" "${THEME_RESOURCE_PATH}")
        else()
            if(NOT EXISTS "${THEME_CACHE_PATH}")
                message(WARNING "Failed to download Doxygen theme")
                return()
            endif()
            file(
                COPY "${THEME_CACHE_PATH}"
                DESTINATION "${FETCHCONTENT_BASE_DIR}"
            )
            file(
                RENAME "${FETCHCONTENT_BASE_DIR}/${THEME_VERSION}"
                "${THEME_RESOURCE_PATH}"
            )
        endif()
    endif()

endfunction()

if(CMAKE_SCRIPT_MODE_FILE AND NOT CMAKE_PARENT_LIST_FILE)
    setup_doxygen_build()
endif()
