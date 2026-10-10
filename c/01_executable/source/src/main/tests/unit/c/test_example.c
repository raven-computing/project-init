${{VAR_COPYRIGHT_HEADER}}

#include "unity.h"

#include "example.h"

void setUp(void) { }

void tearDown(void) { }

void testTrivial(void) {
    TEST_ASSERT_EQUAL(1, 1);
}

void testApplicationGetFortyTwo(void) {
    TEST_ASSERT_EQUAL(42, getFortyTwo());
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(testTrivial);
    RUN_TEST(testApplicationGetFortyTwo);
    return UNITY_END();
}
