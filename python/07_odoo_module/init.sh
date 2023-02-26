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
# *          ***   Init Script for Python Odoo Module Projects   ***          *
# *                               INIT LEVEL 2                                *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_ODOO_MODULE_NAME: The technical name for the Odoo module.


function process_files_lvl_2() {
  replace_var "ODOO_MODULE_NAME" "$var_odoo_module_name";
}

# Prompts the user to enter the name of the Odoo module.
#
# The provided answer can be queried in source template files via the
# VAR_ODOO_MODULE_NAME substitution variable.
# The associated shell global variable is set by this function.
#
# Globals:
# var_odoo_module_name - The technical name for the Odoo module.
#                        Is set by this function.
#
function form_python_odoo_module_name() {
  FORM_QUESTION_ID="python.odoo.module.name";
  logI "";
  logI "Enter the name for the Odoo module:";

  read_user_input_text;
  local _odoo_module_name="$USER_INPUT_ENTERED_TEXT";

  # Validate
  if [ -z "${_odoo_module_name}" ]; then
    logI "";
    logI "No module name specified. Using default name 'my_module'";
    _odoo_module_name="my_module";
  else
    # Check for expected pattern
    local re="^[a-z][a-z_]*[a-z]*$";
    if ! [[ ${_odoo_module_name} =~ $re ]]; then
      logE "Invalid input";
      failure "The entered module name contains invalid characters" \
              "Only lower-case a-z and '_' characters are allowed";
    fi
  fi
  var_odoo_module_name="${_odoo_module_name}";
}

# Form questions

form_python_version;

form_python_virtenv_name;

form_python_odoo_module_name

# Project setup

project_init_copy;

project_init_license "py" "xml";

project_init_process;
