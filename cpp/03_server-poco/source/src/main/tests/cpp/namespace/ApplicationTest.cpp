${{VAR_COPYRIGHT_HEADER}}

#include "gtest/gtest.h"
#include "gmock/gmock.h"


int main(int argc, char** argv){
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::InitGoogleMock(&argc, argv);
    return RUN_ALL_TESTS();
}

TEST(ApplicationTest, TestTrivial){
    ASSERT_EQ(1, 1);
}
