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
# *           ***   Compatibility Tests for the head command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: head -n 10 resources/head_lines.txt
function test_head_fewer_lines_in_file() {
  local expected="";
  expected=$(cat << EOS
Line A
Line B
Line C
Line D
Line E
Line F
Line G
EOS
)
  local actual;
  actual=$(head -n 10 resources/head_lines.txt);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: head -n 3 resources/head_lines.txt
function test_head_fewer_lines_in_argument() {
  local expected="";
  expected=$(cat << EOS
Line A
Line B
Line C
EOS
)
  local actual;
  actual=$(head -n 3 resources/head_lines.txt);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

function test_command() {
  test_head_fewer_lines_in_file      &&
  test_head_fewer_lines_in_argument;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

