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
# *            ***   Compatibility Tests for the sed command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: sed -n "1p" < "resources/sed_read_one_line.txt"
function test_sed_read_first_line() {
  local expected="Line A";
  local line_num=1;
  local actual;
  actual=$(sed -n "${line_num}p" < "resources/sed_read_one_line.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: sed -n "3p" < "resources/sed_read_one_line.txt"
function test_sed_read_middle_line() {
  local expected="Line C";
  local line_num=3;
  local actual;
  actual=$(sed -n "${line_num}p" < "resources/sed_read_one_line.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: sed -n "5p" < "resources/sed_read_one_line.txt"
function test_sed_read_last_line() {
  local expected="Line E";
  local line_num=5;
  local actual;
  actual=$(sed -n "${line_num}p" < "resources/sed_read_one_line.txt");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_sed_read_first_line   &&
  test_sed_read_middle_line  &&
  test_sed_read_last_line;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

