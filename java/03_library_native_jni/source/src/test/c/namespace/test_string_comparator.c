${{VAR_COPYRIGHT_HEADER}}

#include "unity.h"

#include "${{VAR_NAMESPACE_PATH}}/string_comparator.h"


void setUp(){ }

void tearDown(){ }

void testTrivial(){
    TEST_ASSERT_EQUAL(1, 1);
}

void testCompareEqual(){
    int result = compare_strings("TEST-1", "TEST-1");
    TEST_ASSERT_EQUAL(0, result);
}

int main(void){
    UNITY_BEGIN();
    RUN_TEST(testTrivial);
    RUN_TEST(testCompareEqual);
    return UNITY_END();
}
