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
# *                   ***   Init Script for R Projects   ***                  *
# *                                 INIT LEVEL 1                              *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_R_VERSION: The version number of the R language to be used, e.g. '3.5.0'
# VAR_R_VERSION_LABEL: The version label of the R language to be 
#                      used, e.g. 'R 3.5.0'


function process_files_lvl_1() {
  replace_var "R_VERSION"        "$var_r_version";
  replace_var "R_VERSION_LABEL"  "$var_r_version_label";
}

# [API function]
# Prompts the user to enter the R version to use for the project.
#
# The provided answer can be queried in source template files via the
# VAR_R_VERSION and VAR_R_VERSION_LABEL substitution variables.
# The associated shell global variables are set by this function.
#
# Globals:
# var_r_version       - The R version string. Is set by this function.
# var_r_version_label - The R version label string.
#                       Is set by this function.
#
function form_r_version() {
  logI "";
  logI "Specify the R language to be used by the project:";
  read_user_input_selection "${SUPPORTED_LANG_VERSIONS_LABELS[@]}";
  var_r_version=${SUPPORTED_LANG_VERSIONS_IDS[USER_INPUT_ENTERED_INDEX]};
  var_r_version_label=${SUPPORTED_LANG_VERSIONS_LABELS[USER_INPUT_ENTERED_INDEX]};
}

# Specify supported R versions
add_lang_version "3.5.0" "R 3.5.0";
add_lang_version "3.6.0" "R 3.6.0";
add_lang_version "4.0.0" "R 4.0.0";
add_lang_version "4.1.0" "R 4.1.0";
add_lang_version "4.2.0" "R 4.2.0";

# Let the user choose an R project type
select_project_type "r" "R";
selected_name="$FORM_PROJECT_TYPE_NAME";
selected_dir="$FORM_PROJECT_TYPE_DIR";

proceed_next_level "$selected_dir";
