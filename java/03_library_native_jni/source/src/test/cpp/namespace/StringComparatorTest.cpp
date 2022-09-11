${{VAR_COPYRIGHT_HEADER}}

#include "gtest/gtest.h"
#include "gmock/gmock.h"

#include "${{VAR_NAMESPACE_PATH}}/StringComparator.h"


using std::string;
using ${{VAR_NAMESPACE_COLON}}::StringComparator;


int main(int argc, char** argv){
    ::testing::InitGoogleTest(&argc, argv);
    ::testing::InitGoogleMock(&argc, argv);
    return RUN_ALL_TESTS();
}

TEST(StringComparatorTest, TestTrivial){
    ASSERT_EQ(1, 1);
}

TEST(StringComparatorTest, TestCompareEqual){
    StringComparator dummy;
    int result = dummy.compare("TEST-1", "TEST-1");
    ASSERT_EQ(result, 0);
}
