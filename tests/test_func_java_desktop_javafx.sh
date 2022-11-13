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
# *           ***   Functionality Test for Java Desktop GUI    ***            *
# *                    Application Projects Using JavaFX                      *
# *                                                                           *
# #***************************************************************************#


function test_functionality() {
  test_functionality_with "test_java_desktop_javafx.properties";
  return $?;
}

function test_functionality_result() {
  local files=();
  files+=("README.md");
  files+=("LICENSE");
  files+=(".gitignore");
  files+=("pom.xml");
  files+=("src/main/java/raven/Main.java");
  files+=("src/main/java/raven/Controller.java");
  files+=("src/main/java/module-info.java");
  files+=("src/main/resources/css/styles.css");
  files+=("src/main/resources/layout/Scene.fxml");

  local dirs=();
  dirs+=("src/main/java/raven");
  dirs+=("src/main/resources/css");
  dirs+=("src/main/resources/layout");

  local not_dirs=();
  not_dirs+=("src/main/java/namespace");

  assert_files_exist "${files[@]}"         &&
  assert_dirs_exist "${dirs[@]}"           &&
  assert_dirs_not_exist "${not_dirs[@]}";
  return $?;
}
