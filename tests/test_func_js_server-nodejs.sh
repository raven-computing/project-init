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
# *     ***   Functionality Test for JavaScript Server Application   ***      *
# *                         Projects Using Node.js                            *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_js_server-nodejs.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=("LICENSE");
  files+=(".gitignore");
  files+=("package.json");
  files+=("app.js");
  files+=("public/index.html");
  files+=("test.sh");
  files+=(".docker/controls.sh");
  files+=(".docker/Dockerfile-run");
  files+=(".docker/entrypoint.sh");

  local dirs=();
  dirs+=("public");
  dirs+=(".docker");

  assert_files_exist "${files[@]}"  &&
  assert_dirs_exist "${dirs[@]}";
  return $?;
}
