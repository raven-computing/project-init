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
# *        ***   Functionality Test for C++ Desktop GUI Projects   ***        *
# *                                   Using ImGUI                             *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_cpp_desktop_imgui.properties";
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
  files+=("src/main/cpp/raven/gui/Application.h");
  files+=("src/main/cpp/raven/gui/Application.cpp");
  files+=("src/main/cpp/raven/gui/Window.h");
  files+=("src/main/cpp/raven/gui/Window.cpp");
  files+=("src/main/tests/CMakeLists.txt");
  files+=("src/main/tests/cpp/raven/gui/ApplicationTest.cpp");
  files+=("docs/Doxyfile");
  files+=("docs/page_main.md");

  local dirs=();
  dirs+=("src/main/cpp/raven");
  dirs+=("src/main/cpp/raven/gui");
  dirs+=("src/main/resources");
  dirs+=("src/main/tests/cpp/raven");
  dirs+=("src/main/tests/cpp/raven/gui");
  dirs+=("src/main/tests/resources");
  dirs+=("docs");

  local not_dirs=();
  not_dirs+=("src/main/cpp/namespace");
  not_dirs+=("src/main/tests/cpp/namespace");

  assert_files_exist "${files[@]}"        &&
  assert_dirs_exist "${dirs[@]}"          &&
  assert_dirs_not_exist "${not_dirs[@]}";
}
