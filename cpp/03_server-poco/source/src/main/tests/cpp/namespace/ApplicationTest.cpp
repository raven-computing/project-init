${{VAR_COPYRIGHT_HEADER}}

#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "${{VAR_NAMESPACE_PATH}}/StringProcessor.h"

using ${{VAR_NAMESPACE_COLON}}::StringProcessor;

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::InitGoogleMock(&argc, argv);
    return RUN_ALL_TESTS();
}

TEST(ApplicationTest, TestTrivial) {
    ASSERT_EQ(1, 1);
}

TEST(ApplicationTest, TestReverseString) {
    StringProcessor processor("Hello");
    ASSERT_EQ(processor.reverse(), "olleH");
}
