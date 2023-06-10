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
# *           ***   Functionality Test for Quickstart Function   ***          *
# *                            Provided by an Addon                           *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  # test_functionality_quickstart @addon_function;
  # return $?;
  return 0;
}

function test_functionality_result() {
  local files=();
  files+=("example.sh");

  # assert_files_exist "${files[@]}";
  # return $?;
  return 0;
}
