# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

add_test_suite(
    TEST_SUITE_NAME        ExampleUnitTest
    TEST_SUITE_TARGET      test_example
    TEST_SUITE_SOURCE      unit/c/test_example.c
    TEST_SUITE_LINK        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
)

add_test_suite(
    TEST_SUITE_NAME        ExampleFunctionalityTest
    TEST_SUITE_TARGET      test_app
    TEST_SUITE_SOURCE      functionality/test_app.sh
    TEST_SUITE_LINK        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION}
)
