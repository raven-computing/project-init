# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

#==================================[ TARGET ]==================================
# Application ${{VAR_PROJECT_NAME}} core libraries

set(${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE ${{VAR_ARTIFACT_BINARY_NAME}}core)

add_library(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    STATIC
    cpp/${{VAR_NAMESPACE_PATH}}/Server.cpp
    cpp/${{VAR_NAMESPACE_PATH}}/ExampleRouter.cpp
    cpp/${{VAR_NAMESPACE_PATH}}/ExampleControllerHTTP.cpp
    cpp/${{VAR_NAMESPACE_PATH}}/ExampleControllerWS.cpp
    cpp/${{VAR_NAMESPACE_PATH}}/StringProcessor.cpp
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    PRIVATE
    cpp
)

target_link_libraries(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    PUBLIC
    netcore
)

enable_compiler_warnings(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    ${${{VAR_PROJECT_NAME_UPPER}}_IGNORE_WARNINGS}
)

if(${{VAR_PROJECT_NAME_UPPER}}_USE_SANITIZERS)
    add_sanitizers(${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE})
endif()

#==================================[ TARGET ]==================================
# Application ${{VAR_PROJECT_NAME}} main executable

set(${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION ${{VAR_ARTIFACT_BINARY_NAME}})

add_executable(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION}
    cpp/Main.cpp
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION}
    PRIVATE
    cpp
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

#===================================[ TESTS ]==================================
# Application ${{VAR_PROJECT_NAME}} main tests

if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS)
    add_subdirectory(tests)
     if(${{VAR_PROJECT_NAME_UPPER}}_BUILD_TEST_COVERAGE)
        add_code_coverage(${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE})
    endif()
endif()
