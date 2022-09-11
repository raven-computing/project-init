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
# *           ***   Compatibility Tests for the xargs command   ***           *
# *                                                                           *
# #***************************************************************************#


# @CMD: echo "   This is a test string" |xargs
function test_xargs_trim_whitespace_left() {
  local expected="This is a test string";
  local actual;
  actual=$(echo "   This is a test string" |xargs);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "This is a test string   " |xargs
function test_xargs_trim_whitespace_right() {
  local expected="This is a test string";
  local actual;
  actual=$(echo "This is a test string   " |xargs);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "   This is a test string   " |xargs
function test_xargs_trim_whitespace_both_sides() {
  local expected="This is a test string";
  local actual;
  actual=$(echo "   This is a test string   " |xargs);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: echo "This is a test string" |xargs
function test_xargs_nothing_to_trim() {
  local expected="This is a test string";
  local actual;
  actual=$(echo "This is a test string" |xargs);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_xargs_trim_whitespace_left       &&
  test_xargs_trim_whitespace_right      &&
  test_xargs_trim_whitespace_both_sides &&
  test_xargs_nothing_to_trim;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

