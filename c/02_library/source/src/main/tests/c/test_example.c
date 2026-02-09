${{VAR_COPYRIGHT_HEADER}}

#include "unity.h"

#include "example.h"

void setUp() { }

void tearDown() { }

void testAddFortyTwoWithPositiveArg() {
    TEST_ASSERT_EQUAL_INT(47, addFortyTwo(5));
}

void testAddFortyTwoWithNegativeArg() {
    TEST_ASSERT_EQUAL_INT(-2, addFortyTwo(-44));
}

void testAddFortyTwoWithZeroArg() {
    TEST_ASSERT_EQUAL_INT(42, addFortyTwo(0));
}

void testGetText() {
    TEST_ASSERT_EQUAL_STRING("${{VAR_PROJECT_SLOGAN_STRING}}\n", getText());
}

int main(void) {
    UNITY_BEGIN();
    RUN_TEST(testAddFortyTwoWithPositiveArg);
    RUN_TEST(testAddFortyTwoWithNegativeArg);
    RUN_TEST(testAddFortyTwoWithZeroArg);
    RUN_TEST(testGetText);
    return UNITY_END();
}
