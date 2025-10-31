# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

#==================================[ TARGET ]==================================
# Application ${{VAR_PROJECT_NAME}} core libraries

set(${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE ${{VAR_ARTIFACT_BINARY_NAME}}core)

add_library(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    STATIC
    c/example.c
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    PRIVATE
    c
)

target_link_libraries(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    PRIVATE
    ${${{VAR_PROJECT_NAME_UPPER}}_DEPENDENCIES_LINK_TARGETS}
)

enable_compiler_warnings(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    ${${{VAR_PROJECT_NAME_UPPER}}_IGNORE_WARNINGS}
)

if(${{VAR_PROJECT_NAME_UPPER}}_SOURCE_ANALYSIS)
    enable_source_compile_checks(
        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    )
endif()

if(${{VAR_PROJECT_NAME_UPPER}}_USE_SANITIZERS)
    add_sanitizers(${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE})
endif()

#==================================[ TARGET ]==================================
# Application ${{VAR_PROJECT_NAME}} main executable

set(${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION ${{VAR_ARTIFACT_BINARY_NAME}})

add_executable(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION}
    c/main.c
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION}
    PRIVATE
    c
)

target_link_libraries(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION}
    PRIVATE
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
)

enable_compiler_warnings(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION}
    ${${{VAR_PROJECT_NAME_UPPER}}_IGNORE_WARNINGS}
)

if(${{VAR_PROJECT_NAME_UPPER}}_SOURCE_ANALYSIS)
    enable_source_compile_checks(
        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION}
    )
endif()

#===================================[ TESTS ]==================================
# Application ${{VAR_PROJECT_NAME}} main tests

if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS)
    add_subdirectory(tests)
    if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TEST_COVERAGE)
        add_code_coverage(${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE})
    endif()
endif()
