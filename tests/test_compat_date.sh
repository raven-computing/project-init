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
# *           ***   Compatibility Tests for the date command   ***            *
# *                                                                           *
# #***************************************************************************#


# @CMD: date +%Y   # Checking the first two digits
function test_date_can_get_current_year() {
  local expected="20";
  local actual;
  actual=$(date +%Y);
  local exit_status=$?;
  # We only check the first two digits here
  actual="${actual::2}";
  assert_equal "$expected" "$actual" $exit_status;
  return $?;
}

function test_command() {
  test_date_can_get_current_year;
  return $?;
}

# Do not run tests when this file is sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  test_command "$@";
fi

