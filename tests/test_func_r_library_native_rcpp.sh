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
# *          ***   Functionality Test for R Library Projects   ***            *
# *                          Using Native Code (Rcpp)                         *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_r_library_native_rcpp.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=("LICENSE");
  files+=(".gitignore");
  files+=(".Rbuildignore");
  files+=("DESCRIPTION");
  files+=("NAMESPACE");
  files+=("R/example.R");
  files+=("R/package.R");
  files+=("src/example.cpp");
  files+=("man/addFortyTwo.Rd");
  files+=("man/addVecFortyTwoNative.Rd");
  files+=("tests/testthat.R");
  files+=("tests/testthat/test-example.R");

  local not_dirs=();
  not_dirs+=(".docker");

  assert_files_exist "${files[@]}" &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
