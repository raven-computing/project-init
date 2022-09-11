#!/bin/bash
# Copyright (C) 2022 Raven Computing
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
# *            ***   Compatibility Tests for the cut command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: echo "TEST_A=VALUE-1" |cut -d= -f1
function test_cut_delimiter_first_item() {
  local expected="TEST_A";
  local x="TEST_A=VALUE-1";
  local actual;
  actual=$(echo "$x" |cut -d= -f1);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "TEST_B=VALUE-2" |cut -d= -f2
function test_cut_delimiter_second_item() {
  local expected="VALUE-2";
  local x="TEST_B=VALUE-2";
  local actual;
  actual=$(echo "$x" |cut -d= -f2);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "/some/file/path/with?file_name" |cut -d? -f2
function test_cut_delimiter_qstmark_second_item() {
  local expected="file_name";
  local x="/some/file/path/with?file_name";
  local actual;
  actual=$(echo "$x" |cut -d? -f2);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_cut_delimiter_first_item          &&
  test_cut_delimiter_second_item         &&
  test_cut_delimiter_qstmark_second_item;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

