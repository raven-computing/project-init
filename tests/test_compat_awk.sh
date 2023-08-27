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
# *            ***   Compatibility Tests for the awk command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: echo "TEST_A:VALUE-1" |awk -F  ":" '{print $1}'
function test_single_delimiter_first() {
  local expected="TEST_A";
  local actual;
  actual=$(echo "TEST_A:VALUE-1" |awk -F  ":" '{print $1}');
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "TEST_B:VALUE-2" |awk -F  ":" '{print $2}'
function test_single_delimiter_second() {
  local expected="VALUE-2";
  local actual;
  actual=$(echo "TEST_B:VALUE-2" |awk -F  ":" '{print $2}');
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "TEST_A=>VALUE_1" |awk -F'=>' '{print $1}'
function test_multichar_delimiter_first() {
  local expected="TEST_A";
  local actual;
  actual=$(echo "TEST_A=>VALUE_1" |awk -F'=>' '{print $1}');
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo " TEST_B => VALUE_2 " |awk -F'=>' '{print $2}'
function test_multichar_delimiter_second() {
  local expected=" VALUE_2 ";
  local actual;
  actual=$(echo " TEST_B => VALUE_2 " |awk -F'=>' '{print $2}');
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: awk 'NR!~/^('"3"')$/' "resources/awk_remove_line.txt"
function test_remove_line_from_file() {
  local line_num=3;
  local expected=$(cat << EOS
Line A
Line B
Line D
Line E
EOS
)
  local actual;
  actual="$(awk 'NR!~/^('"$line_num"')$/' "resources/awk_remove_line.txt")";
  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_replace_variable_from_file() {
  local _var_key="TEST_KEY";
  local _var_value="TEST_VALUE";
  local expected=$(cat << EOS
Line A
Line B TEST_VALUE_Data
Line C
EOS
)
  local actual;
  actual="$(export value="${_var_value}" &&              \
            awk -v key='\\${{VAR_'"${_var_key}"'}}'      \
                '{ gsub(key, ENVIRON["value"]); print; }' \
                "resources/awk_replace_var.txt")";

  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_replace_include_directive_from_file() {
  local _include_file_key="the/shared/file/to/include";
  local _include_value=$(cat << EOS
  _INCL_BEGIN_  
THE_INCLUDED_DATA with an esc slash \/ and dot \. and an & ampersand
  _INCL_END_  
EOS
)

  _include_value="${_include_value//&/\\&}";

  local expected=$(cat << EOS
Line A
Line B
Line C
  _INCL_BEGIN_  
THE_INCLUDED_DATA with an esc slash \/ and dot \. and an & ampersand
  _INCL_END_  
Line D
Line E
EOS
)
  local actual;
  actual=$(export value="${_include_value}" &&                  \
           awk -v key='\\${{INCLUDE:'"${_include_file_key}"'}}' \
                '{ gsub(key, ENVIRON["value"]); print; }'       \
                "resources/awk_replace_include_directive.txt");

  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_single_delimiter_first              &&
  test_single_delimiter_second             &&
  test_multichar_delimiter_first           &&
  test_multichar_delimiter_second          &&
  test_remove_line_from_file               &&
  test_replace_variable_from_file          &&
  test_replace_include_directive_from_file;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi
