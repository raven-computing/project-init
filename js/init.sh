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
# *               ***   Init Script for JavaScript Projects   ***             *
# *                                 INIT LEVEL 1                              *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_NODEJS_VERSION: The version number of Node.js to be used,
#                     e.g. '16'
# VAR_NODEJS_VERSION_LABEL: The version label of Node.js to be used,
#                           e.g. 'Node.js 16'


function process_files_lvl_1() {
  replace_var "NODEJS_VERSION"       "$var_nodejs_version";
  replace_var "NODEJS_VERSION_LABEL" "$var_nodejs_version_label";
}

# [API function]
# Prompts the user to enter the Node.js version to use for the project.
#
# The provided answer can be queried in source template files via the
# VAR_NODEJS_VERSION and VAR_NODEJS_VERSION_LABEL substitution variables.
# The associated shell global variables are set by this function.
#
# Globals:
# FORM_QUESTION_ID         - js.nodejs.version
# var_nodejs_version       - The Node.js version string.
#                            Is set by this function.
# var_nodejs_version_label - The Node.js version label string.
#                            Is set by this function.
#
function form_nodejs_version() {
  FORM_QUESTION_ID="js.nodejs.version";
  logI "";
  logI "Specify the Node.js version to be used by the project:";
  # We alienate the SUPPORTED_LANG_VERSIONS_* global vars here
  read_user_input_selection "${SUPPORTED_LANG_VERSIONS_LABELS[@]}";
  var_nodejs_version=${SUPPORTED_LANG_VERSIONS_IDS[USER_INPUT_ENTERED_INDEX]};
  var_nodejs_version_label=${SUPPORTED_LANG_VERSIONS_LABELS[USER_INPUT_ENTERED_INDEX]};
}

# Specify supported versions for Node.js
# We use the standard API for language version specification for now
add_lang_version "20" "Node.js 20";
add_lang_version "22" "Node.js 22";
add_lang_version "24" "Node.js 24";

# Let the user choose a JavaScript project type
select_project_type "js" "JavaScript";
selected_name="$FORM_PROJECT_TYPE_NAME";
selected_dir="$FORM_PROJECT_TYPE_DIR";

proceed_next_level "$selected_dir";
