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
# *                   ***   Init Script for C Projects   ***                  *
# *                                 INIT LEVEL 1                              *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_C_VERSION: The version number of the C standard to be used, e.g. '99'
# VAR_C_VERSION_LABEL: The version label of the C standard to be 
#                      used, e.g. 'C99'
# VAR_ARTIFACT_BINARY_NAME: The name of the binary file to
#                           be produced by the project
# VAR_ARTIFACT_BINARY_NAME_UPPER: The name of the binary file to be produced
#                                 by the project, in all upper-case.
# VAR_PREFIX_INCLUDE_GUARD: The prefix to be used in all header include guards

function process_files_lvl_1() {
  replace_var "C_VERSION"                  "$var_c_version";
  replace_var "C_VERSION_LABEL"            "$var_c_version_label";
  replace_var "ARTIFACT_BINARY_NAME"       "$var_artifact_binary_name";
  replace_var "ARTIFACT_BINARY_NAME_UPPER" "$var_artifact_binary_name_upper";
  # shellcheck disable=SC2154
  replace_var "PREFIX_INCLUDE_GUARD"       "$var_project_name_upper";
}

# [API function]
# Prompts the user to enter the C version to use for the project.
#
# The provided answer can be queried in source template files via the
# VAR_C_VERSION_LABEL and VAR_C_VERSION substitution variables.
# The associated shell global variables are set by this function.
#
# Globals:
# FORM_QUESTION_ID    - c.version
# var_c_version       - The C version string. Is set by this function.
# var_c_version_label - The C version label string.
#                       Is set by this function.
#
function form_c_version() {
  FORM_QUESTION_ID="c.version";
  logI "";
  logI "Specify the C standard to be used by the project:";
  read_user_input_selection "${SUPPORTED_LANG_VERSIONS_LABELS[@]}";
  var_c_version=${SUPPORTED_LANG_VERSIONS_IDS[USER_INPUT_ENTERED_INDEX]};
  var_c_version_label=${SUPPORTED_LANG_VERSIONS_LABELS[USER_INPUT_ENTERED_INDEX]};
}

# [API function]
# Prompts the user to enter the name of the produced binary file name
# (without possible platform-dependent file extension).
#
# The provided answer can be queried in source template files via the
# VAR_ARTIFACT_BINARY_NAME substitution variable.
# The associated shell global variable is set by this function.
#
# Globals:
# FORM_QUESTION_ID               - c.binary.name
# var_artifact_binary_name       - The name of the binary artifact.
#                                  Is set by this function.
# var_artifact_binary_name_upper - The name of the binary artifact in
#                                  all upper-case. Is set by this function.
#
function form_c_binary_name() {
  FORM_QUESTION_ID="c.binary.name";
  logI "";
  logI "Enter the name of the binary file that this project produces:";
  # shellcheck disable=SC2154
  USER_INPUT_DEFAULT_TEXT="$var_project_name_lower";
  logI "(Defaults to '${USER_INPUT_DEFAULT_TEXT}')";
  read_user_input_text;
  var_artifact_binary_name="$USER_INPUT_ENTERED_TEXT";
  var_artifact_binary_name_upper=$(echo "$var_artifact_binary_name" \
                                    |tr '[:lower:]' '[:upper:]');
}

# Specify supported C standards
add_lang_version "90" "C89/90 (ANSI C)"; # CMake expects the identifier as '90'
add_lang_version "99" "C99";
add_lang_version "11" "C11";
add_lang_version "17" "C17";
add_lang_version "23" "C23";

# Let the user choose a C project type
select_project_type "c" "C";
selected_name="$FORM_PROJECT_TYPE_NAME";
selected_dir="$FORM_PROJECT_TYPE_DIR";

proceed_next_level "$selected_dir";
