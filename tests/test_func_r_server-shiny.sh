#!/bin/bash
# Copyright (C) 2022 Raven Computing
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
# *           ***   Functionality Test for R Shiny Projects   ***             *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_r_server-shiny.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=("LICENSE");
  files+=("app.R");
  files+=("main.R");
  files+=("R/module.R");
  files+=("R/server.R");
  files+=("R/ui.R");
  files+=("www/normal_distribution.png");

  assert_files_exist "${files[@]}";
  return $?;
}
