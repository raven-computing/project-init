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
# *           Using Native Code with Cython Compiled C Extensions             *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_python_library_native_cython.properties";
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
  files+=("requirements.txt");
  files+=("pylintrc");
  files+=("pyproject.toml");
  files+=("MANIFEST.in");
  files+=("raven/finder.py");
  files+=("raven/index_finder.py");
  files+=("raven/_index_finder.pyx");
  files+=("raven/__init__.py");
  files+=("tests/__init__.py");
  files+=("tests/test_index_finder.py");
  files+=(".docker/controls.sh");
  files+=(".docker/Dockerfile-build");
  files+=(".docker/entrypoint.sh");
  files+=("docs/mkdocs.yaml");
  files+=("docs/index.md");

  local not_files=();
  not_files+=("deploy.sh");

  local dirs=();
  dirs+=("raven");
  dirs+=(".docker");
  dirs+=("docs");

  local not_dirs=();
  not_dirs+=("package");

  assert_files_exist "${files[@]}"          &&
  assert_files_not_exist "${not_files[@]}"  &&
  assert_dirs_exist "${dirs[@]}"            &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
