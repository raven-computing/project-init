# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

add_test_suite(
    TEST_SUITE_NAME        ExampleTest
    TEST_SUITE_TARGET      test_example
    TEST_SUITE_SOURCE      c/test_example.c
    TEST_SUITE_LINK        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_LIB_MAIN}
)

set_target_properties(
    test_example
    PROPERTIES
    C_STANDARD ${${{VAR_PROJECT_NAME_UPPER}}_C_STANDARD}
    C_STANDARD_REQUIRED True
)
