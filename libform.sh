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
# *             ***   Project Init Main Form Implementation  ***              *
# *                                                                           *
# #***************************************************************************#
#
# This file contains the code for the init level 0 main form.
# Call the show_project_init_main_form() function to conduct the user
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
# VAR_PROJECT_ORGANISATION_NAME: The name of the organisation for the project
# VAR_PROJECT_ORGANISATION_URL: The URL for the organisation website
# VAR_PROJECT_ORGANISATION_EMAIL: The E-Mail of the organisation of the project
# VAR_PROJECT_LICENSE: The name of the project license
# VAR_COPYRIGHT_YEAR: The year used in copyright notices
# VAR_COPYRIGHT_HOLDER: The name of the copyright holder
# VAR_PROJECT_SLOGAN_STRING: The example string to use within the generated
#                            example source code, e.g. when printing something
#                            to the screen
# VAR_PROJECT_DIR: The absolute path to the directory where the
#                  project is initialized
# VAR_PROJECT_LANG: The name of the programming language used in the project


# Global var holding the name of the directory representing
# the next init level after the main form was shown.
# Represents the return value of the show_project_init_main_form() function.
FORM_MAIN_NEXT_DIR="";

# Shows and runs through the main Project Init form.
function show_project_init_main_form() {
  logI "";
  local specified_project_name="";
  get_property "project.name" "ask";
  if [[ "$PROPERTY_VALUE" == "ask" ]]; then
    FORM_QUESTION_ID="project.name";
    logI "Enter the name of the project:";
    read_user_input_text;
    specified_project_name="$USER_INPUT_ENTERED_TEXT";
  else
    specified_project_name="$PROPERTY_VALUE";
  fi

  if [ -z "$specified_project_name" ]; then
    logE "Please provide a project name";
    failure "No project name was specified";
  fi
  # Check against regex pattern
  local re="^[0-9a-zA-Z_-]+$";
  if ! [[ "$specified_project_name" =~ $re ]]; then
    logE "Invalid project name";
    failure "A project name with invalid characters was specified." \
            "Only lower/upper-case A-Z, digits, '-' and '_' characters are allowed";
  fi
  # Save as is, as lowercase and as uppercase
  var_project_name="$specified_project_name";
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

  # Set generic variables used in every project
  get_property "project.organisation.name" "Raven Computing";
  var_project_organisation_name="$PROPERTY_VALUE";

  get_property "project.organisation.url" "https://www.raven-computing.com";
  var_project_organisation_url="$PROPERTY_VALUE";

  get_property "project.organisation.email" "info@raven-computing.com";
  var_project_organisation_email="$PROPERTY_VALUE";

  get_property "project.slogan.string" "Created by Project Init system";
  var_project_slogan_string="$PROPERTY_VALUE";

  local all_license_dirs=();
  for fpath in "$SCRIPT_LVL_0_BASE/licenses/"*; do
    if [ -d "$fpath" ]; then
      all_license_dirs+=("$fpath");
    fi
  done

  # Add the license directories from the addons to the list
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -d "$PROJECT_INIT_ADDONS_DIR/licenses" ]; then
      for fpath in "$PROJECT_INIT_ADDONS_DIR/licenses/"*; do
        if [ -d "$fpath" ]; then
          all_license_dirs+=("$fpath");
        fi
      done
      # Check if the separator char used in the sort function
      # is part of one of the path strings
      for fpath in ${all_license_dirs[@]}; do
        if [[ "$fpath" == *"?"* ]]; then
          logE "Invalid path encountered:";
          logE "'$fpath'";
          logE "Path contains an invalid character: '?'";
          failure "One or more paths to a component of an addon has an invalid character." \
                  "Please make sure that the path to the addons directory does not"        \
                  "contain '?' characters";
        fi
      done
      all_license_dirs=( $(_sort_file_paths "${all_license_dirs[@]}") );
    fi
  fi

  # Construct the list of license dirs and names
  local project_licenses_dirs=();
  local project_licenses_names=();

  for dir in ${all_license_dirs[@]}; do
    local dir_name=$(basename "$dir");
    if [ -r "$dir/license.txt" ]; then
      project_licenses_dirs+=("$dir");
      if [ -r "$dir/name.txt" ]; then
        local name=$(head -n 1 "$dir/name.txt");
        project_licenses_names+=("$name");
      else
        logW "The license directory '$dir_name' has no name file";
        name="$dir_name";
        project_licenses_names+=("$name");
      fi
    else
      logW "The license directory does not have a 'license.txt' file:";
      logW "at: '$dir'";
    fi
  done

  # Add an option for no license
  project_licenses_dirs+=("NONE");
  project_licenses_names+=("None");

  get_property "project.license" "ask";
  if [[ "$PROPERTY_VALUE" == "ask" ]]; then
    # Prompt to chosse a license
    FORM_QUESTION_ID="project.license";
    logI "";
    logI "Choose a license for the project:";
    read_user_input_selection "${project_licenses_names[@]}";

    # Check whether to set default text
    if [ -z "$USER_INPUT_ENTERED_INDEX" ]; then
      logI "";
      logI "You have not selected a license. The project will not be licensed";
      var_project_license_dir="NONE";
      var_project_license="None";
    else
      # Either set the selected license or 'None' 
      var_project_license="${project_licenses_names[USER_INPUT_ENTERED_INDEX]}";
      var_project_license_dir="${project_licenses_dirs[USER_INPUT_ENTERED_INDEX]}";

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
    for (( i=0; i<${#project_licenses_names[@]}; ++i )); do
      if [[ "$var_project_license" == "${project_licenses_names[$i]}" ]]; then
        var_project_license_dir="${project_licenses_dirs[$i]}";
        break;
      fi
    done
    # Check if license name was valid by checking whether we found a dir for it
    if [ -z "$var_project_license_dir" ]; then
      logE "No valid license specified for the new project";
      local hint_prop_key="${COLOR_CYAN}project.license=ask${COLOR_NC}";
      local hint_prop_file="${COLOR_CYAN}project.properties${COLOR_NC}";
      failure \
        "You have specified that new projects should use the license '$var_project_license'," \
        "however, this license is not available. Either specify a valid license name"         \
        "or set ${hint_prop_key} in your ${hint_prop_file} file to be able to select "        \
        "an available license from a list.";
    fi
  fi

  # Set copyright information vars
  var_copyright_year=$(date +%Y);
  if (( $? != 0 )); then
    logW "Failed to get current date:";
    logW "Command 'date' returned non-zero exit status.";
    warning "Check date in copyright headers of source files";
    var_copyright_year="1970";
  fi
  var_copyright_holder="$var_project_organisation_name";

  # Prepare reading of project target directory path
  local project_dir_name="$var_project_name_lower";
  var_project_dir="";
  local is_home_set=false;

  get_boolean_property "sys.project.workdir.cwd" "false";
  local config_use_cwd="$PROPERTY_VALUE";
  get_property "sys.project.workdir.base" "workspace";
  local project_workdir="$PROPERTY_VALUE";
  # Check configured workdir value
  if ! [[ "$project_workdir" =~ $re ]]; then
    logW "Property with key 'sys.project.workdir.base' has an invalid value.";
    logW "Only lower/upper-case A-Z, digits, '-' and '_' characters are allowed";
    project_workdir="workspace";
  fi
  if [[ "$config_use_cwd" == "true" ]]; then
    var_project_dir="$USER_CWD/$project_dir_name";
  else
    if [ -n "$HOME" ]; then
      is_home_set=true;
      # Set as default value
      var_project_dir="$HOME/$project_workdir/$project_dir_name";
    fi
  fi

  FORM_QUESTION_ID="project.dir";
  logI "";
  logI "Enter the path to the project directory:";
  if [ -n "$var_project_dir" ]; then
    logI "(Defaults to '$var_project_dir')";
  fi
  read_user_input_text;
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
  if ! [[ "$var_project_dir" == /* ]]; then
    if [[ "$config_use_cwd" == "true" ]]; then
      var_project_dir="$USER_CWD/$var_project_dir";
    else
      var_project_dir="$HOME/$project_workdir/$var_project_dir";
    fi
    logI "";
    logI "Project will be initialized under '$var_project_dir'";
  fi

  _check_is_valid_project_dir "$var_project_dir";

  # Check whether the project directory already
  # exists and is not empty
  if [ -d "$var_project_dir" ]; then
    if ! [ -z "$(ls $var_project_dir)" ]; then
      _FLAG_PROJECT_DIR_POLLUTED=true;
      logW "Project directory is not empty. Files may get replaced";
    fi
  fi

  # Construct the list of language dirs and names
  local project_lang_dirs=()
  local project_lang_names=()

  for dir in $(ls -d */); do
    if [ -f "${dir}init.sh" ]; then
      get_boolean_property "${dir::-1}.disable" "false";
      if [[ "$PROPERTY_VALUE" == "true" ]]; then
        continue;
      fi
      if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
        if [ -f "$PROJECT_INIT_ADDONS_DIR/${dir}DISABLE" ]; then
          continue;
        fi
      fi
      project_lang_dirs+=("$dir");
      if [ -r "${dir}name.txt" ]; then
        name=$(head -n 1 "${dir}name.txt");
        project_lang_names+=("$name");
      else
        logW "Project init directory has no name file:";
        logW "at: '$dir'";
        name="$dir";
        project_lang_names+=("${name::-1}");
      fi
    fi
  done

  # Save the number of supported langs in the base script so that we
  # can later distinguish whether the user has chosen one of those
  # or a lang provided by addons
  local number_of_base_langs=${#project_lang_dirs[@]};

  # Add supported languages from addons to list
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    for dir in $(ls -d "$PROJECT_INIT_ADDONS_DIR"/*); do
      if [ -f "${dir}/init.sh" ]; then
        project_lang_dirs+=("$dir");
        if [ -r "${dir}/name.txt" ]; then
          name=$(head -n 1 "${dir}/name.txt");
          project_lang_names+=("$name");
        else
          logW "Project init directory has no name file:";
          logW "at: '$dir'";
          logW "Please add a file 'name.txt' to the directory" \
              "of your language addon";
          logW "to control how the language is shown in the selection";
          name="$(basename "$dir")";
          project_lang_names+=("$name");
        fi
      fi
    done
  fi

  logI "";
  # Check whether we have anything to show
  local total_number_of_langs=${#project_lang_dirs[@]};
  if (( $total_number_of_langs == 0 )); then
    logE "Cannot prompt for language selection. No options available";
    failure "You have disabled all base language selection options "          \
            "but not provided a language via addons. Please either enable or" \
            "provide at least one language for project initialization";
  fi

  # Either let the user select a language out of the list of available ones,
  # or automatically pick the lang if there is only one available
  if (( $total_number_of_langs > 1 )); then
    FORM_QUESTION_ID="project.language";
    logI "Select the language to be used:";
    read_user_input_selection "${project_lang_names[@]}";
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
  if (( $USER_INPUT_ENTERED_INDEX >= $number_of_base_langs )); then
    CURRENT_LVL_PATH="$PROJECT_INIT_ADDONS_DIR";
    _FLAG_PROJECT_LANG_IS_FROM_ADDONS=true;
  fi

  # Set global ret val
  FORM_MAIN_NEXT_DIR="$selected_dir";
  return 0;
}
