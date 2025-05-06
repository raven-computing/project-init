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
# *          ***   Init Script for Python Odoo Module Projects   ***          *
# *                               INIT LEVEL 2                                *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_ODOO_MODULE_NAME: The technical name for the Odoo module.
# VAR_INIT_IMPORT_CONTROLLERS: The import statement for controllers.
# VAR_INIT_IMPORT_MODELS: The import statement for models.
# VAR_INIT_IMPORT_WIZARD: The import statement for wizards.
# VAR_MANIFEST_SECURITY_DECL: The manifest data declaration for security files.
# VAR_MANIFEST_VIEWS_DECL: The manifest data declaration for views.
# VAR_MANIFEST_WIZARD_DECL: The manifest data declaration for wizard views.


function process_files_lvl_2() {
  if [ -n "$var_odoo_module_name" ]; then
    # Rename module according to provided name and apply
    # customisations to module structure first, then afterwards
    # substitution variable replacement so that file cache only
    # needs to be updated once
    if directory_exists "module"; then
      move_file "module" "$var_odoo_module_name";
      # Odoo web controller
      if [[ $var_odoo_create_controller == true ]]; then
        move_file "${var_odoo_module_name}/controllers/module.py" \
                  "${var_odoo_module_name}/controllers/${var_odoo_module_name}.py";
      else
        remove_file "${var_odoo_module_name}/controllers";
      fi

      # Odoo model
      if [[ $var_odoo_create_model == false ]]; then
        remove_file "${var_odoo_module_name}/models";
        remove_file "${var_odoo_module_name}/security";
      else
        if file_exists "${var_odoo_module_name}/security/module_groups.xml"; then
          move_file "${var_odoo_module_name}/security/module_groups.xml" \
                    "${var_odoo_module_name}/security/${var_odoo_module_name}_groups.xml";
        fi
      fi

      # Odoo model views
      if [[ $var_odoo_create_model_views == false ]]; then
        remove_file "${var_odoo_module_name}/views";
      fi

      # Odoo wizard
      if [[ $var_odoo_create_wizard == false ]]; then
        remove_file "${var_odoo_module_name}/wizard";
      fi

      # Update file cache
      find_all_files;
    fi
  fi

  if [[ $var_odoo_create_controller == true ]]; then
    replace_var "INIT_IMPORT_CONTROLLERS";
  else
    replace_var "INIT_IMPORT_CONTROLLERS" "";
  fi
  if [[ $var_odoo_create_model == true ]]; then
    replace_var "INIT_IMPORT_MODELS";
    replace_var "MANIFEST_SECURITY_DECL";
  else
    replace_var "INIT_IMPORT_MODELS"     "";
    replace_var "MANIFEST_SECURITY_DECL" "";
  fi
  if [[ $var_odoo_create_model_views == true ]]; then
    replace_var "MANIFEST_VIEWS_DECL";
  else
    replace_var "MANIFEST_VIEWS_DECL" "";
  fi
  if [[ $var_odoo_create_wizard == true ]]; then
    replace_var "INIT_IMPORT_WIZARD";
    replace_var "MANIFEST_WIZARD_DECL";
  else
    replace_var "INIT_IMPORT_WIZARD"   "";
    replace_var "MANIFEST_WIZARD_DECL" "";
  fi
  replace_var "ODOO_MODULE_NAME" "$var_odoo_module_name";
  # Remove unsupported lines from copied requirements.txt file.
  replace_var "REQUIREMENTS_LINT"   "";
  replace_var "REQUIREMENTS_DEPLOY" "";
  replace_var "DOCUMENTED_MODULE" "models.new_model";
}

# Validation function for the Odoo module name form question.
function _validate_odoo_module_name() {
  local input="$1";
  if [ -z "$input" ]; then
    return 1;
  fi
  local re="^[a-z][a-z_]*[a-z]*$";
  if ! [[ "$input" =~ $re ]]; then
    logI "Only lower-case a-z and '_' characters are allowed";
    return 1;
  fi
  # Check for disallowed module names
  local _disallowed_module_names="module package build dist tests";
  if [[ " ${_disallowed_module_names} " =~ .*\ ${input}\ .* ]]; then
    logI "The name '${input}' is disallowed";
    return 1;
  fi
  return 0;
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

  USER_INPUT_DEFAULT_TEXT="my_module";
  read_user_input_text _validate_odoo_module_name;
  if (( $? == 1 )); then
    logI "";
    logI "No module name specified. Using default name '${USER_INPUT_DEFAULT_TEXT}'";
  fi
  local _odoo_module_name="$USER_INPUT_ENTERED_TEXT";
  var_odoo_module_name="${_odoo_module_name}";
  var_namespace="${_odoo_module_name}"; # Needed for generated docs
}

# Prompts the user to enter whether he wants the Odoo module to have a controller.
#
# Globals:
# var_odoo_create_controller - A boolean flag indicating whether to create
#                              an Odoo controller. Is set by this function.
#
function form_python_odoo_create_controller() {
  FORM_QUESTION_ID="python.odoo.create.controller";
  logI "";
  logI "Should the Odoo module have a web controller? (Y/n)";
  read_user_input_yes_no true;
  var_odoo_create_controller=$USER_INPUT_ENTERED_BOOL;
}

# Prompts the user to enter whether he wants the Odoo module to have a model
# and potentially views for that model.
#
# Globals:
# var_odoo_create_model       - A boolean flag indicating whether to create
#                               an Odoo model. Is set by this function.
# var_odoo_create_model_views - A boolean flag indicating whether to create
#                               a Odoo views for the model. Is set by this function.
#
function form_python_odoo_create_model_and_views() {
  FORM_QUESTION_ID="python.odoo.create.model";
  logI "";
  logI "Should the Odoo module have a model? (Y/n)";
  read_user_input_yes_no true;
  var_odoo_create_model=$USER_INPUT_ENTERED_BOOL;
  if [[ $var_odoo_create_model == true ]]; then
    FORM_QUESTION_ID="python.odoo.create.views";
    logI "";
    logI "Should the Odoo module have views for the model? (Y/n)";
    read_user_input_yes_no true;
    var_odoo_create_model_views=$USER_INPUT_ENTERED_BOOL;
  else
    var_odoo_create_model_views=false;
  fi
}

# Prompts the user to enter whether he wants the Odoo module to have a wizard.
#
# Globals:
# var_odoo_create_wizard - A boolean flag indicating whether to create
#                          an Odoo wizard. Is set by this function.
#
function form_python_odoo_create_wizard() {
  FORM_QUESTION_ID="python.odoo.create.wizard";
  logI "";
  logI "Should the Odoo module have a wizard? (Y/n)";
  read_user_input_yes_no true;
  var_odoo_create_wizard=$USER_INPUT_ENTERED_BOOL;
}


# Form questions

form_python_version;

form_python_virtenv_name;

form_python_odoo_module_name;

form_python_odoo_create_controller;

form_python_odoo_create_model_and_views;

form_python_odoo_create_wizard;

form_docs_integration;

form_docker_integration;

# Project setup

project_init_copy;

project_init_license "py" "xml";

project_init_process;
