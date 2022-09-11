# Copyright (C) 2022 Raven Computing

add_test_suite(
    TEST_SUITE_NAME        NetTest
    TEST_SUITE_TARGET      test_net
    TEST_SUITE_SOURCE      cpp/raven/net/NetTest.cpp
    TEST_SUITE_LINK        ${${{VAR_PROJECT_NAME_UPPER}}_TARGET_NET_CORE}
)
