# Copyright (C) ${{VAR_COPYRIGHT_YEAR}} ${{VAR_COPYRIGHT_HOLDER}}

add_test_suite(
    TEST_SUITE_NAME        ApplicationTest
    TEST_SUITE_TARGET      test_application
    TEST_SUITE_SOURCE      c/test_application.c
    TEST_SUITE_LINK        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_APPLICATION_CORE}
)
