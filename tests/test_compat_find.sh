#!/bin/bash
# Copyright (C) 2024 Raven Computing
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
# *           ***   Compatibility Tests for the find command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: find resources/find/ -type f \( -name should_be_found1.txt \)
function test_find_one_file() {
  local expected="resources/find/should_be_found1.txt";
  local dir="resources/find";
  local file_args=();
  local f="should_be_found1.txt";
  file_args+=(-name "$f");
  local actual;
  actual=$(find $dir/ -type f \( "${file_args[@]}" \));
  local exit_status=$?;
  assert_equal "$expected" "$actual" $exit_status;
  return $?;
}

# @CMD: find resources/find/ -type f \( "${file_args[@]}" \)
function test_find_two_files() {
  local expected="";
  expected=$(cat << EOS
resources/find/should_be_found1.txt
resources/find/should_be_found2.txt
EOS
)
  local dir="resources/find";
  local file_args=();
  file_args+=(-name "should_be_found1.txt");
  file_args+=( -o -name "should_be_found2.txt");
  local actual;
  actual=$(find $dir/ -type f \( "${file_args[@]}" \));
  local exit_status=$?;
  # Sort output of find
  actual=$(echo "$actual" |sort);
  assert_equal "$expected" "$actual" $exit_status;
  return $?;
}

# @CMD: find resources/find/ -type f \( "${file_args[@]}" \)
function test_find_all_files_by_name() {
  local expected="";
  expected=$(cat << EOS
resources/find/should_be_found1.txt
resources/find/should_be_found2.txt
resources/find/should_be_found3.txt
EOS
)
  local dir="resources/find";
  local file_args=();
  file_args+=(-name "should_be_found1.txt");
  file_args+=( -o -name "should_be_found2.txt");
  file_args+=( -o -name "should_be_found3.txt");
  local actual;
  actual=$(find $dir/ -type f \( "${file_args[@]}" \));
  local exit_status=$?;
  # Sort output of find
  actual=$(echo "$actual" |sort);
  assert_equal "$expected" "$actual" $exit_status;
  return $?;
}

# @CMD: find resources/find/ -type f
function test_find_all_files() {
  local expected="";
  expected=$(cat << EOS
resources/find/should_be_found1.txt
resources/find/should_be_found2.txt
resources/find/should_be_found3.txt
EOS
)
  local dir="resources/find";
  local actual;
  actual=$(find $dir/ -type f);
  local exit_status=$?;
  # Sort output of find
  actual=$(echo "$actual" |sort);
  assert_equal "$expected" "$actual" $exit_status;
  return $?;
}

function test_command() {
  test_find_one_file          &&
  test_find_two_files         &&
  test_find_all_files_by_name &&
  test_find_all_files;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

