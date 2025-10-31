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

set(${{VAR_PROJECT_NAME_UPPER}}_CXX_STANDARD ${{VAR_CPP_VERSION}})

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
    cpp/${{VAR_NAMESPACE_PATH}}/StringGenerator.cpp
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    "$<BUILD_INTERFACE:${${{VAR_PROJECT_NAME_UPPER}}_GENERATED_HEADERS}>"
    PRIVATE
    cpp
)

target_link_libraries(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    PRIVATE
    ${${{VAR_PROJECT_NAME_UPPER}}_DEPENDENCIES_LINK_TARGETS}
)

set_target_properties(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    PROPERTIES
    CXX_STANDARD ${${{VAR_PROJECT_NAME_UPPER}}_CXX_STANDARD}
    CXX_STANDARD_REQUIRED True
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN True
)

generate_export_header(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    EXPORT_FILE_NAME "${${{VAR_PROJECT_NAME_UPPER}}_EXPORT_HEADER}"
)

enable_compiler_warnings(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    ${${{VAR_PROJECT_NAME_UPPER}}_IGNORE_WARNINGS}
)

if(${{VAR_PROJECT_NAME_UPPER}}_USE_SANITIZERS)
    add_sanitizers(${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN})
endif()

#===================================[ TESTS ]==================================
# Library ${{VAR_PROJECT_NAME}} tests

if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS)
    add_subdirectory(tests)
    if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TEST_COVERAGE)
        add_code_coverage(${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN})
    endif()
endif()
