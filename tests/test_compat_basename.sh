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
# *          ***   Compatibility Tests for the basename command   ***         *
# *                                                                           *
# #***************************************************************************#


# @CMD: basename "/home/user/testing/dir/test"
function test_basename_full_path() {
  local expected="test";
  local dir="/home/user/testing/dir/test";
  local actual;
  actual=$(basename "$dir");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: basename "/home/user/testing with spaces/dir/test with spaces"
function test_basename_path_with_spaces() {
  local expected="test with spaces";
  local dir="/home/user/testing with spaces/dir/test with spaces";
  local actual;
  actual=$(basename "$dir");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: basename "/"
function test_basename_path_root() {
  local expected="/";
  local dir="/";
  local actual;
  actual=$(basename "$dir");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: basename "testdir"
function test_basename_only_one_dir() {
  local expected="testdir";
  local dir="testdir";
  local actual;
  actual=$(basename "$dir");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_basename_full_path        &&
  test_basename_path_with_spaces &&
  test_basename_path_root        &&
  test_basename_only_one_dir;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi
