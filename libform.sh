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
# *             ***   Project Init Main Form Implementation  ***              *
# *                                                                           *
# #***************************************************************************#
#
# This file contains the code for the init level 0 main form.
# Call the project_init_show_main_form() function to conduct the user
# through the main form.
# The core function and global variables of the Project Init system
# are required to be available at the time the function is called.
#
# The following substitution variables are set by the main form:
#
# VAR_PROJECT_NAME: The name of the project
# VAR_PROJECT_NAME_LOWER: The name of the project, converted to lower case
# VAR_PROJECT_NAME_UPPER: The name of the project, converted to upper case
# VAR_PROJECT_DESCRIPTION: The project description
# VAR_PROJECT_LICENSE: The name of the project license
# VAR_PROJECT_DIR: The absolute path to the directory where the
#                  project is initialized
# VAR_PROJECT_LANG: The name of the programming language used in the project


# Global var holding the name of the directory representing
# the next init level after the main form was shown.
# Represents the return value of the project_init_show_main_form() function.
FORM_MAIN_NEXT_DIR="";

# Form callback function called by libinit when the project
# initialization process is executed.
function _project_init_process_forms() {
  if [ -n "$var_project_integration_docs_enabled" ]; then
    _project_init_process_docs_integration;
  fi
  if [ -n "$var_project_integration_docker_enabled" ]; then
    _project_init_process_docker_integration;
  fi
}

# Validation function for the project name form question.
function _validate_project_name() {
  local input="$1";
  if [ -z "$input" ]; then
    logI "Please provide a project name.";
    return 1;
  fi
  # Check against regex pattern
  local re="^[0-9a-zA-Z_ -]+$";
  if ! [[ "$input" =~ $re ]]; then
    logI "Invalid project name.";
    logI "Only lower/upper-case A-Z, digits, '-' and '_' characters are allowed";
    return 1;
  fi
  return 0;
}

# Validation function for the project target directory form question.
function _validate_project_directory() {
  local input="$1";
  if [ -z "$input" ]; then
    return 0;
  fi
  if ! _is_absolute_path "$input"; then
    # _check_is_valid_project_dir() expects an absolute path
    input="${var_project_dir}/${input}";
  fi
  _check_is_valid_project_dir "$input";
  return $?;
}

# Shows and runs through the main Project Init form.
function project_init_show_main_form() {
  _project_init_show_start_info;
  logI "";
  local specified_project_name="";
  get_property "project.name" "ask";
  if [[ "$PROPERTY_VALUE" == "ask" ]]; then
    FORM_QUESTION_ID="project.name";
    logI "Enter the name of the project:";
    read_user_input_text _validate_project_name;
    specified_project_name="$USER_INPUT_ENTERED_TEXT";
  else
    specified_project_name="$PROPERTY_VALUE";
  fi

  # Allow spaces but convert them to underscores.
  var_project_name="${specified_project_name// /_}";
  # Save name also as lowercase and as uppercase.
  var_project_name_lower=$(echo "$var_project_name" |tr '[:upper:]' '[:lower:]');
  var_project_name_upper=$(echo "$var_project_name" |tr '[:lower:]' '[:upper:]');
  if (( $? != 0 )); then
    failure "Failed to convert project name to lower-/uppercase: " \
            "Command 'tr' returned non-zero exit status";
  fi

  local specified_project_description;
  get_property "project.description" "ask";
  if [[ "$PROPERTY_VALUE" == "ask" ]]; then
    FORM_QUESTION_ID="project.description";
    logI "";
    logI "Enter a short description of the project:";
    read_user_input_text;
    specified_project_description="$USER_INPUT_ENTERED_TEXT";
  else
    specified_project_description="$PROPERTY_VALUE";
  fi

  # Check whether to set default text
  if [ -z "$specified_project_description" ]; then
    logI "You have not entered a short project description.";
    logI "A default description will be generated for you";
    get_property "project.description.default" "Project Init Default Description";
    var_project_description="$PROPERTY_VALUE";
  else
    var_project_description="$specified_project_description";
  fi

  _load_available_licenses;

  local select_license=true;
  get_boolean_property "sys.baselicenses.disable" "false";
  local baselicenses_disabled="$PROPERTY_VALUE";
  if [[ "$baselicenses_disabled" == "true" ]]; then
    if (( ${#_PROJECT_AVAILABLE_LICENSES_PATHS[@]} == 0 )); then
      select_license=false;
      var_project_license_dir="NONE";
      var_project_license="None";
      logI "";
      if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
        logW "Base licenses are disabled but the active addon has not provided any licenses.";
      else
        logW "Base licenses are disabled but no addon is active to provide alternative licenses.";
      fi
      logW "The project to be initialized will not be licensed.";
    fi
  fi

  if [[ $select_license == true ]]; then
    get_property "project.license" "ask";
    if [[ "$PROPERTY_VALUE" == "ask" ]]; then
      # Prompt to chosse a license
      FORM_QUESTION_ID="project.license";
      logI "";
      logI "Choose a license for the project:";
      read_user_input_selection "${_PROJECT_AVAILABLE_LICENSES_NAMES[@]}";

      # Check whether to set default text
      if [ -z "$USER_INPUT_ENTERED_INDEX" ]; then
        logI "";
        logI "You have not selected a license. The project will not be licensed";
        var_project_license_dir="NONE";
        var_project_license="None";
      else
        # Either set the selected license or 'None' 
        var_project_license="${_PROJECT_AVAILABLE_LICENSES_NAMES[USER_INPUT_ENTERED_INDEX]}";
        var_project_license_dir="${_PROJECT_AVAILABLE_LICENSES_PATHS[USER_INPUT_ENTERED_INDEX]}";

        if [[ "$var_project_license_dir" == "NONE" ]]; then
          logI "";
          logI "The project will have no license";
        fi
      fi
    else
      # License name was specified directly as property
      var_project_license="$PROPERTY_VALUE";
      # Find the corresponding license dir
      local i;
      for (( i=0; i<${#_PROJECT_AVAILABLE_LICENSES_NAMES[@]}; ++i )); do
        if [[ "$var_project_license" == "${_PROJECT_AVAILABLE_LICENSES_NAMES[i]}" ]]; then
          var_project_license_dir="${_PROJECT_AVAILABLE_LICENSES_PATHS[i]}";
          break;
        fi
      done
      # Check if license name was valid by checking whether we found a dir for it
      if [ -z "$var_project_license_dir" ]; then
        logE "No valid license specified for the new project";
        local hint_prop_key="${COLOR_CYAN}project.license=ask${COLOR_NC}";
        local hint_prop_file="${COLOR_CYAN}project.properties${COLOR_NC}";
        failure \
          "You have specified that new projects should use the license '${var_project_license}'," \
          "however, this license is not available. Either specify a valid license name"           \
          "or set ${hint_prop_key} in your ${hint_prop_file} file to be able to select "          \
          "an available license from a list.";
      fi
    fi
  fi

  _PROJECT_SELECTED_LICENSE_PATH="$var_project_license_dir";
  _PROJECT_SELECTED_LICENSE_NAME="$var_project_license";

  # Prepare reading of project target directory path
  local project_dir_name="$var_project_name_lower";
  var_project_dir="";

  get_boolean_property "sys.project.workdir.cwd" "false";
  local config_use_cwd="$PROPERTY_VALUE";
  get_property "sys.project.workdir.base" "workspace";
  local project_workdir="$PROPERTY_VALUE";
  # Check configured workdir value
  local re="^[0-9a-zA-Z_-]+$";
  if ! [[ "$project_workdir" =~ $re ]]; then
    logW "Property with key 'sys.project.workdir.base' has an invalid value.";
    logW "Only lower/upper-case A-Z, digits, '-' and '_' characters are allowed";
    project_workdir="workspace";
  fi
  if [[ "$config_use_cwd" == "true" ]]; then
    var_project_dir="${USER_CWD}/${project_dir_name}";
  else
    if [ -n "$HOME" ]; then
      # Set as default value
      var_project_dir="${HOME}/${project_workdir}/${project_dir_name}";
    fi
  fi

  FORM_QUESTION_ID="project.dir";
  logI "";
  logI "Enter the path to the project directory:";
  if [ -n "$var_project_dir" ]; then
    logI "(Defaults to '${var_project_dir}')";
  fi
  read_user_input_text _validate_project_directory;
  local entered_project_dir="$USER_INPUT_ENTERED_TEXT";

  # Check given answer
  if [ -z "$entered_project_dir" ]; then
    if [ -z "$var_project_dir" ]; then
      logE "Please provide a project directory path";
      failure "No project directory was specified";
    fi
  else
    if (( ${#entered_project_dir} > 1 )); then
      # Remove any trailing slashes and assign
      while [[ "$entered_project_dir" == */ ]]; do
        entered_project_dir="${entered_project_dir%/}";
      done
    fi
    var_project_dir="$entered_project_dir";
  fi

  # Convert to absolute path if necessary
  if ! _is_absolute_path "$var_project_dir"; then
    if [[ "$config_use_cwd" == "true" ]]; then
      var_project_dir="${USER_CWD}/${var_project_dir}";
    else
      var_project_dir="${HOME}/${project_workdir}/${var_project_dir}";
    fi
    logI "";
    logI "Project will be initialized at '${var_project_dir}'";
  fi

  if ! _check_is_valid_project_dir "$var_project_dir"; then
    failure "Invalid project directory: '${var_project_dir}'";
  fi

  # Check whether the project directory already
  # exists and is not empty
  if [ -d "$var_project_dir" ]; then
    if [ -n "$(ls "$var_project_dir")" ]; then
      _FLAG_PROJECT_DIR_POLLUTED=true;
      logW "Project directory is not empty. Files may get replaced";
    fi
  fi

  # Construct the list of language dirs and names
  local project_lang_dirs=()
  local project_lang_names=()

  for dir in *; do
    if [ -d "$dir" ]; then
      if [ -f "${dir}/init.sh" ]; then
        get_boolean_property "${dir}.disable" "false";
        if [[ "$PROPERTY_VALUE" == "true" ]]; then
          continue;
        fi
        if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
          if [ -f "${PROJECT_INIT_ADDONS_DIR}/${dir}/DISABLE" ]; then
            continue;
          fi
        fi
        project_lang_dirs+=("$dir");
        if [ -r "${dir}/name.txt" ]; then
          name=$(head -n 1 "${dir}/name.txt");
          project_lang_names+=("$name");
        else
          logW "Project init directory has no name file:";
          logW "at: '${dir}'";
          name="$dir";
          project_lang_names+=("${name}");
        fi
      fi
    fi
  done

  # Save the number of supported langs in the base script so that we
  # can later distinguish whether the user has chosen one of those
  # or a lang provided by addons
  local number_of_base_langs=${#project_lang_dirs[@]};

  # Add supported languages from addons to list
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    for dir in "${PROJECT_INIT_ADDONS_DIR}"/*; do
      if [ -d "$dir" ]; then
        if [ -f "${dir}/init.sh" ]; then
          project_lang_dirs+=("$dir");
          if [ -r "${dir}/name.txt" ]; then
            name=$(head -n 1 "${dir}/name.txt");
            project_lang_names+=("$name");
          else
            logW "Project init directory has no name file:";
            logW "at: '${dir}'";
            logW "Please add a file 'name.txt' to the directory" \
                 "of your language addon";
            logW "to control how the language is shown in the selection";
            name="$(basename "$dir")";
            project_lang_names+=("$name");
          fi
        fi
      fi
    done
  fi

  # Check whether we have anything to show
  local total_number_of_langs=${#project_lang_dirs[@]};
  if (( total_number_of_langs == 0 )); then
    logE "Cannot prompt for language selection. No options available";
    failure "You have disabled all base language selection options"         \
            "but not provided any programming language support via addons." \
            "Please either enable or provide at least one programming"      \
            "language for project initialization.";
  fi

  # To differentiate between whether a base lang or a lang provided by an addon
  # is selected, the code below relies on the fact that languages are
  # not user-sortable. The shown list and thus the selection item index always
  # has first base langs before addon langs.
  local selected_lang_index=0;

  # Either let the user select a language out of the list of available ones,
  # or automatically pick the lang if there is only one available
  if (( total_number_of_langs > 1 )); then
    FORM_QUESTION_ID="project.language";
    logI "";
    logI "Select the language to be used:";
    read_user_input_selection "${project_lang_names[@]}";
    selected_lang_index=$USER_INPUT_ENTERED_INDEX;
    local selected_name="${project_lang_names[USER_INPUT_ENTERED_INDEX]}";
    local selected_dir="${project_lang_dirs[USER_INPUT_ENTERED_INDEX]}";
  else
    local selected_name="${project_lang_names[0]}";
    local selected_dir="${project_lang_dirs[0]}";
  fi

  var_project_lang="$selected_name";

  # When the user choses a lang which is provided by an addon, we must set
  # the path for the current level to the addons root dir so that all
  # subsequent operations take that dir as the base
  if (( selected_lang_index >= number_of_base_langs )); then
    CURRENT_LVL_PATH="$PROJECT_INIT_ADDONS_DIR";
    _FLAG_PROJECT_LANG_IS_FROM_ADDONS=true;
  fi

  # Set global ret val
  FORM_MAIN_NEXT_DIR="$selected_dir";
  return 0;
}

# Processes the project source template files related to the Docker integration.
function _project_init_process_docker_integration() {
  replace_var "SCRIPT_BUILD_ISOLATED_OPT"          "$var_script_build_isolated_opt";
  replace_var "SCRIPT_BUILD_ISOLATED_ARGFLAG"      "$var_script_build_isolated_argflag";
  replace_var "SCRIPT_BUILD_ISOLATED_ARGARRAY"     "$var_script_build_isolated_argarray";
  replace_var "SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD" "$var_script_build_isolated_argarray_add";
  replace_var "SCRIPT_BUILD_ISOLATED_ARGPARSE"     "$var_script_build_isolated_argparse";
  replace_var "SCRIPT_BUILD_ISOLATED_MAIN"         "$var_script_build_isolated_main";
  replace_var "SCRIPT_BUILD_ISOLATED_HINT1"        "$var_script_build_isolated_hint1";
  replace_var "SCRIPT_TEST_ISOLATED_OPT"           "$var_script_test_isolated_opt";
  replace_var "SCRIPT_TEST_ISOLATED_MAIN"          "$var_script_test_isolated_main";
  replace_var "SCRIPT_TEST_ISOLATED_HINT1"         "$var_script_test_isolated_hint1";
  replace_var "SCRIPT_RUN_ISOLATED_OPT"            "$var_script_run_isolated_opt";
  replace_var "SCRIPT_RUN_ISOLATED_MAIN"           "$var_script_run_isolated_main";
  replace_var "SCRIPT_RUN_ISOLATED_HINT1"          "$var_script_run_isolated_hint1";
  if [[ "$var_project_integration_docker_enabled" == "0" ]]; then
    # Remove entire .docker dir in source root
    if directory_exists ".docker"; then
      remove_file ".docker";
    else
      logW "Cannot remove: '.docker'";
      logW "The project Docker integration was disabled but the project directory does not";
      logW "have a '.docker' directory in the root of the source tree.";
      warning "Docker integration was disabled but project had no '.docker' directory";
    fi
  elif [[ "$var_project_integration_docker_enabled" == "1" ]]; then
    if ! directory_exists ".docker"; then
      logW "The project Docker integration was enabled but the project directory does not";
      logW "have a '.docker' directory in the root of the source tree.";
      warning "Docker integration was enabled but could not find the '.docker' directory";
    fi
  fi
}

# Processes the project source template 'docs' directory and replaces the
# corresponding substitution variables for the project documentation integration.
function _project_init_process_docs_integration() {
  if [[ "$var_project_integration_docs_enabled" == "1" ]]; then
    if [[ "$var_project_lang" == "C" || "$var_project_lang" == "C++" ]]; then
      copy_shared "doxygen" "docs";
      load_var_from_file "SCRIPT_BUILD_DOCS_DOXYGEN_MAIN";
      var_script_build_docs_main="$VAR_FILE_VALUE";
      load_var_from_file "DOCKERFILE_BUILD_DOXYGEN";
      var_dockerfile_build_doxygen="$VAR_FILE_VALUE";
    elif [[ "$var_project_lang" == "Java" || "$var_project_lang" == "Python" ]]; then
      copy_shared "mkdocs" "docs";
      load_var_from_file "SCRIPT_BUILD_DOCS_MKDOCS_MAIN";
      var_script_build_docs_main="$VAR_FILE_VALUE";
      load_var_from_file "DOCKERFILE_BUILD_MKDOCS";
      var_dockerfile_build_mkdocs="$VAR_FILE_VALUE";
      load_var_from_file "DOCS_CONTENT_API_REFERENCE";
      replace_var "DOCS_CONTENT_API_REFERENCE" "$VAR_FILE_VALUE";
      load_var_from_file "DOCS_MKDOCS_PLUGIN_MKDOCSTRINGS";
      replace_var "DOCS_MKDOCS_PLUGIN_MKDOCSTRINGS" "$VAR_FILE_VALUE";
    else
      logW "Cannot set up project documentation integration.";
      logW "No docs template resource is available for ${var_project_lang}";
      var_project_integration_docs_enabled="0";
      var_script_build_docs_argflag="";
      var_script_build_docs_argparse="";
      var_script_build_docs_opt="";
    fi
  fi
  replace_var "SCRIPT_BUILD_DOCS_ARGFLAG"  "$var_script_build_docs_argflag";
  replace_var "SCRIPT_BUILD_DOCS_ARGPARSE" "$var_script_build_docs_argparse";
  replace_var "SCRIPT_BUILD_DOCS_OPT"      "$var_script_build_docs_opt";
  replace_var "SCRIPT_BUILD_DOCS_MAIN"     "$var_script_build_docs_main";
  replace_var "DOCKERFILE_BUILD_DOXYGEN"   "$var_dockerfile_build_doxygen";
  replace_var "DOCKERFILE_BUILD_MKDOCS"    "$var_dockerfile_build_mkdocs";
  # If Docker integration is generally not available for the underlying project type
  # (i.e. form_docker_integration() is never called by any init script), then we must
  # handle here the Docker-related Docs integration substitution variables ourselves,
  # and remove them. Otherwise this is handled by _project_init_process_docker_integration()
  if [ -z "$var_project_integration_docker_enabled" ]; then
    replace_var "SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD" "";
    replace_var "SCRIPT_BUILD_ISOLATED_HINT1"        "";
  fi
}

# [API function]
# Prompts the user to enter whether he wants Docker integration.
#
# Enabling Docker integration for a project means that a user can build and test the
# project inside a virtualized environment of a Docker container. This makes it easier,
# for example, to build a project from source because a user does not have to worry
# about the underlying toolchain. Integration with Docker is always optional.
#
# This function will set the `var_project_integration_docker_enabled` global variable
# to either "1" or "0", depending on the user's choice. You may then handle this
# information in one of your custom `process_files_lvl_*()` functions.
#
# The project source files responsible for the Docker integration should
# reside in a **'.docker'** directory inside the project source root. If the user chooses
# to disable Docker integration for a project, then that directory is automatically
# removed from the project during initialization.
#
# Globals:
# FORM_QUESTION_ID                       - project.integration.docker
# var_project_integration_docker_enabled - Indicates whether the user wants to enable Docker
#                                          integration for the project or not. Is set to the
#                                          string "1" if Docker integration should be enabled,
#                                          otherwise it is set to "0". Is set by this function.
#
function form_docker_integration() {
  FORM_QUESTION_ID="project.integration.docker";
  logI "";
  logI "Would you like to enable Docker integration? (Y/n)";
  read_user_input_yes_no true;
  if [[ "$USER_INPUT_ENTERED_BOOL" == "true" ]]; then
    var_project_integration_docker_enabled="1";
    load_var_from_file "SCRIPT_BUILD_ISOLATED_OPT";
    var_script_build_isolated_opt="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_BUILD_ISOLATED_ARGFLAG";
    var_script_build_isolated_argflag="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_BUILD_ISOLATED_ARGARRAY";
    var_script_build_isolated_argarray="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD";
    var_script_build_isolated_argarray_add="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_BUILD_ISOLATED_ARGPARSE";
    var_script_build_isolated_argparse="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_BUILD_ISOLATED_MAIN";
    var_script_build_isolated_main="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_BUILD_ISOLATED_HINT1";
    var_script_build_isolated_hint1="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_TEST_ISOLATED_OPT";
    var_script_test_isolated_opt="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_TEST_ISOLATED_MAIN";
    var_script_test_isolated_main="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_TEST_ISOLATED_HINT1";
    var_script_test_isolated_hint1="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_RUN_ISOLATED_OPT";
    var_script_run_isolated_opt="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_RUN_ISOLATED_MAIN";
    var_script_run_isolated_main="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_RUN_ISOLATED_HINT1";
    var_script_run_isolated_hint1="$VAR_FILE_VALUE";
  else
    var_project_integration_docker_enabled="0";
  fi
}

# Prompts the user to enter whether he wants project documentation integration.
#
# This function will set the `var_project_integration_docs_enabled` global variable
# to either "1" or "0", depending on the user's choice.
#
# Globals:
# FORM_QUESTION_ID                       - project.integration.docs
# var_project_integration_docs_enabled   - Indicates whether the user wants to have
#                                          project documentation integration.
#                                          Is set by this function.
#
function form_docs_integration() {
  FORM_QUESTION_ID="project.integration.docs";
  logI "";
  logI "Should the project have documentation resources? (Y/n)";
  read_user_input_yes_no true;
  if [[ "$USER_INPUT_ENTERED_BOOL" == "true" ]]; then
    var_project_integration_docs_enabled="1";
    load_var_from_file "SCRIPT_BUILD_DOCS_ARGFLAG";
    var_script_build_docs_argflag="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_BUILD_DOCS_ARGPARSE";
    var_script_build_docs_argparse="$VAR_FILE_VALUE";
    load_var_from_file "SCRIPT_BUILD_DOCS_OPT";
    var_script_build_docs_opt="$VAR_FILE_VALUE";
  else
    var_project_integration_docs_enabled="0";
  fi
}
