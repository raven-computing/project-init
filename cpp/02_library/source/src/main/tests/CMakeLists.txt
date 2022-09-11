# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

add_test_suite(
    TEST_SUITE_NAME        StringGeneratorTest
    TEST_SUITE_TARGET      test_string_generator
    TEST_SUITE_SOURCE      cpp/${{VAR_NAMESPACE_PATH}}/StringGeneratorTest.cpp
    TEST_SUITE_LINK        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
)
