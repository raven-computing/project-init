# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

add_test_suite(
    TEST_SUITE_NAME        StringComparatorTest
    TEST_SUITE_TARGET      test_string_comparator
    TEST_SUITE_SOURCE      cpp/${{VAR_NAMESPACE_PATH}}/StringComparatorTest.cpp
    TEST_SUITE_LINK        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_JNI_MAIN}
)
