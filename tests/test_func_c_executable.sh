#!/bin/bash
# Copyright (C) 2025 Raven Computing
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
# *         ***   Functionality Test for C Executables Projects   ***         *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_c_executable.properties";
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
  files+=("src/main/c/main.c");
  files+=("src/main/c/example.h");
  files+=("src/main/c/example.c");
  files+=("src/main/tests/CMakeLists.txt");
  files+=("src/main/tests/c/test_example.c");
  files+=(".docker/controls.sh");
  files+=(".docker/Dockerfile-build");
  files+=(".docker/entrypoint.sh");
  files+=("docs/Doxyfile");
  files+=("docs/page_main.md");

  local dirs=();
  dirs+=("src/main/resources");
  dirs+=("src/main/tests/resources");
  dirs+=(".docker");
  dirs+=("docs");

  assert_files_exist "${files[@]}"  &&
  assert_dirs_exist "${dirs[@]}";
  return $?;
}
