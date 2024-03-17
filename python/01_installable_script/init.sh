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
# *       ***   Init Script for Python Installable Script Projects   ***      *
# *                               INIT LEVEL 2                                *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_EXEC_SCRIPT_NAME: The name of the executable script which will
#                       be callable after installation.


function process_files_lvl_2() {
  replace_var "EXEC_SCRIPT_NAME"  "$var_exec_script_name";
  replace_var "DOCUMENTED_MODULE" "application";
}

# Prompts the user to enter the name of the executable script.
#
# Globals:
# var_exec_script_name - The name of the executable script.
#                        Is set by this function.
#
function form_python_exec_script_name() {
  FORM_QUESTION_ID="python.script.name";
  logI "";
  logI "Specify the name of the executable script when installed.";
  logI "This is the command by which the script can be" \
       "called on the command line.";
  # shellcheck disable=SC2154
  logI "Or press enter to use the default name '${var_project_name_lower}'";
  read_user_input_text _validate_exec_script_name;
  var_exec_script_name="$USER_INPUT_ENTERED_TEXT";

  if [ -z "$var_exec_script_name" ]; then
    var_exec_script_name="$var_project_name_lower";
  fi
}


# Form questions

form_python_version;

form_python_virtenv_name;

form_python_package_name;

form_python_exec_script_name;

form_python_use_linter;

form_python_pypi_deployment;

form_docs_integration;

form_docker_integration;

# Project setup

project_init_copy;

project_init_license "py";

project_init_process;
