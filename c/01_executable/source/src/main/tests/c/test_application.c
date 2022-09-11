${{VAR_COPYRIGHT_HEADER}}

#include "unity.h"

#include "application.h"


void setUp(){ }

void tearDown(){ }

void testTrivial(){
    TEST_ASSERT_EQUAL(1, 1);
}

void testApplicationGetFortyTwo(){
    TEST_ASSERT_EQUAL(42, getFortyTwo());
}

int main(void){
    UNITY_BEGIN();
    RUN_TEST(testTrivial);
    RUN_TEST(testApplicationGetFortyTwo);
    return UNITY_END();
}
