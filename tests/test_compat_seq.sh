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
# *            ***   Compatibility Tests for the seq command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: seq 1 15
function test_seq_output() {
  local expected="";
  expected=$(cat << EOS
1
2
3
4
5
6
7
8
9
10
11
12
13
14
15
EOS
)
  local i_max=15;
  local actual;
  actual=$(seq 1 $i_max);
  assert_equal "$expected" "$actual" $?;
  return $?;
}

# @CMD: for i in $(seq 0 15); do actual="${actual} $i"; done
function test_seq_in_for_loop() {
  local expected=" 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15";
  local i_max=15;
  local i;
  local actual="";
  for i in $(seq 0 $i_max); do
    actual="${actual} $i";
  done
  assert_equal "$expected" "$actual";
  return $?;
}

function test_command() {
  test_seq_output        &&
  test_seq_in_for_loop;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

