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
# *        ***   Functionality Test for Python Library Projects   ***         *
# *                        Using Native Code with ctypes                      *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_python_library_native_ctypes.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=("LICENSE");
  files+=(".gitignore");
  files+=(".global.sh");
  files+=("setup.sh");
  files+=("setup.py");
  files+=("pyproject.toml");
  files+=("release.sh");
  files+=("requirements.txt");
  files+=("pylintrc");
  files+=("raven/comparator.py");
  files+=("raven/string_comparator.py");
  files+=("raven/__init__.py");
  files+=("tests/__init__.py");
  files+=("tests/test_string_comparator.py");

  local not_files=();
  not_files+=("docs/mkdocs.yaml");
  not_files+=("docs/index.md");

  local dirs=();
  dirs+=("raven");

  local not_dirs=();
  not_dirs+=("package");
  not_dirs+=(".docker");
  not_dirs+=("docs");

  assert_files_exist "${files[@]}"         &&
  assert_files_not_exist "${not_files[@]}" &&
  assert_dirs_exist "${dirs[@]}"           &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
