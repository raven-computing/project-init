${{VAR_COPYRIGHT_HEADER}}

#include <string.h>

#include "gtest/gtest.h"
#include "gmock/gmock.h"

#include "${{VAR_NAMESPACE_PATH}}/StringGenerator.h"

using std::string;
using ::testing::StartsWith;
using ${{VAR_NAMESPACE_COLON}}::StringGenerator;

int main(int argc, char** argv) {
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::InitGoogleMock(&argc, argv);
    return RUN_ALL_TESTS();
}

TEST(StringGeneratorTest, TestTrivial) {
    ASSERT_EQ(1, 1);
}

TEST(StringGeneratorTest, TestGenerate) {
    StringGenerator dummy;
    string val = dummy.generate();
    ASSERT_FALSE(val.empty());
    ASSERT_THAT(val, StartsWith("${{VAR_PROJECT_SLOGAN_STRING}}"));
}
