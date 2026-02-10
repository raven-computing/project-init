${{VAR_COPYRIGHT_HEADER}}

#include "gtest/gtest.h"
#include "gmock/gmock.h"

#include "${{VAR_NAMESPACE_PATH}}/Application.h"

using ${{VAR_NAMESPACE_COLON}}::Application;

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::InitGoogleMock(&argc, argv);
    return RUN_ALL_TESTS();
}

TEST(ApplicationTest, TestTrivial) {
    ASSERT_EQ(1, 1);
}

TEST(ApplicationTest, TestGetValue) {
    ASSERT_EQ("${{VAR_PROJECT_SLOGAN_STRING}}", Application::getTitle());
}
