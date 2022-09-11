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
# *           ***   Compatibility Tests for the dirname command   ***         *
# *                                                                           *
# #***************************************************************************#


# @CMD: dirname "/home/user/testing/dir/test"
function test_dirname_full_path() {
  local expected="/home/user/testing/dir";
  local dir="/home/user/testing/dir/test";
  local actual;
  actual=$(dirname "$dir");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: dirname "/home/user/testing with spaces/dir/test with spaces"
function test_dirname_path_with_spaces() {
  local expected="/home/user/testing with spaces/dir";
  local dir="/home/user/testing with spaces/dir/test with spaces";
  local actual;
  actual=$(dirname "$dir");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: dirname "/"
function test_dirname_path_root() {
  local expected="/";
  local dir="/";
  local actual;
  actual=$(dirname "$dir");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: dirname "testdir"
function test_dirname_only_one_dir() {
  local expected=".";
  local dir="testdir";
  local actual;
  actual=$(dirname "$dir");
  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_dirname_full_path        &&
  test_dirname_path_with_spaces &&
  test_dirname_path_root        &&
  test_dirname_only_one_dir;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

