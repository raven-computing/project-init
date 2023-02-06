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
# *        ***   Functionality Test for C++ Executables Projects   ***        *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_cpp_executable.properties";
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
  files+=("src/main/cpp/Main.cpp");
  files+=("src/main/cpp/raven/mynsa/mynsb/Application.h");
  files+=("src/main/cpp/raven/mynsa/mynsb/Application.cpp");
  files+=("src/main/tests/CMakeLists.txt");
  files+=("src/main/tests/cpp/raven/mynsa/mynsb/ApplicationTest.cpp");
  files+=(".docker/controls.sh");
  files+=(".docker/Dockerfile-build");
  files+=(".docker/entrypoint.sh");

  local dirs=();
  dirs+=("src/main/cpp/raven");
  dirs+=("src/main/cpp/raven/mynsa");
  dirs+=("src/main/cpp/raven/mynsa/mynsb");
  dirs+=("src/main/resources");
  dirs+=("src/main/tests/cpp/raven");
  dirs+=("src/main/tests/cpp/raven/mynsa");
  dirs+=("src/main/tests/cpp/raven/mynsa/mynsb");
  dirs+=("src/main/tests/resources");
  dirs+=(".docker");

  local not_dirs=();
  not_dirs+=("src/main/cpp/namespace");
  not_dirs+=("src/main/tests/cpp/namespace");

  assert_files_exist "${files[@]}"        &&
  assert_dirs_exist "${dirs[@]}"          &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
