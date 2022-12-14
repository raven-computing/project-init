# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

#==================================[ TARGET ]==================================
# Library ${{VAR_PROJECT_NAME}}

set(${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN ${{VAR_ARTIFACT_BINARY_NAME}})

# Specify the C standard
set(${{VAR_PROJECT_NAME_UPPER}}_C_STANDARD ${{VAR_C_VERSION}})

if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_SHARED_LIBS)
    set(${{VAR_PROJECT_NAME_UPPER}}_MAIN_LIB_TYPE SHARED)
else()
    set(${{VAR_PROJECT_NAME_UPPER}}_MAIN_LIB_TYPE STATIC)
endif()

add_library(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    ${${{VAR_PROJECT_NAME_UPPER}}_MAIN_LIB_TYPE}
    c/example.c
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    PUBLIC
    "$<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>"
    PRIVATE
    c
)

set_target_properties(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
    PROPERTIES
    C_STANDARD ${${{VAR_PROJECT_NAME_UPPER}}_C_STANDARD}
    C_STANDARD_REQUIRED True
)

#===================================[ TESTS ]==================================
# Library ${{VAR_PROJECT_NAME}} tests

if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS)
    add_subdirectory(tests)
endif()
