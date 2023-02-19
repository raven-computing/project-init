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
# *       ***   Functionality Test for Java JNI Library Projects   ***        *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_java_library_native_jni.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=("LICENSE");
  files+=(".gitignore");
  files+=("pom.xml");
  files+=("CMakeLists.txt");
  files+=("Dependencies.cmake");
  files+=("cmake/DependencyUtil.cmake");
  files+=("src/main/CMakeLists.txt");
  files+=("src/main/java/raven/mynsa/mynsb/Comparator.java");
  files+=("src/main/java/raven/mynsa/mynsb/StringComparator.java");
  files+=("src/test/java/raven/mynsa/mynsb/StringComparatorTest.java");
  files+=("src/test/java/raven/mynsa/mynsb/LibTests.java");
  files+=("src/main/cpp/jni/raven_mynsa_mynsb_StringComparator.cpp");
  files+=("src/main/include/jni/raven_mynsa_mynsb_StringComparator.h");
  files+=("src/main/cpp/raven/mynsa/mynsb/StringComparator.cpp");
  files+=("src/main/include/raven/mynsa/mynsb/StringComparator.h");
  files+=("src/test/CMakeLists.txt");
  files+=("src/test/cpp/raven/mynsa/mynsb/StringComparatorTest.cpp");

  local not_files=();
  not_files+=("cmake/ConfigUnity.cmake");
  not_files+=("cmake/c_DependencyUtil.cmake");
  not_files+=("cmake/c_TestUtil.cmake");
  not_files+=("src/main/include/raven/mynsa/mynsb/string_comparator.h");

  local dirs=();
  dirs+=("src/main/java/raven");
  dirs+=("src/main/java/raven/mynsa");
  dirs+=("src/main/java/raven/mynsa/mynsb");
  dirs+=("src/main/cpp/raven");
  dirs+=("src/main/cpp/raven/mynsa");
  dirs+=("src/main/cpp/raven/mynsa/mynsb");
  dirs+=("src/test/java/raven");
  dirs+=("src/test/java/raven/mynsa");
  dirs+=("src/test/java/raven/mynsa/mynsb");
  dirs+=("src/test/cpp/raven");
  dirs+=("src/test/cpp/raven/mynsa");
  dirs+=("src/test/cpp/raven/mynsa/mynsb");

  local not_dirs=();
  not_dirs+=("src/main/java/namespace");
  not_dirs+=("src/main/cpp/namespace");
  not_dirs+=("src/main/include/namespace");
  not_dirs+=("src/test/java/namespace");
  not_dirs+=("src/test/cpp/namespace");
  not_dirs+=("src/main/c");
  not_dirs+=("src/test/c");

  assert_files_exist "${files[@]}"         &&
  assert_files_not_exist "${not_files[@]}" &&
  assert_dirs_exist "${dirs[@]}"           &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
