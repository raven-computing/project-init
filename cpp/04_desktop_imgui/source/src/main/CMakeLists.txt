# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

#==================================[ TARGET ]==================================
# Application ${{VAR_PROJECT_NAME}} core libraries

set(${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE ${{VAR_ARTIFACT_BINARY_NAME}}core)

# The path to the directory containing the dependencies
set(DEPENDENCIES_DIR "${CMAKE_BINARY_DIR}/_deps")

# The path to the ImGUI sources
set(LIB_IMGUI_DIR "${DEPENDENCIES_DIR}/imgui-src")

add_library(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    STATIC
    cpp/${{VAR_NAMESPACE_PATH}}/Application.cpp
    cpp/${{VAR_NAMESPACE_PATH}}/Window.cpp
    "${LIB_IMGUI_DIR}/imgui.cpp"
    "${LIB_IMGUI_DIR}/imgui_demo.cpp"
    "${LIB_IMGUI_DIR}/imgui_draw.cpp"
    "${LIB_IMGUI_DIR}/imgui_tables.cpp"
    "${LIB_IMGUI_DIR}/imgui_widgets.cpp"
    "${LIB_IMGUI_DIR}/backends/imgui_impl_glfw.cpp"
    "${LIB_IMGUI_DIR}/backends/imgui_impl_opengl3.cpp"
)

target_include_directories(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    PRIVATE
    cpp
    "${LIB_IMGUI_DIR}"
    "${LIB_IMGUI_DIR}/backends"
)

if(UNIX AND NOT APPLE)
    set(${{VAR_PROJECT_NAME_UPPER}}_PLATFORM_LINK_LIBRARIES dl GL)
elseif(WIN32)
    set(${{VAR_PROJECT_NAME_UPPER}}_PLATFORM_LINK_LIBRARIES opengl32)
else()
    message(FATAL_ERROR "Unsupported platform")
endif()

target_link_libraries(
    ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
    PUBLIC
    ${${{VAR_PROJECT_NAME_UPPER}}_PLATFORM_LINK_LIBRARIES}
    ${${{VAR_PROJECT_NAME_UPPER}}_DEPENDENCIES_LINK_TARGETS}
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
        add_code_coverage(${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION})
    endif()
endif()
