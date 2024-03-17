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
# *       ***   Functionality Test for Java Executables Projects   ***        *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_java_executable.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=(".gitignore");
  files+=("pom.xml");
  files+=("src/main/java/raven/mynsa/mynsb/Main.java");
  files+=("src/test/java/raven/mynsa/mynsb/MainTest.java");
  files+=("src/test/java/raven/mynsa/mynsb/MainTests.java");
  files+=("docs/mkdocs.yaml");
  files+=("docs/index.md");

  local not_files=();
  not_files+=("LICENSE");

  local dirs=();
  dirs+=("src/main/java/raven");
  dirs+=("src/main/java/raven/mynsa");
  dirs+=("src/main/java/raven/mynsa/mynsb");
  dirs+=("src/test/java/raven");
  dirs+=("src/test/java/raven/mynsa");
  dirs+=("src/test/java/raven/mynsa/mynsb");
  dirs+=("docs");

  local not_dirs=();
  not_dirs+=("src/main/java/namespace");
  not_dirs+=("src/test/java/namespace");

  assert_files_exist "${files[@]}"         &&
  assert_files_not_exist "${not_files[@]}" &&
  assert_dirs_exist "${dirs[@]}"           &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
