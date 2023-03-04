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
# *           ***   Functionality Test for C Library Projects   ***           *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_c_library.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=("LICENSE");
  files+=(".gitignore");
  files+=("CMakeLists.txt");
  files+=("Dependencies.cmake");
  files+=("cmake/DependencyUtil.cmake");
  files+=("src/main/CMakeLists.txt");
  files+=("src/main/c/example.c");
  files+=("src/main/include/example.h");
  files+=("src/main/tests/CMakeLists.txt");
  files+=("src/main/tests/c/test_example.c");

  local dirs=();
  dirs+=("src/main/resources");
  dirs+=("src/main/tests/resources");

  local not_dirs=();
  not_dirs+=(".docker");

  assert_files_exist "${files[@]}"  &&
  assert_dirs_exist "${dirs[@]}"    &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
