# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

include(GenerateExportHeader)

#==================================[ TARGET ]==================================
# Library ${{VAR_PROJECT_NAME}}

set(${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN
    ${{VAR_ARTIFACT_BINARY_NAME}}
    CACHE
    STRING
    "Target name for the ${{VAR_PROJECT_NAME}} library"
)

set(${{VAR_PROJECT_NAME_UPPER}}_C_STANDARD ${{VAR_C_VERSION}})

if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_SHARED_LIBS)
    set(${{VAR_PROJECT_NAME_UPPER}}_MAIN_LIB_TYPE SHARED)
else()
    set(${{VAR_PROJECT_NAME_UPPER}}_MAIN_LIB_TYPE STATIC)
endif()

set(${{VAR_PROJECT_NAME_UPPER}}_GENERATED_HEADERS ${CMAKE_BINARY_DIR}/headers)

set(${{VAR_PROJECT_NAME_UPPER}}_EXPORT_HEADER
    "${${{VAR_PROJECT_NAME_UPPER}}_GENERATED_HEADERS}/${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}_export.h"
)

add_library(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    ${${{VAR_PROJECT_NAME_UPPER}}_MAIN_LIB_TYPE}
    c/example.c
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<BUILD_INTERFACE:${${{VAR_PROJECT_NAME_UPPER}}_GENERATED_HEADERS}>"
    PRIVATE
    c
)

set_target_properties(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    PROPERTIES
    C_STANDARD ${${{VAR_PROJECT_NAME_UPPER}}_C_STANDARD}
    C_STANDARD_REQUIRED True
    C_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN True
)

generate_export_header(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    EXPORT_FILE_NAME "${${{VAR_PROJECT_NAME_UPPER}}_EXPORT_HEADER}"
)

#===================================[ TESTS ]==================================
# Library ${{VAR_PROJECT_NAME}} tests

if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS)
    add_subdirectory(tests)
endif()
