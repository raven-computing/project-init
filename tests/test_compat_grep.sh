#!/bin/bash
# Copyright (C) 2023 Raven Computing
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# #***************************************************************************#
# *                                                                           *
# *           ***   Compatibility Tests for the grep command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: grep -o '\${{VAR_[0-9A-Z_]\+}}' "resources/grep_one_variable.txt"
function test_grep_file_with_one_variable() {
  local expected="\${{VAR_TEST_123_KEY}}";
  local actual;
  actual=$(grep -o '\${{VAR_[0-9A-Z_]\+}}' "resources/grep_one_variable.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: grep -o '\${{VAR_[0-9A-Z_]\+}}' "resources/grep_two_variables.txt"
function test_grep_file_with_two_variables() {
  local expected=$(cat << EOS
\${{VAR_TEST_123_KEY}}
\${{VAR_TEST_123_KEY}}
EOS
)
  local actual;
  actual=$(grep -o '\${{VAR_[0-9A-Z_]\+}}' "resources/grep_two_variables.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: grep -o '\${{VAR_[0-9A-Z_]\+}}' "resources/grep_three_variables.txt"
function test_grep_file_with_three_variables() {
  local expected=$(cat << EOS
\${{VAR_TEST_123_KEY}}
\${{VAR_TEST_123_KEY}}
\${{VAR_TEST_123_KEY}}
EOS
)
  local actual;
  actual=$(grep -o '\${{VAR_[0-9A-Z_]\+}}' "resources/grep_three_variables.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: grep -n '\${{VAR_TEST_123_KEY}}' "resources/grep_one_variable.txt"
function test_grep_file_line_number_with_one_variable() {
  local expected="3:Line C \${{VAR_TEST_123_KEY}}_Data";
  local var_to_find="TEST_123_KEY";
  local actual;
  actual=$(grep -n "\${{VAR_${var_to_find}}}" "resources/grep_one_variable.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: grep -n '\${{VAR_TEST_123_KEY}}' "resources/grep_two_variables.txt"
function test_grep_file_line_numbers_with_two_variables() {
  local expected=$(cat << EOS
3:Line C \${{VAR_TEST_123_KEY}}_Data
5:\${{VAR_TEST_123_KEY}} VAR_SHOULD_BE_IGNORED
EOS
)
  local var_to_find="TEST_123_KEY";
  local actual;
  actual=$(grep -n "\${{VAR_${var_to_find}}}" "resources/grep_two_variables.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: grep -n '\${{VAR_TEST_123_KEY}}' "resources/grep_three_variables.txt"
function test_grep_file_line_numbers_with_three_variables() {
  local expected=$(cat << EOS
1:\${{VAR_TEST_123_KEY}}
4:Line C \${{VAR_TEST_123_KEY}}_Data
8:\${{VAR_TEST_123_KEY}}
EOS
)
  local var_to_find="TEST_123_KEY";
  local actual;
  actual=$(grep -n "\${{VAR_${var_to_find}}}" "resources/grep_three_variables.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: cat resources/grep_line_first_printable_char.txt |grep -n -m 1 "[[:print:]]"
function test_grep_input_first_line_with_printable_char() {
  local expected="6:Line A";
  local actual;
  actual=$(cat resources/grep_line_first_printable_char.txt |grep -n -m 1 "[[:print:]]");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: grep --recursive --line-number --regexp='^${{INCLUDE:.*}}$' "resources/grep"
function test_grep_find_all_files_with_include_directives() {
  local expected=$(cat << EOS
resources/grep/should_be_found1.txt:5:\${{INCLUDE:the/shared/file/to/include}}
resources/grep/should_be_found2.txt:7:\${{INCLUDE:some/other/file/to/include}}
resources/grep/should_be_found3.txt:1:\${{INCLUDE:and/a/different/file/also.txt}}
EOS
)
  local actual;
  actual=$(grep --recursive                  \
                --line-number                \
                --regexp='^${{INCLUDE:.*}}$' \
                "resources/grep");

  # Sort output of grep
  actual=$(echo "$actual" |sort);

  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_grep_file_with_one_variable                  &&
  test_grep_file_with_two_variables                 &&
  test_grep_file_with_three_variables               &&
  test_grep_file_line_number_with_one_variable      &&
  test_grep_file_line_numbers_with_two_variables    &&
  test_grep_file_line_numbers_with_three_variables  &&
  test_grep_input_first_line_with_printable_char    &&
  test_grep_find_all_files_with_include_directives;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

