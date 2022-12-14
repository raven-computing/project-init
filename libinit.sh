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
# *               ***   Project Init Functions and Globals   ***              *
# *                                                                           *
# #***************************************************************************#
#
# This file defines common functions and global variables used in the Project
# Init system. It contains the core code upon which the system is built.
#
# Not all functions defined in this file are considered as API functions.
# Functions which can be called as an API are designated as such in their
# source documentation. Concretely, all API functions will have the
# symbol "[API function]" put as the first line comment of their respective
# source documentation. The conventional regulations with regard to API
# stability and backwards compatibility apply. Functions which are not
# considered as an API do not have to guarantee stability with regard to
# their signature. Such functions are allowed to change in any way, or be
# removed completely without the application of any standard deprecation
# policy. The consumption of non-API functions is exclusively intended by
# the Project Init system itself. Therefore, developers writting add-ons are
# strongly advised to only use API functions in their code.
#
# All global variables defined in this file should be considered read-only by
# external/API users if their identifying name is written in all caps.
# Do not manually assign a value to any such global variable.
# The values of those global variables should only be changed by functions
# defined in this file or init system code.
#
# The Project Init system divides the initialization into separate steps,
# so called init levels. These levels do not have to be visually
# distinguishable by the end user. They are simply used to hierarchically
# lay out the initialization code in a logical order. The general rule is
# that code in higher init levels is common to all lower init levels. However,
# the reverse is not true. For example, the highest init level is 0 (zero),
# which will typically involve code to retrieve the name and description of the
# project to initialize and the language to be used. The next init level (1)
# will then consider the steps to be taken in order to initialize a project
# with the given language, i.e. all things common to projects for that
# language or technology.
# Each init level is defined by a directory containing an "init.sh" file, a
# so called init script. Such a directory is usually located under a higher
# init level directory.
#
# Although an init script can in principle contain arbitrary shell code, the
# common practice is to ask the underlying user questions relevant to the
# particular init level context and set internal variables. In this way,
# the user is presented with a continuous form of questions in order to set
# up a new project according to his needs.
# The following functions can be used to gather the answer from the user for
# various types of questions:
#   * read_user_input_text()
#   * read_user_input_selection()
#   * read_user_input_yes_no()
#
# Questions, informative text, warnings and errors can be shown at any time
# in a consistent way by means of the log*() family of functions.
#
# The answers provided by the user are in the end usually saved in so called
# substitution variables. These are defined as global shell variables with
# a "var_"-prefix. They should be defined as all lower-case. Substitution
# variables usually have a counterpart in one or more project template
# source files. Those counterparts have the pattern "${{VAR_*}}", where
# the "*" is the unique identifier of that substitution variable, in all caps.
# A standard mechanism is provided by which substitution variables defined in
# project source template files are replaced by the concrete value set in the
# corresponding shell variable.
#
# Once an init script has completed its task and gathered all relevant
# information from the user, there are two distinct situations to consider.
# If a subsequent init level exists, then the active init level signals to
# the Project Init system that it can move on to the next lower init level.
# This is done by a call to the proceed_next_level() function, usually placed
# as the last line of code in an init script. This procedure recursively calls
# the init scripts in the right order, until the final init level is reached.
# The final init level usually also has a "source" subdirectory which contains
# the project source template files. Those can be any type of files which are
# used by the concrete project type to be initialized.
#
# The actual project initialization is executed by calling the corresponding
# API functions in the right order. The initialization is a three-step process.
# First, the project source template files are copied as is to the
# project target directory. Second, the licensing and copyright information is
# set up based on the information provided by the user. Third, all copied
# project source files are processed and potentially changed.
# The actually initialization is therefore executed when the last init script
# calls the following functions in this specific order:
#   * project_init_copy()
#   * project_init_license()
#   * project_init_process()
#
# In principle, any custom shell code can be inserted in between the above
# three function calls. The convention is, however, that these functions are
# the last lines of code in the last init script within the lowermost
# init level. The project_init_process() function is responsible for
# processing the project source template files in such a way, that
# the initialized project contains syntactically correct code and can
# be built and used practically out of the box. In doing so, all encountered
# substitution variables are replaced by the value set in the corresponding
# init script code. Any init script can introduce and define new substitution
# variables, which must be present in the underlying project source template
# files in order to have an effect. Each substitution variable is processed
# by a call to the replace_var() function.
# Substitution variables should generally not be processed before
# the project_init_process() function is called, although it is possible.
# To adhere to the general init level processing order, each init level script
# can define a process_files_lvl_*() function, where the "*" is the number of
# the init level that the underlying init script implements. These functions
# will be called by the init system at the right time and in the right order,
# from higher init levels (lower level number) to lower init levels
# (higher level number). The convention is that the function implementations
# take care of processing all substitution variables, which are defined or set
# in the underlying init script, by calling the replace_var() function.
# Usually, the process_files_lvl_*() functions are placed as the first function
# inside the corresponding init script.
#
# An irrecoverable error can be signaled at any time by calling the failure()
# function. This will gracefully terminate the initialization process and
# inform the user about the occurred error. If the user should only be
# informed about an issue, without terminating the program, the warning()
# function should be used instead. Warnings are accumulated and shown to
# the user at the end of a successful project initialization.
#
# The developer documentation is available under on GitHub:
# https://github.com/raven-computing/project-init/wiki
#
# Please consult the docs for further information on the Init System and
# the provided APIs. The system and its behaviour is customizable by
# an add-on mechanism without having to change the core code of the system.


# Minimum required Bash major version
readonly REQUIREMENT_BASH_VERSION=4;

# [API Exit Code]
# Used when a project is successfully initialized
# and the program has finished without fatal errors.
readonly EXIT_SUCCESS=0;
# [API Exit Code]
# Used when the program encounters any kind of error.
readonly EXIT_FAILURE=1;
# [API Exit Code]
# Used when the program is terminated by an interrupt signal,
# e.g. when cancelling by means of Ctrl+C, or when the user
# does not confirm the project initialization.
readonly EXIT_CANCELLED=5;

# [API Global]
# Holds the version identifier of the Project Init system.
# The format is 'major.minor.patch'.
PROJECT_INIT_VERSION="";

# [API Global]
# Holds the version identifier of the addons resources if applicable.
# This is the version as specified in the VERSION file of the addons
# resource directory. The format of the value of this variable
# is 'major.minor.patch', or '?.?.?' if the VERSION file contains an
# invalid format. If no VERSION file is found, this variable will be empty.
PROJECT_INIT_ADDONS_VERSION="";

# [API Global]
# Indicates whether the running version of the Project Init system is
# a development version or a release version. This global variable
# is either true or false.
PROJECT_INIT_IS_DEV_VERSION="";

# [API Global]
# Indicates whether the loaded addons resource of the running Project Init
# system is a development version or a release version. This global variable
# is either true or false.
PROJECT_INIT_ADDONS_IS_DEV_VERSION="";

# [API Global]
# Contains the absolute path to the directory of
# the current active init level. As the user progresses
# through the forms of the various init levels, this
# variable is automatically adjusted to always point to
# the init level directory the system is currently in.
CURRENT_LVL_PATH="";

# [API Global]
# Contains the number of the currently active init level.
# The start (entry point) of the Project Init system,
# i.e. the source root of the system itself, is defined
# as level 0 (zero). As the user progresses through the
# forms, each directory in which the system descends into
# represents a separate init level, for which a greater
# level number is assigned. This variable is automatically
# adjusted to always equal the number of the init level
# the system is currently in.
CURRENT_LVL_NUMBER=0;

# [API Global]
# Contains the user-entered string from the last call
# to the read_user_input_text() function.
USER_INPUT_ENTERED_TEXT="";

# [API Global]
# Contains the selection index of the user choice from
# the last call to the read_user_input_selection() function.
# Please note that this index is always zero-based, even when
# the selection numbers shown to the user within the
# form selections exhibit a different behaviour.
USER_INPUT_ENTERED_INDEX="";

# [API Global]
# Contains the boolean user answer of the yes/no question
# from the last call to the read_user_input_yes_no() function.
# This variable contains either true or false.
USER_INPUT_ENTERED_BOOL="";

# [API Global]
# The name of the project type selected by the user.
# This global var holds one of the two results of
# the select_project_type() function.
FORM_PROJECT_TYPE_NAME="";

# [API Global]
# The path to the directory of the project type
# selected by the user. This global var holds one of
# the two results of the select_project_type() function.
FORM_PROJECT_TYPE_DIR="";

# [API Global]
# Holds the name of the directory representing
# the next init level that was selected by the user. Please note
# that this is not the absolute path to the selected directory,
# but rather only the name of the directory within the filesystem.
# Represents the first return value of
# the select_next_level_directory() function.
SELECTED_NEXT_LEVEL_DIR="";

# [API Global]
# Holds the display name of the directory that was selected by
# the user. This is not the directory name on the filesystem, but
# rather the name as it is shown to the user within the form,
# i.e. as specified by the accompanying 'name.txt' file.
# Represents the second return value of
# the select_next_level_directory() function.
SELECTED_NEXT_LEVEL_DIR_NAME="";

# [API Global]
# Holds the property value set by the get_property()
# and get_boolean_property() functions.
PROPERTY_VALUE="";

# [API Global]
# Holds the value computed and set by the make_hyperlink() function.
# The string value might contain terminal escape codes.
# Since:
# 1.1.0
HYPERLINK_VALUE="";

# [API Global]
# The message to show when a project is successfully initialized.
# This text is shown in the terminal and in the desktop notification.
# Since:
# 1.1.0
PROJECT_INIT_SUCCESS_MESSAGE="Project has been initialized";

# An array for holding all supported language version
# numbers/identifiers
SUPPORTED_LANG_VERSIONS_IDS=();

# An array for holding the corresponding labels for all
# supported language versions
SUPPORTED_LANG_VERSIONS_LABELS=();

# An array holding names of commands that are required
# by the init system. Is filled by the _read_dependencies() function.
SYS_DEPENDENCIES=();

# An array where all summary warning messages are saved.
# Use the warning() function to add a new message.
_WARNING_LOG=();

# Holds the number of issued warnings. This corresponds to
# the number of occurred warning-level log statements.
_N_WARNINGS=0;

# Holds the number of issued errors. This corresponds to
# the number of occurred error-level log statements.
_N_ERRORS=0;

# The list of all entries in 'files.txt' files.
LIST_FILES_TXT=();

# The absolute path to the location where
# Project Init resources, including addons, are cached.
readonly RES_CACHE_LOCATION="/tmp";

# The base URL to be used when creating hyperlinks
# to the Project Init documentation, e.g. for help texts.
readonly DOCS_BASE_URL="https://github.com/raven-computing/project-init/wiki";

# Contains the absolute path to the directory of the current theoretic
# init level within the addons resource. This is essentially the addons
# counterpart to $CURRENT_LVL_PATH, but the path is always pointing
# to the addons resource directory. This variable is automatically
# adjusted to always point to the init level directory of the addons
# resource that is or would be applicable, even when no such directory
# is provided by the addon. If no addon is active, then this variable
# will be left empty.
_ADDONS_CURRENT_LVL_PATH="";

# Indicates whether the file cache is invalidated.
_FLAG_FCACHE_ERR=false;

# Indicates whether the selected project language comes exclusively
# from an addons resource.
_FLAG_PROJECT_LANG_IS_FROM_ADDONS=false;
# Indicates whether the project_init_copy() function was called.
_FLAG_PROJECT_FILES_COPIED=false;
# Indicates whether the project_init_license() function was called.
_FLAG_PROJECT_LICENSE_PROCESSED=false;
# Indicates whether the project_init_process() function was called.
_FLAG_PROJECT_FILES_PROCESSED=false;
# Indicates whether the directory where the new project should be
# initialized in is polluted, i.e. it already exists and was not empty
# when the init system checked it.
_FLAG_PROJECT_DIR_POLLUTED=false;
# Indicates whether the system configuration has been loaded.
_FLAG_CONFIGURATION_LOADED=false;

# The timeout of the success notification, in milliseconds.
_INT_NOTIF_SUCCESS_TIMEOUT=3000;
# The path to the icon to be used by the success notification.
# Is set dynamically as the program progesses.
_STR_NOTIF_SUCCESS_ICON="";
# Indicates whether a success notification icon was specified by an addon.
_FLAG_NOTIF_SUCCESS_ICON_ADDON=false;

# Terminal color flag may be set as env var
if [[ "$TERMINAL_USE_ANSI_COLORS" == "0" ]]; then
  readonly TERMINAL_USE_ANSI_COLORS=false;
  # Disable colors
  readonly COLOR_RED="";
  readonly COLOR_GREEN="";
  readonly COLOR_BLUE="";
  readonly COLOR_CYAN="";
  readonly COLOR_ORANGE="";
  readonly COLOR_NC="";
else
  readonly TERMINAL_USE_ANSI_COLORS=true;
  # Terminal colors
  readonly COLOR_RED="\033[0;31m";
  readonly COLOR_GREEN="\033[1;32m";
  readonly COLOR_BLUE="\033[1;34m";
  readonly COLOR_CYAN="\033[1;36m";
  readonly COLOR_ORANGE="\033[1;33m";
  readonly COLOR_NC="\033[0m";
fi


# [API function]
# Prints an INFO level statement on stdout.
#
# All given info strings are logged on one line.
#
# Args:
# $* - An arbitrary number of string messages to log
#
# Stdout:
# An INFO level statement.
#
function logI() {
  if [[ $TERMINAL_USE_ANSI_COLORS == true ]]; then
    echo -e "[${COLOR_BLUE}INFO${COLOR_NC}] $*";
  else
    echo "[INFO] $*";
  fi
}

# [API function]
# Prints a WARNING level statement on stdout.
#
# All given warning strings are logged on one line.
#
# Args:
# $* - An arbitrary number of string messages to log
#
# Stdout:
# A WARNING level statement.
#
function logW() {
  if [[ $TERMINAL_USE_ANSI_COLORS == true ]]; then
    echo -e "[${COLOR_ORANGE}WARN${COLOR_NC}] $*";
  else
    echo "[WARN] $*";
  fi
  ((++_N_WARNINGS));
}

# [API function]
# Prints an ERROR level statement on stdout.
#
# All given error strings are logged on one line.
#
# Args:
# $* - An arbitrary number of string messages to log
#
# Stdout:
# An ERROR level statement.
#
function logE() {
  if [[ $TERMINAL_USE_ANSI_COLORS == true ]]; then
    echo -e "[${COLOR_RED}ERROR${COLOR_NC}] $*";
  else
    echo "[ERROR] $*";
  fi
  ((++_N_ERRORS));
}

# [API function]
# Adds a warning to the project initialization summary.
#
# This function adds the given warning message to the list of warnings
# shown at the end after a project has been successfully initialized.
# Only one string can be given to this function per call. Each message
# will be shown on a separate line.
#
# Args:
# $1 - A string message to log
#
function warning() {
  _WARNING_LOG+=("$1");
}

# Prints a statement indicating a successful operation.
#
# This function shows a success message and prints saved warnings.
# The program will not be terminated by this function.
#
function _log_success() {
  local max_lines=20;
  logI "";
  if [[ $TERMINAL_USE_ANSI_COLORS == true ]]; then
    echo -ne "[${COLOR_BLUE}INFO${COLOR_NC}] ";
    for i in $(seq 1 $max_lines); do
      echo -n "-";
    done
    echo -ne " [${COLOR_GREEN}SUCCESS${COLOR_NC}] ";
  else
    echo -n "[INFO] ";
    for i in $(seq 1 $max_lines); do
      echo -n "-";
    done
    echo -n " [SUCCESS] ";
  fi
  for i in $(seq 1 $max_lines); do
    echo -n "-";
  done
  echo "";
  logI "${PROJECT_INIT_SUCCESS_MESSAGE}";
  logI "";
  # Check logged warning messages
  local warn_size=${#_WARNING_LOG[@]};
  if (( $warn_size > 0 )); then
    for warning in "${_WARNING_LOG[@]}"; do
      logW "${COLOR_ORANGE}Warning:${COLOR_NC}";
      logW "$warning";
      logI "";
    done
  fi
}

# Shows a system notification indicating a successful operation.
#
# This function will try to display a desktop notification if
# the notify-send command is available. It returns exit status 1
# if the notify-send command is not available, otherwise it returns
# the exit status of notify-send.
#
function _show_notif_success() {
  if _command_dependency "notify-send"; then
    local _project_name="New Project";
    if [ -n "$var_project_name" ]; then
      _project_name="$var_project_name";
    fi
    local _has_icon=false;
    if [ -n "${_STR_NOTIF_SUCCESS_ICON}" ]; then
      if [ -r "${_STR_NOTIF_SUCCESS_ICON}" ]; then
        _has_icon=true;
      fi
    fi
    if [[ ${_has_icon} == true ]]; then
      notify-send -i "${_STR_NOTIF_SUCCESS_ICON}"  \
                  -t ${_INT_NOTIF_SUCCESS_TIMEOUT} \
                  "${_project_name}"               \
                  "${PROJECT_INIT_SUCCESS_MESSAGE}";
    else
      notify-send -t ${_INT_NOTIF_SUCCESS_TIMEOUT} \
                  "${_project_name}"               \
                  "${PROJECT_INIT_SUCCESS_MESSAGE}";
    fi
    return $?;
  fi
  return 1;
}

# Prints a help text statement with the specified log level.
#
# Is used to guide the user to some specific part of the official documentation.
# The help text is directly printed with the specified log level. Therefore a call
# to this function needs to be placed at the right location.
#
# Args:
# $1 - The log level to use when printing the help text.
#      Must be one of 'I' (Info), 'W' (Warning), 'E' (Error).
# $2 - The documentation link relative to the base URL as indicated
#      by the $DOCS_BASE_URL global variable.
#
# Globals:
# DOCS_BASE_URL - Is used by this function to determine the base part of the created
#                 hyperlink, which points to the official documentation.
#
# Stdout:
# Help text information with the specified log level.
#
function _show_helptext() {
  local _log_lvl="$1";
  local _doc_res="$2";
  if [ -z "${_log_lvl}" ]; then
    logE "Programming error: No log level specified in call to _show_helptext()";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    return 1;
  fi
  if [ -z "${_doc_res}" ]; then
    logE "Programming error: No resource name specified in call to _show_helptext()";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    return 1;
  fi
  make_hyperlink "${DOCS_BASE_URL}/${_doc_res}" "documentation";
  local _helptext="[HELP]: See the $HYPERLINK_VALUE for more information";
  if [[ "${_log_lvl}" == "I" ]]; then
    logI "";
    logI "${_helptext}";
    logI "";
  elif [[ "${_log_lvl}" == "W" ]]; then
    logW "";
    logW "${_helptext}";
    logW "";
  elif [[ "${_log_lvl}" == "E" ]]; then
    logE "";
    logE "${_helptext}";
    logE "";
  else
    logE "Programming error: Invalid log level specified in call to _show_helptext()";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    return 1;
  fi
  return 0;
}

# Makes a hyperlink value which points to an API function
# description within the official documentation.
#
# Is used to display a link to a specific API function within the official
# documentation. The hyperlink value is created by using the make_hyperlink() function.
# Therefore, the result is saved in the $HYPERLINK_VALUE global variable.
#
# Args:
# $1 - The function name to make a link for. Must not contain any brackets.
#
# Globals:
# DOCS_BASE_URL   - Is used by this function to determine the base part of the created
#                   hyperlink, which points to the official documentation.
# HYPERLINK_VALUE - Holds the string value of the created hyperlink.
#                   Is set as a result of a call to this function.
#
function _make_func_hl() {
  local _func_name="$1";
  if [ -z "${_func_name}" ]; then
    logE "Programming error: No function name specified in call to _make_func_hl()";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    HYPERLINK_VALUE="";
    return 1;
  fi
  make_hyperlink "${DOCS_BASE_URL}/API-Reference#${_func_name}" "${_func_name}()";
  return $?;
}

# [API function]
# Prints a statement indicating a failed operation.
#
# This function shows a failure message and prints all given error messages.
# The program will be terminated by this function with exit code indicated
# by the global variable $EXIT_FAILURE.
#
# Args:
# $@ - Optional strings indicating all error messages.
#      Each message is printed on its own line.
#
# Stdout:
# Error information.
#
function failure() {
  local max_lines=20;
  logI "";
  if [[ $TERMINAL_USE_ANSI_COLORS == true ]]; then
    echo -ne "[${COLOR_BLUE}INFO${COLOR_NC}] ";
    for i in $(seq 1 $max_lines); do
      echo -ne "-";
    done
    echo -ne " [${COLOR_RED}FAILURE${COLOR_NC}] ";
  else
    echo -n "[INFO] ";
    for i in $(seq 1 $max_lines); do
      echo -n "-";
    done
    echo -n " [FAILURE] ";
  fi
  for i in $(seq 1 $max_lines); do
    echo -n "-";
  done
  echo "";
  logI "";
  if (( $# == 0 )); then
    logE "An error has occurred";
  else
    for msg in "$@"; do
      logE "$msg";
    done
  fi

  if [[ ${_FLAG_PROJECT_FILES_COPIED} == true ]]; then
    # Source files have already been copied to the target directory.
    # Try to clean it up safely
    if [ -d "$var_project_dir" ]; then
      if [[ ${_FLAG_PROJECT_DIR_POLLUTED} == false ]]; then
        var_project_dir="${var_project_dir%/}";
        if [[ "$var_project_dir" != "$HOME" ]]; then
          rm -r "$var_project_dir";
          if (( $? != 0 )); then
            logW "Failed to clean up already created project directory.";
            logW "Check '$var_project_dir' for remnant files";
          fi
        fi
      else
        logW "Unable to clean up already created project directory: Polluted directory.";
        logW "Check '$var_project_dir' for remnant files";
      fi
    fi
  fi

  # Play bell alert sound if applicable
  if [[ ${_FLAG_CONFIGURATION_LOADED} == true ]]; then
    get_boolean_property "sys.output.sound.onfail" "true";
    if [[ "$PROPERTY_VALUE" == "true" ]]; then
      echo -ne "\a";
    fi
  fi

  exit $EXIT_FAILURE;
}

# [API function]
# Creates a hyperlink from the specified URL.
#
# This function can be used to create a clickable hyperlink leading
# to a web resource. The hyperlink might be embedded in a series of
# terminal escape codes if this is an activated feature, in which case
# the specified label is used as the display string for the created hyperlink.
# If the corresponding feature is disabled, the provided URL might be used
# as is in the computed value. Please note that this function does not check
# whether the underlying terminal emulator in use supports displaying
# clickable labeled hyperlinks.
# The result of this function is not printed directly but instead stored
# in the $HYPERLINK_VALUE global variable.
#
# Since:
# 1.1.0
#
# Args:
# $1 - The URL of the hyperlink. This is a mandatory argument.
# $2 - The label of the hyperlink. This argument is optional.
#
# Globals:
# HYPERLINK_VALUE - Holds the string value of the created hyperlink.
#                   Is set by this function.
#
# Returns:
# 0 - If the hypelink was successfully created.
# 1 - If an error occurred.
#
# Examples:
# make_hyperlink "http://www.example.com" "Example Link";
# logI "Please see this $HYPERLINK_VALUE";
#
function make_hyperlink() {
  local _hl_url="$1";
  local _hl_label="$2";
  if [ -z "${_hl_url}" ]; then
    logE "Programming error: No URL specified in call to make_hyperlink()";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    HYPERLINK_VALUE="";
    return 1;
  fi
  if [ -z "${_hl_label}" ]; then
    _hl_label="${_hl_url}";
  fi
  get_boolean_property "sys.output.hyperlinks.escape" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    HYPERLINK_VALUE="\e]8;;${_hl_url}\e\\\\${_hl_label}\e]8;;\e\\\\";
  else
    if [[ "${_hl_label}" != "${_hl_url}" ]]; then
      _hl_url="${_hl_label} (${_hl_url})";
    fi
    HYPERLINK_VALUE="${_hl_url}";
  fi
  return 0;
}

# Loads the version information for the Project Init base system.
#
# Globals:
# PROJECT_INIT_VERSION - Holds the version identifier string.
#                        Is set by this function.
#
# Returns:
# 0 - If the loaded version string is formally valid.
# 1 - If the loaded version string is formally INVALID.
#
function _load_version_base() {
  if [ -z "$SCRIPT_LVL_0_BASE" ]; then
    SCRIPT_LVL_0_BASE="$(_get_script_path "${BASH_SOURCE[0]}")";
  fi
  local path_version_base="$SCRIPT_LVL_0_BASE/VERSION";
  local version_base="?.?.?";
  local ret_val=0;
  # Read from version file
  if [ -r "$path_version_base" ]; then
    version_base=$(head -n 1 "$path_version_base");
  fi
  # Validate version identifiers
  local re="^[0-9]+\.[0-9]+\.[0-9]+(-dev)?$";
  if ! [[ $version_base =~ $re ]]; then
    # Do not print warning if the '-#' arg was specified
    if [[ $ARG_VERSION_STR == false ]]; then
      logW "Invalid version string specified:";
      logW "at: '$path_version_base'";
    fi
    version_base="?.?.?";
    ret_val=1;
  fi
  PROJECT_INIT_VERSION="$version_base";
  if [[ "${PROJECT_INIT_VERSION}" == *-dev ]]; then
    PROJECT_INIT_IS_DEV_VERSION=true;
  else
    PROJECT_INIT_IS_DEV_VERSION=false;
  fi
  return $ret_val;
}

# Loads the version information for the Project Init addons resource.
#
# Globals:
# PROJECT_INIT_ADDONS_VERSION - Holds the version identifier string.
#                               Is set by this function.
#
# Returns:
# 0 - If the loaded version string is formally valid.
# 1 - If the loaded version string is formally INVALID.
#
function _load_version_addons() {
  local path_version_addons="$PROJECT_INIT_ADDONS_DIR/VERSION";
  local version_addons="";
  local ret_val=0;
  # Read from version file
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -r "$path_version_addons" ]; then
      version_addons=$(head -n 1 "$path_version_addons");
    fi
  fi
  # Validate version identifiers
  if [ -n "$version_addons" ]; then
    local re="^[0-9]+\.[0-9]+\.[0-9]+(-dev)?$";
    if ! [[ $version_addons =~ $re ]]; then
      logW "Invalid version string specified in addons resource:";
      logW "at: '$path_version_addons'";
      _show_helptext "W" "Addons#versioning";
      version_addons="?.?.?";
      ret_val=1;
    fi
  fi
  PROJECT_INIT_ADDONS_VERSION="$version_addons";
  if [[ "${PROJECT_INIT_ADDONS_VERSION}" == *-dev ]]; then
    PROJECT_INIT_ADDONS_IS_DEV_VERSION=true;
  else
    PROJECT_INIT_ADDONS_IS_DEV_VERSION=false;
  fi
  return $ret_val;
}

# Parses all given arguments and sets the global $ARG_* variables.
#
# Args:
# $@ -  The arguments to parse.
#
# Stdout:
# An error message is printed if an unknown argument is encountered.
#
# Globals:
# ARG_NO_CACHE    - Represents the '--no-cache' option.
# ARG_NO_PULL     - Represents the '--no-pull' option.
# ARG_HELP        - Represents the '-?|--help' option.
# ARG_VERSION     - Represents the '--version' option.
# ARG_VERSION_STR - Represents the '-#' option.
#
function _parse_args() {
  ARG_NO_CACHE=false;
  ARG_NO_PULL=false;
  ARG_HELP=false;
  ARG_VERSION=false;
  ARG_VERSION_STR=false;
  for arg in "$@"; do
    case $arg in
      --no-cache)
      ARG_NO_CACHE=true;
      shift;
      ;;
      --no-pull)
      ARG_NO_PULL=true;
      shift;
      ;;
      --version)
      ARG_VERSION=true;
      shift;
      ;;
      -#)
      ARG_VERSION_STR=true;
      shift;
      ;;
      -\?|--help)
      ARG_HELP=true;
      shift;
      ;;
      *)
      # Unknown argument
      echo "Unknown argument: '$arg'";
      echo "";
      echo "Use the '--help' option for more information";
      echo "";
      exit $EXIT_FAILURE;
      ;;
    esac
  done
}

# Handles the utility/helper arguments if passed to this program.
# Requires that the global $ARG_* variables have been set.
function _handle_util_args() {
  if [[ $ARG_VERSION_STR == true ]]; then
    _load_version_base;
    echo "$PROJECT_INIT_VERSION";
    exit $EXIT_SUCCESS;
  fi
  if [[ $ARG_VERSION == true ]]; then
    _load_version_base;
    local version_dev="";
    if [[ $PROJECT_INIT_IS_DEV_VERSION == true ]]; then
      version_dev="(Development Version)";
    fi
    echo "Project Init v${PROJECT_INIT_VERSION} ${version_dev}";
    echo "Copyright (C) 2022 Raven Computing";
    echo "This software is licensed under the Apache License, Version 2.0";
    exit $EXIT_SUCCESS;
  fi
  if [[ $ARG_HELP == true ]]; then
    _load_version_base;
    local version_dev="";
    if [[ $PROJECT_INIT_IS_DEV_VERSION == true ]]; then
      version_dev="(Development Version)";
    fi
    echo "Project Init v${PROJECT_INIT_VERSION} ${version_dev}";
    echo "Quickly set up new projects.";
    echo "";
    echo "This program guides a user through the steps of initializing a new software project.";
    echo "Simply run it without any arguments and you will be prompted to answer some ";
    echo "basic questions to initialize a new software project.";
    echo "";
    echo "The following optional arguments are supported:"
    echo "";
    echo "Options:";
    echo "";
    if [[ "$PROJECT_INIT_BOOTSTRAP" == "1" ]]; then
      echo "  [--no-cache]   Clear the caches after the program exits.";
      echo "";
    fi
    echo "  [--no-pull]    Do not update existing caches and use them as is.";
    echo "";
    echo "  [-#|--version] Show program version information.";
    echo "";
    echo "  [-?|--help]    Show this help message.";
    echo "";
    exit $EXIT_SUCCESS;
  fi
}

# Event handling function to be called when an interrupt
# signal SIGINT is received.
function _handle_interrupt_event() {
  echo "";
  logI "Cancelling...";
  exit $EXIT_CANCELLED;
}

# Sets up code to handle system signals.
function _setup_event_handlers() {
  trap _handle_interrupt_event SIGINT;
}

# Checks whether the specified command is available and either returns 0 (zero)
# if it is available or 1 if the command is not available.
#
# Args:
# $1 - The name of the command. This is the name by which the corresponding command
#      is called, e.g. the executable name. This argument is mandatory.
#
# Returns:
# 0 - If the specified command can be found and is available in the system.
# 1 - If the specified command could not be found.
#
# Examples:
# _command_dependency "awk";
#
function _command_dependency() {
  local cmd_exec="$1";
  if [ -z "$cmd_exec" ]; then
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to _command_dependency() function: " \
            "No command name specified";
  fi
  if ! command -v "$cmd_exec" &> /dev/null; then
    return 1;
  fi
  return 0;
}

# Prints the content of the specified text file.
#
# If the specified file cannot be read, this function does nothing.
#
# Args:
# $1 - The path to the file to read. This argument is mandatory.
#
function _print_text_from_file() {
  local file_path="$1";
  # Read and print lines if available
  if [ -r "$file_path" ]; then
    # Save the internal field separator
    local IFS_ORIG="$IFS";
    # Set the IFS to an empty string
    IFS="";
    # Read the text file and show
    local line="";
    while read -r line || [ -n "$line" ]; do
      logI "$line";
    done < "$file_path"
    # Reset the original IFS value
    IFS="$IFS_ORIG";
  fi
}

# Shows the ASCII-encoded start icon.
#
# This function reads the 'icon.ascii.txt' file containing the icon to show.
# An existing file in the addons directory takes precedence over the base icon.
#
function _show_start_icon() {
  local ficon="$SCRIPT_LVL_0_BASE/icon.ascii.txt";
  # Check for addons overwrite
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -r "$PROJECT_INIT_ADDONS_DIR/icon.ascii.txt" ]; then
      ficon="$PROJECT_INIT_ADDONS_DIR/icon.ascii.txt";
    fi
  fi
  # Read and show icon
  _print_text_from_file "$ficon";
}

# Reads the specified text file and populates the $SYS_DEPENDENCIES global
# variable with the corresponding dependency command names.
#
# This function can be called multiple times for different files.
# Already existing dependencies are not added again.
#
# Args:
# $1 - The text file to read.
#
# Returns:
# 0 - If the specified file was successfully read.
# 1 - If the file could be read but is incorrectly formatted.
# 2 - If the specified file could not be read.
#
# Globals:
# SYS_DEPENDENCIES - The variable to which the read dependencies are written to.
#                    Must be an already declared array.
#
# Examples:
# _read_dependencies "dependencies.txt";
#
function _read_dependencies() {
  local dependencies_file="$1";
  local invalid_format=false;
  local invalid_line=0;
  if [[ -z "$dependencies_file" ]]; then
    logE "Programming error: No file specified in call to _read_dependencies()";
    return 2;
  fi
  if [ -r "$dependencies_file" ]; then
    local line_num=0;
    local line="";
    while read -r line || [ -n "$line" ]; do
      line_num=$((line_num+1));
      # Ignore comments and blank lines
      if [[ ! -z "$line" && "$line" != \#* ]]; then
        # Check that the line does not contain spaces
        if [[ "$line" != *" "* ]]; then
          # Avoid duplicates
          if [[ ! "${SYS_DEPENDENCIES[*]}" =~ "${line}" ]]; then
            SYS_DEPENDENCIES+=( "$line" );
          fi
        else
          invalid_format=true;
          invalid_line=$line_num;
        fi
      fi
    done < "$dependencies_file";
  else
    logW "The specified dependencies file does not exist or is not readable:";
    logW "at: '$dependencies_file'";
    return 2
  fi
  if [[ $invalid_format == true ]]; then
    logW "The dependencies file is incorrectly formatted:";
    logW "at: '$dependencies_file' (at line $invalid_line)";
    return 1;
  fi
  return 0;
}

# Performs system compatibility checks.
#
# This function will call failure() if compatibility cannot be guaranteed.
#
function _check_system_compat() {
  # Check Bash version.
  # Defaults to 0 (zero) if version number cannot be determined
  local bash_version_major="${BASH_VERSINFO:-0}";
  local bash_version_full="${BASH_VERSION}";
  if (( $bash_version_major < $REQUIREMENT_BASH_VERSION )); then
    logW "Unsatisfied compatibility requirement.";
    if (( $bash_version_major == 0 )); then
      logW "You are using an unsupported Bash version.";
    else
      local _bash_version_msg="$bash_version_major";
      if [ -n "$bash_version_full" ]; then
        _bash_version_msg="$bash_version_full";
      fi
      logW "You are using Bash version ${_bash_version_msg}";
    fi
    logW "This program requires at least Bash version $REQUIREMENT_BASH_VERSION";
    failure "Unsupported interpreter version";
  fi
}

# Performs system dependencies checks.
#
# This function can call the failure() function if a system dependency
# is not available.
#
function _check_system_dependencies() {
  # Check that required external commands are available
  _read_dependencies "dependencies.txt";
  if (( $? != 0 )); then
    failure "Detected error in the base dependencies.txt file";
  fi
  for dependency in ${SYS_DEPENDENCIES[*]}; do
    if ! _command_dependency "$dependency"; then
      logE "Could not find the '$dependency' executable.";
      logE "Please make sure that $dependency is correctly installed.";
      failure "Unsatisfied compatibility requirement. Missing system dependency";
    fi
  done

  # Check for addons sys dependencies
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -f "$PROJECT_INIT_ADDONS_DIR/dependencies.txt" ]; then
      _read_dependencies "$PROJECT_INIT_ADDONS_DIR/dependencies.txt";
      for dependency in ${SYS_DEPENDENCIES[*]}; do
        _command_dependency "$dependency";
        if (( $? != 0 )); then
          get_boolean_property "sys.dependencies.onmissing.fail" "true";
          if [[ "$PROPERTY_VALUE" == "true" ]]; then
            logE "Could not find the '$dependency' executable.";
            logE "Please make sure that $dependency is correctly installed.";
            failure "Unsatisfied compatibility requirement. Missing system dependency";
          else
            logW "Missing system dependency: '$dependency'";
          fi
        fi
      done
    fi
  fi
}

# Loads the Project Init addons resources from the specified Git repository
# to a temporary directory.
#
# The specified argument must not contain the 'GIT:' prefix as used by
# the $PROJECT_INIT_ADDONS_RES environment variable.
# After the addons resources are loaded, the $PROJECT_INIT_ADDONS_DIR global
# variable is set to point to the temporary directory where the resources
# are located.
# This function may reuse already fetched Git resources and update them
# via Git protocols.
#
# Args:
# $1 - The Git repository access specifier as e.g. passed
#      to the 'git clone' command. Can be in any format which can be
#      handled by Git.
#
# Stdout:
# Loading text is printed normally and encountered errors.
#
# Globals:
# PROJECT_INIT_ADDONS_DIR - The path to the (temporary) directory containing
#                           the loaded addons resources.
#                           Is set by this function.
#
function _load_addons_resource_git() {
  local git_res="$1";
  if [ -z "$git_res" ]; then
    failure "Programming error: Invalid call to _load_addons_resource_git() function: " \
            "No arguments specified";
  fi
  local cmd_exit_status=0;
  # Ensure that git is available
  _command_dependency "git";
  # We temporarily switch to the system's /tmp directory.
  # To be reverted at the end of this function or in case of failure.
  cd "$RES_CACHE_LOCATION";
  cmd_exit_status=$?;
  if (( $cmd_exit_status != 0 )); then
    failure "Failed to change active working directory to $RES_CACHE_LOCATION";
  fi
  # Effective user ID
  local _EUID=$(id -u);
  # Find suitable cache dir
  local cache_dir_pattern="piar_cache_${_EUID}_*";
  local cache_dirs=( $cache_dir_pattern );
  local addons_res_dir="";
  # Check if a cache dir already exists
  if [[ "${cache_dirs[0]}" == "$cache_dir_pattern" ]]; then
    # No cache dir found
    _command_dependency "mktemp";
    # Create new cache dir
    addons_res_dir="$(mktemp -d piar_cache_${_EUID}_XXXXXXXXXX 2>&1)";
    cmd_exit_status=$?;
    if (( $cmd_exit_status != 0 )); then
      cd "$SCRIPT_LVL_0_BASE";
      logE "Command 'mktemp' returned non-zero exit status $cmd_exit_status";
      if [ -n "$addons_res_dir" ]; then
        logE "Command error:";
        echo "$addons_res_dir";
      fi
      failure "Failed to create addons resource cache under $RES_CACHE_LOCATION";
    fi
    local branch="";
    local git_branch="";
    if [ -n "$PROJECT_INIT_ADDONS_RES_BRANCH" ]; then
      branch="$PROJECT_INIT_ADDONS_RES_BRANCH";
      git_branch="-b $branch";
    fi
    echo -n "Loading addons...";
    git clone $git_branch --depth 1 "$git_res" "$RES_CACHE_LOCATION/$addons_res_dir" &> /dev/null;
    cmd_exit_status=$?;
    if (( $cmd_exit_status != 0 )); then
      echo "FAILURE";
      rm -r "$addons_res_dir";
      cd "$SCRIPT_LVL_0_BASE";
      logE "Command 'git clone' returned non-zero exit status $cmd_exit_status";
      logE "Make sure that '$git_res' is a valid git repository and that ";
      logE "you have the necessary access rights.";
      if [ -n "$branch" ]; then
        failure "Failed to fetch Project Init addons resources from '$git_res' " \
                "on branch '$branch' and caching it under '$RES_CACHE_LOCATION/$addons_res_dir'";
      else
        failure "Failed to fetch Project Init addons resources from '$git_res' " \
                "and caching it under '$RES_CACHE_LOCATION/$addons_res_dir'";
      fi
    fi
    echo "OK";
  else
    # At least one cache dir found
    addons_res_dir="${cache_dirs[0]}";
    cd "$addons_res_dir";
    cmd_exit_status=$?;
    if (( $cmd_exit_status != 0 )); then
      failure "Failed to change active working directory to '$addons_res_dir'";
    fi
    echo -n "Loading addons...";
    if [[ $ARG_NO_PULL == false ]]; then
      # Update cache so that we always use the latest version
      git pull &> /dev/null;
      cmd_exit_status=$?;
    fi
    if (( $cmd_exit_status != 0 )); then
      echo "FAILURE";
      cd "$SCRIPT_LVL_0_BASE";
      local cache_dir="$RES_CACHE_LOCATION/$addons_res_dir";
      logE "Command 'git pull' returned non-zero exit status $cmd_exit_status";
      failure "Failed to update cached Project Init addons resources: "     \
              "at: '$cache_dir'"                                            \
              "You could try to remove the cache directory '$cache_dir' "   \
              "and try again.";
    fi
    echo "OK";
  fi
  # Set global var and switch back to the system init base dir
  logI "";
  PROJECT_INIT_ADDONS_DIR="$RES_CACHE_LOCATION/$addons_res_dir";
  cd "$SCRIPT_LVL_0_BASE";
  cmd_exit_status=$?;
  if (( $cmd_exit_status != 0 )); then
    failure "Failed to change active working directory back to $SCRIPT_LVL_0_BASE";
  fi
}

# Loads the Project Init addons resources if available and sets
# the corresponding system variables.
#
# Calling this function only has an effect if the $PROJECT_INIT_ADDONS_RES
# environment variable is set. Addons can be loaded in two ways: directly via a
# directory in the filesystem or via a Git repository. In any case, however,
# this function makes the underlying addons resources available to the rest of
# the init system by setting the $PROJECT_INIT_ADDONS_DIR global variable.
# Code which consumes addons resources must do so by only using
# the $PROJECT_INIT_ADDONS_DIR global variable, which, after this function is
# called and if non-empty, provides the absolute path to the directory
# containing the addons resources.
#
# If the addons resources cannot be correctly loaded, due to any reason, or an
# inconsistency is detected, then this function can either print a warning or
# exit the program by means of the failure() function.
# This function is intended to be called once during the startup procedure.
#
# Globals:
# PROJECT_INIT_ADDONS_DIR - The path to the directory containing the loaded
#                           addons resources. If no addons are loaded, then
#                           it is set to an empty string.
#                           Is set by this function.
#
function _load_addons_resource() {
  if [ -n "$PROJECT_INIT_ADDONS_RES" ]; then
    local addons_is_git_res=false;
    if [[ "$PROJECT_INIT_ADDONS_RES" == GIT:* ]]; then
      # Addons is git resource
      addons_is_git_res=true;
      PROJECT_INIT_ADDONS_RES="${PROJECT_INIT_ADDONS_RES:4}";
      _load_addons_resource_git "$PROJECT_INIT_ADDONS_RES";
    else
      # Addons is filesystem resource
      PROJECT_INIT_ADDONS_DIR="$PROJECT_INIT_ADDONS_RES";
    fi
    # Check set dir var
    if [ -d "$PROJECT_INIT_ADDONS_DIR" ]; then
      if ! [ -r "$PROJECT_INIT_ADDONS_DIR/INIT_ADDONS" ]; then
        # Do not show warnings when in test mode
        if [[ "$PROJECT_INIT_TESTS_ACTIVE" != "1" ]]; then
          if [[ $addons_is_git_res == true ]]; then
            logW "Repository is not marked as a Project Init addons resource:";
            logW "Accessed via: '$PROJECT_INIT_ADDONS_RES'";
            logW "Please add an empty file named 'INIT_ADDONS' in the repository root";
            logW "in order to use it as a Project Init addons resource.";
          else
            logW "Directory is not marked as a Project Init addons resource:";
            logW "at: '$PROJECT_INIT_ADDONS_DIR'";
            logW "Please create an empty file '$PROJECT_INIT_ADDONS_DIR/INIT_ADDONS'";
            logW "in order to use the directory as a Project Init addons resource.";
          fi
          logW "";
          logW "Ignoring 'PROJECT_INIT_ADDONS_RES' resource";
          PROJECT_INIT_ADDONS_DIR="";
        fi
      fi
    else
      logW "Cannot use Project Init addons resource:";
      logW "at: '$PROJECT_INIT_ADDONS_DIR'";
      if [[ "$PROJECT_INIT_ADDONS_DIR" =~ ^http*|^https* \
           || "$PROJECT_INIT_ADDONS_DIR" == *"@"* ]]; then

        logW "";
        logW "If you want to use a Git repository as an addons resource, the value of";
        logW "the 'PROJECT_INIT_ADDONS_RES' environment variable must start with 'GIT:'";
      fi
      logW "";
      logW "Ignoring 'PROJECT_INIT_ADDONS_RES' resource";
      PROJECT_INIT_ADDONS_DIR="";
    fi
  else
    PROJECT_INIT_ADDONS_DIR="";
  fi
}

# Shows the start title.
#
# This function shows the start program title indicating the program name,
# vesion and potentially the addons version if available.
#
function _show_start_title() {
  if [ -z "$PROJECT_INIT_VERSION" ]; then
    _load_version_base;
  fi
  local version_base="$PROJECT_INIT_VERSION";
  local version_addons="$PROJECT_INIT_ADDONS_VERSION";

  if [[ "$version_base" == "?.?.?" ]]; then
    version_base="?";
  fi
  if [[ "$version_addons" == "?.?.?" ]]; then
    version_addons="?";
  fi

  # Check for addons title
  local has_addons_title=false;
  if [ -n "$PROJECT_INIT_ADDONS_DIR/title.txt" ]; then
    if [ -r "$PROJECT_INIT_ADDONS_DIR/title.txt" ]; then
      _print_text_from_file "$PROJECT_INIT_ADDONS_DIR/title.txt";
      has_addons_title=true;
    fi
  fi

  if [[ $has_addons_title == false ]]; then
    # Create and show version information message
    local version_string="*****  Project Init";
    if [ -n "$version_base" ]; then
      version_string="$version_string - v$version_base";
      if [[ $PROJECT_INIT_IS_DEV_VERSION == true ]]; then
        version_string="$version_string (Development Version)";
      fi
    fi
    if [ -n "$version_addons" ]; then
      version_string="$version_string  [ using addons v$version_addons";
      if [[ $PROJECT_INIT_ADDONS_IS_DEV_VERSION == true ]]; then
        version_string="$version_string (Development Version)";
      fi
      version_string="$version_string ]";
    elif [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
      version_string="$version_string  [ with addons ]";
    fi
    version_string="$version_string  *****";
    logI "$version_string";
  fi
}

# Shows the informative start info text.
function _show_start_text() {
  logI "";
  # Check for addons description text
  local has_addons_text=false;
  if [ -n "$PROJECT_INIT_ADDONS_DIR/description.txt" ]; then
    if [ -r "$PROJECT_INIT_ADDONS_DIR/description.txt" ]; then
      _print_text_from_file "$PROJECT_INIT_ADDONS_DIR/description.txt";
      has_addons_text=true;
    fi
  fi
  if [[ $has_addons_text == false ]]; then
    logI "Welcome to Project Init. This program will guide you through the steps";
    logI "of initializing a new software project. Please answer the following";
    logI "questions to get started.";
  fi
}

# Returns the absolute path to the directory of the specified bash script.
#
# This function can be used to get the absolute path to the bash script for
# which the BASH_SOURCE variable is given
#
# Args:
# $1 - The value of the BASH_SOURCE shell variable.
#
# Stdout:
# The absolute path to the script, dumped to stdout.
#
# Examples:
# my_path=$(_get_script_path "${BASH_SOURCE[0]}")
#
function _get_script_path() {
  local _arg_path="$1";
  echo "$(cd "$(dirname "${_arg_path}")" > /dev/null 2>&1 && pwd)";
}

# Reads the specified .properties formatted file and populates
# the specified associative array global variable with the corresponding
# key-value pairs.
#
# This function can be called multiple times for different files.
# The previously populated key-value pairs are not lost. However, in the
# case of an already existent key in any subsequent call, the value for
# that key is overwritten with the new value.
# The specified file to be read must be properties-formatted. The second
# argument is optional. When omitted, all read properties are saved in
# the $PROPERTIES global variable.
#
# Args:
# $1 - The properties file to read. This is a mandatory argument.
# $2 - The name of the associative array global variable to populate.
#      This is an optional argument.
#
# Returns:
# 0 - If the specified properties file was successfully read.
# 1 - If the file could be read but is incorrectly formatted.
# 2 - If the specified file could not be read.
#
# Globals:
# PROPERTIES - The variable to which the read key-value pairs are written to
#              if the $2 argument is not provided.
#              Must be an already declared associative array.
#
# Examples:
# _read_properties "project.properties";
# declare -g -A MY_A_VARIABLE;
# _read_properties "myfile.properties" MY_A_VARIABLE;
#
function _read_properties() {
  local properties_file="$1";
  local container="$2";
  if [ -z "$container" ]; then
    container="PROPERTIES";
  fi
  local invalid_format=false;
  local invalid_line=0;
  if [[ -z "$properties_file" ]]; then
    logE "Programming error: No file specified in call to _read_properties()";
    return 2;
  fi
  local line_num=0;
  if [ -r "$properties_file" ]; then
    local p_key="";
    local p_val="";
    local line="";
    while read -r line || [ -n "$line" ]; do
      line_num=$((line_num+1));
      # ignore comments and blank lines
      if [[ ! -z "$line" && "$line" != \#* ]]; then
        # Check that the line is a key-value pair
        if [[ "$line" == *"="* ]]; then
          p_key=$(echo "$line" |cut -d= -f1);
          p_val=$(echo "$line" |cut -d= -f2);
          if (( $? != 0 )); then
            logW "Failed to process properties file:";
            logW "at: '$properties_file'";
            logW "Command 'cut' returned non-zero exit status.";
            logW "Default property values will be used";
            return 2;
          fi
          # Check against empty key and value
          if [[ -z "$p_key" || -z "$p_val" ]]; then
            invalid_format=true;
            invalid_line=$line_num;
          else
            declare -g $container["$p_key"]="$p_val";
          fi
        else
          invalid_format=true;
          invalid_line=$line_num;
        fi
      fi
    done < "$properties_file";
  else
    logW "The specified properties file does not exist or is not readable:";
    logW "at: '$properties_file'";
    return 2;
  fi
  if [[ $invalid_format == true ]]; then
    logW "The properties file is incorrectly formatted:";
    logW "at: '$properties_file' (at line $invalid_line)";
    return 1;
  fi
  return 0;
}

# [API function]
# Gets the property value for the specified key.
#
# This function queries the value for the specified key in
# the $PROPERTIES global variable and writes the result to $PROPERTY_VALUE.
# The default value to use is an optional argument. If it is not specified
# and the given key does not exist, then $PROPERTY_VALUE is set to an
# empty string.
#
# Args:
# $1 - The key of the property to get. Must be specified.
# $2 - The default value to use when the specified key does not exist.
#      This argument is optional.
#
# Returns:
# 0 - If the specified key was found in the available properties.
# 1 - If the specified key was not found in the available properties.
#
# Globals:
# PROPERTY_VALUE - Will hold the property value for the specified key once
#                  this function returns. Holds either the specified default
#                  value or an empty string if no property with such
#                  key exists.
# PROPERTIES     - The variable which contains the key-value pairs.
#                  Must be an already declared associative array.
#
# Examples:
# get_property "my.prop.key";
# echo "The value of 'my.prop.key' is '$PROPERTY_VALUE'";
#
# get_property "my.prop.key" "My Default Value";
# echo "The (default) value of 'my.prop.key' is '$PROPERTY_VALUE'";
#
function get_property() {
  local p_key="$1";
  local p_default_val="$2";
  # Check if the map contains the specified key
  if [[ "${PROPERTIES[$p_key]+1}" == "1" ]]; then
    # Set the value associated with the key
    PROPERTY_VALUE="${PROPERTIES[${p_key}]}";
    return 0;
  else
    # Set the specified default value
    PROPERTY_VALUE="$p_default_val";
    return 1;
  fi
}

# [API function]
# Gets the boolean property value for the specified key.
#
# This function queries the boolean value for the specified key in
# the $PROPERTIES global variable and writes the result to $PROPERTY_VALUE.
# It can be used instead of get_property() if the queried property is known
# to represent a boolean. If a malformed value is encountered, then a warning
# is logged. This function guarantees that after it returns
# the $PROPERTY_VALUE global variable is set to either 'true' or 'false'.
#
# The default boolean value to use is an optional argument. If it is
# not specified and the given key does not exist, or the specified default
# value does not represent a valid boolean, then $PROPERTY_VALUE is
# set to the string 'false'.
#
# Args:
# $1 - The key of the boolean property to get. Must be specified.
# $2 - The default boolean value to use when the specified key does not exist.
#      This argument is optional.
#
# Returns:
# 0 - If the specified key was found in the available properties.
# 1 - If the specified key was not found in the available properties.
#
# Globals:
# PROPERTY_VALUE - Will hold the boolean property value for the specified
#                  key once this function returns. Holds either the
#                  specified default value or the string "false" if no
#                  property with such key exists.
# PROPERTIES     - The variable which contains the key-value pairs.
#                  Must be an already declared associative array.
#
# Examples:
# get_boolean_property "my.prop.key";
# echo "The boolean value of 'my.prop.key' is '$PROPERTY_VALUE'";
#
# get_boolean_property "my.prop.key" "true";
# echo "The (default) boolean value of 'my.prop.key' is '$PROPERTY_VALUE'";
#
function get_boolean_property() {
  local p_key="$1";
  local p_default_val="$2";
  if [ -z "$p_default_val" ]; then
    p_default_val="false";
  fi
  if [[ "$p_default_val" != "true" && "$p_default_val" != "false" ]]; then
    logW "Programming error: Illegal function call:";
    logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    logW "Invalid argument \$2 to get_boolean_property() function:";
    logW "Expected boolean but found '$p_default_val'";
    logW "Default value must be specified as either 'true' or 'false'";
    p_default_val="false";
  fi
  get_property "$p_key" "$p_default_val";
  local key_found=$?;
  if [[ "$PROPERTY_VALUE" != "true" && "$PROPERTY_VALUE" != "false" ]]; then
    logW "Malformed boolean property with key '$p_key'";
    if [ -n "$PROPERTY_VALUE" ]; then
      logW "Invalid boolean value: '$PROPERTY_VALUE'";
    fi
    logW "For boolean properties only the values 'true' and 'false' are allowed.";
    PROPERTY_VALUE="$p_default_val";
  fi
  return $key_found;
}

# Runs the addons load-hook if available.
#
# This function can be safely called even when no addons are used.
# The hook is executed in a subprocess, for which both stdout and stderr
# are redirected to /dev/null
#
function _run_addon_load_hook() {
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    # Ignore load-hook if script does not exist
    if [ -f "$PROJECT_INIT_ADDONS_DIR/load-hook.sh" ]; then
      # Check if hook is executable
      if [ -x "$PROJECT_INIT_ADDONS_DIR/load-hook.sh" ]; then
        # Run hook script, in a subshell-process,
        # redirect stdout and stderr to /dev/null
        (cd "$PROJECT_INIT_ADDONS_DIR" \
            && exec "$PROJECT_INIT_ADDONS_DIR/load-hook.sh" > /dev/null 2>&1);

      else
        logW "The addons load hook is not marked as executable.";
        logW "Please set as executable: '$PROJECT_INIT_ADDONS_DIR/load-hook.sh'";
        _show_helptext "W" "Addons#hooks";
        warning "The load-hook of the Project Init script was not executed";
      fi
    fi
  fi
}

# Runs the addons after-init-hook if available.
#
# This function can be safely called even when no addons are used.
# The hook is executed in a subprocess, for which both stdout and stderr
# are redirected to /dev/null
#
function _run_addon_after_init_hook() {
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    # Ignore hook if script does not exist
    if [ -f "$PROJECT_INIT_ADDONS_DIR/after-init-hook.sh" ]; then
      # Check if hook is executable
      if [ -x "$PROJECT_INIT_ADDONS_DIR/after-init-hook.sh" ]; then
        logI "Running after-init hook";
        # Run hook script, in a subshell-process, define env var,
        # redirect stdout and stderr to /dev/null
        (cd "$PROJECT_INIT_ADDONS_DIR" \
            && export VAR_PROJECT_DIR="$var_project_dir"; \
            exec "$PROJECT_INIT_ADDONS_DIR/after-init-hook.sh" > /dev/null 2>&1);

      else
        logW "The addons after-init hook is not marked as executable.";
        logW "Please set as executable:" \
             "'$PROJECT_INIT_ADDONS_DIR/after-init-hook.sh'";
        _show_helptext "W" "Addons#hooks";

        warning "The after-init-hook of the Project Init script was not executed";
      fi
    fi
  fi
}

# Reads the specified 'files.txt' configuration file and populates
# the $LIST_FILES_TXT global variable with the found entries.
#
# This function can be used to load filenames and file patterns
# specified in a file, one per line. The found items are appended
# to the corresponding global variable.
#
# Args:
# $1 - The path to the 'files.txt' configuration file.
#      Must represent a valid file.
#
# Globals:
# LIST_FILES_TXT - Adds all found items to the array of filenames/file patterns.
#
function _fill_files_list_from() {
  local fpath="$1";
  if [ -r "$fpath" ]; then
    local line="";
    while read -r line || [ -n "$line" ]; do
      # Ignore comments and blank lines
      if [[ ! -z "$line" && "$line" != \#* ]]; then
        # Trim surrounding whitespaces
        local file_item="$(echo "$line" |xargs)";
        # Add item to global variable
        LIST_FILES_TXT+=("$file_item");
      fi
    done < "$fpath";
  else
    logW "Cannot load file list from file:";
    logW "at: '$fpath'";
    logW "File does not exist or is not readable";
  fi
}

# Loads the base system configuration files and stores the
# data in the corresponding global variables.
#
# The counterpart configuration files from the addons resource
# are also loaded by this function if applicable. This depends
# on the status of the $PROJECT_INIT_ADDONS_DIR global variable.
#
# This function also checks whether the test mode is activated and
# conditionally calls the _load_test_configuration() function if needed.
#
# Globals:
# PROPERTIES                 - The system properties. Is declared and initialized
#                              by this function.
# LIST_FILES_TXT             - The array of filenames/file patterns from files.txt
# PROJECT_INIT_ADDONS_DIR    - The path to the addons resource directory.
#                              If this is set to a non-empty string, then
#                              addons resources will be considered.
# _FLAG_CONFIGURATION_LOADED - Is set by this function.
#
function _load_configuration() {
  # Read in project properties
  declare -g -A PROPERTIES;
  _read_properties "project.properties";

  # Check for addons properties
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -f "$PROJECT_INIT_ADDONS_DIR/project.properties" ]; then
      _read_properties "$PROJECT_INIT_ADDONS_DIR/project.properties";
    fi
  fi

  # Check for user-specific properties
  if [ -n "$PROJECT_INIT_USER_PROPERTIES" ]; then
    if [ -r "$PROJECT_INIT_USER_PROPERTIES" ]; then
      _read_properties "$PROJECT_INIT_USER_PROPERTIES";
    fi
  else
    # Check user home directory
    if [ -n "$HOME" ]; then
      if [ -r "$HOME/project.properties" ]; then
        _read_properties "$HOME/project.properties";
      elif [ -r "$HOME/.project.properties" ]; then
        _read_properties "$HOME/.project.properties";
      fi
    fi
  fi

  # Load file declarations from the base configuration
  _fill_files_list_from "files.txt";

  # Check for addons files
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -f "$PROJECT_INIT_ADDONS_DIR/files.txt" ]; then
      # Load file declarations from the addons configuration
      _fill_files_list_from "$PROJECT_INIT_ADDONS_DIR/files.txt";
    fi
  fi

  # Check test configs
  if [[ "$PROJECT_INIT_TESTS_ACTIVE" == "1" ]]; then
    if [ -z "$PROJECT_INIT_TESTS_RUN_CONFIG" ]; then
      logE "Environment variable 'PROJECT_INIT_TESTS_ACTIVE' is set";
      logE "but 'PROJECT_INIT_TESTS_RUN_CONFIG' is missing";
      failure "Failed to execute test run";
    fi
    if [[ $(type -t _load_test_configuration) == function ]]; then
      _load_test_configuration;
    else
      logW "Environment variable 'PROJECT_INIT_TESTS_ACTIVE' is set";
      logW "but function _load_test_configuration() is not defined";
    fi
  fi

  _FLAG_CONFIGURATION_LOADED=true;
}

# Startup function for the Project Init system.
function start_project_init() {
  # Keep track of the current working directory of the user when he
  # executed the main script, even though we change it below to make
  # it easier throughout the Project Init system.
  USER_CWD="$PWD";
  # Script root directory
  SCRIPT_LVL_0_BASE="$(_get_script_path "${BASH_SOURCE[0]}")";
  CURRENT_LVL_PATH="$SCRIPT_LVL_0_BASE";
  CURRENT_LVL_NUMBER=0;
  # Ensure we are at level 0 base
  cd "$SCRIPT_LVL_0_BASE";

  _check_system_compat;

  _parse_args "$@";
  _handle_util_args;

  _setup_event_handlers;
  _load_addons_resource;

  # Check the addons dir env var and
  # adjust the paths if necessary
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if (( ${#PROJECT_INIT_ADDONS_DIR} > 1 )); then
      # Remove trailing slash
      PROJECT_INIT_ADDONS_DIR="${PROJECT_INIT_ADDONS_DIR%/}";
      _ADDONS_CURRENT_LVL_PATH="$PROJECT_INIT_ADDONS_DIR";
      _load_version_addons;

      # Check for addon icon override
      if [ -r "$PROJECT_INIT_ADDONS_DIR/icon.notif.png" ]; then
        _STR_NOTIF_SUCCESS_ICON="$PROJECT_INIT_ADDONS_DIR/icon.notif.png";
        _FLAG_NOTIF_SUCCESS_ICON_ADDON=true;
      fi
    fi
  fi

  _load_configuration;
  _check_system_dependencies;

  # Check for addons load hook
  _run_addon_load_hook;

  get_boolean_property "sys.starticon.show" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    _show_start_icon;
  fi
  get_boolean_property "sys.starttitle.show" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    _show_start_title;
  fi
  get_boolean_property "sys.starttext.show" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    _show_start_text;
  fi
}

# Finish function for the Project Init system.
function finish_project_init() {
  # Check that all API functions have been called
  if [[ ${_FLAG_PROJECT_FILES_COPIED} == false ]]; then
    _make_func_hl "project_init_copy";
    failure "The script in last init level was executed without a call to the"  \
            "$HYPERLINK_VALUE function. Please make sure that the 'init.sh'"    \
            "script in the lowermost init level calls the project_init_copy()"  \
            "function when ready.";
  fi
  if [[ ${_FLAG_PROJECT_LICENSE_PROCESSED} == false ]]; then
    _make_func_hl "project_init_license";
    failure "The script in last init level was executed without a call to the"     \
            "$HYPERLINK_VALUE function. Please make sure that the 'init.sh'"       \
            "script in the lowermost init level calls the project_init_license()"  \
            "function when ready. The function must always be called, even"        \
            "when no license was selected or there is no intention in using"       \
            "any license or copyright notice";
  fi
  if [[ ${_FLAG_PROJECT_FILES_PROCESSED} == false ]]; then
    _make_func_hl "project_init_process";
    failure "The script in last init level was executed without a call to the" \
            "$HYPERLINK_VALUE function. Please make sure that the"             \
            "'init.sh' script in the lowermost init level calls the"           \
            "project_init_process() function when ready.";
  fi
  # Check for addons after-init hook
  _run_addon_after_init_hook;
  # Finish
  _log_success;

  get_boolean_property "sys.notification.success.show" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    _show_notif_success;
  fi

  return $EXIT_SUCCESS;
}

# Sorts the given file paths according to the file names.
#
# This function sorts the specified strings denoting absolute
# paths to files. The sorted paths are dumped to stdout.
#
# Args:
# $@ - An arbitrary number of strings denoting file paths.
#      The strings must not contain any '?' characters.
#
# Stdout:
# The specified absolute paths, sorted by the file names,
# dumped to stdout.
#
# Examples:
# my_paths=( $(_sort_file_paths "${my_path_array[@]}") );
#
function _sort_file_paths() {
  local _fpaths=$@;
  for fpath in ${_fpaths}; do
    # Get the file name from the absolute path
    fname=$(basename "${fpath}");
    # Add the file name in front of the absolute path
    echo "${fname}?${fpath}";
  done |sort |cut -d? -f2
}

# [API function]
# Finds all files in the project directory indicated by
# the $var_project_dir variable.
#
# This function searches for the files specified in the $LIST_FILES_TXT
# global variable. The search is conducted in the project target directory
# and is done recursively. The paths to the found files are then cached
# in the $CACHE_ALL_FILES global variable.
#
# This function should be called every time the files in the project target
# directory are changed, i.e. files are added, moved, or deleted. Changes
# of the file contents are irrelevant. Calling this function ensures that
# the internally used file cache is up-to-date after the project
# structure has changed.
#
# Globals:
# LIST_FILES_TXT  - Used to get all file names and file patterns
#                   to search for, as an array
# CACHE_ALL_FILES - The variable in which all found files are saved.
# var_project_dir - The path to the project directory (target).
#
function find_all_files() {
  # Build arg string for find command
  file_args=();
  isfirst=true;
  for f in "${LIST_FILES_TXT[@]}"; do
    if [[ $isfirst == true ]]; then
      isfirst=false;
      # The first item does not have an '-o' option
      file_args+=(-name "$f");
    else
      file_args+=( -o -name "$f");
    fi
  done

  # List all files matching an ext or file name
  CACHE_ALL_FILES=$(find $var_project_dir/ -type f \( "${file_args[@]}" \));
  if (( $? != 0 )); then
    logE "Failed to update internal file cache:";
    logE "Command 'find' returned non-zero exit status.";
    failure "Failed to update internal file cache." \
            "Your system might be using an incompatible version of 'find'";
  fi
}

# [API function]
# Copies all project source template files to the project target directory.
#
# This function copies all files in the Project Init source directory to the
# Project Init target directory indicated by the $var_project_dir variable.
#
# The file cache for the project target files, which is represented by
# the $CACHE_ALL_FILES global variable, is populated with the paths to
# the copied files in the target directory as a result of this operation.
#
# The path to the project source template files can be optionally specified
# as an argument to this function.
#
# Args:
# $1 - The absolute path to the project source template directory.
#      This argument is optional. If not specified directly, then the
#      directory is assumed to be "$CURRENT_LVL_PATH/source",
#      i.e. the "source" directory in the lowermost init level
#
# Globals:
# var_project_dir  - The path to the project directory to which the files
#                    will be copied (target).
# var_project_name - The name of the project to initialize.
# CACHE_ALL_FILES  - The variable in which the paths to all copied files
#                    are saved.
# CURRENT_LVL_PATH - The path to the current init level dir.
#                    Used when no path arg is specified
#
function project_init_copy() {
  local files_source="$1";
  logI "";
  # Prompt for explicit confirmation if necessary
  get_boolean_property "sys.init.confirm" "false";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    logI "You are about to initialize a new software project.";
    logI "Do you want to continue? (Y/n)";
    read_user_input_yes_no true;
    answer=$USER_INPUT_ENTERED_BOOL;
    if [[ $answer == false ]]; then
      logI "Cancelling...";
      exit $EXIT_CANCELLED;
    fi
    logI "";
  fi

  # Set source directory if arg is not given
  if [[ "$files_source" == "" ]]; then
    files_source="$CURRENT_LVL_PATH/source";
  fi
  # Check if source is directory
  if ! [ -d "$files_source" ]; then
    logE "Project source template directory does not exist" \
         "or is not a directory:";
    logE "at: '$files_source'";
    failure "Project source template directory not found";
  fi

  # Check if target dir already exists, and create if necessary,
  # including all parent dirs
  if ! [ -d "$var_project_dir" ]; then
    logI "Creating project directory '${COLOR_CYAN}${var_project_dir}${COLOR_NC}'";
    mkdir -p "$var_project_dir";
    if (( $? != 0 )); then
      logE "Failed to create the project directory or one of its parents";
      failure "Failed to create the project directory or one of its parents." \
              "Please make sure that you have the filesystem rights"          \
              "to write at that location";
    fi
  else
    logI "Project directory already exists.";
    logI "Will initialize project in '${COLOR_CYAN}${var_project_dir}${COLOR_NC}'";
  fi

  logI "Initializing project ${COLOR_CYAN}${var_project_name}${COLOR_NC}";
  # Copy all template souce files to the target dir.
  # Include hidden files
  cp -R "$files_source/." "$var_project_dir/";
  if (( $? != 0 )); then
    logE "Failed to initialize the project in target directory:";
    logE "at: '$var_project_dir'";
    failure "Failed to copy project source files to the target project location";
  fi
  # Set file cache
  find_all_files;
  # Signal files have been copied
  _FLAG_PROJECT_FILES_COPIED=true;
}

# Removes all duplicates from the specified strings.
#
# This function returns all provided strings, dumped to stdout, while
# removing duplicates, i.e. all unique items are returned.
#
# Args:
# $@ - A series of strings to be filtered for uniqueness.
#
# Stdout:
# All unique strings in the series of specified strings, dumped to stdout.
#
function _unique_items() {
  local items=("$@");
  for item in ${items[@]}; do
    echo "$item";
  done |sort -u
}

# Validates that no unreplaced substitution variables are present in
# all files specified by the internal file cache.
#
# For each uniquely found substitution variable, a warning is shown
# to the user. It is searched for the standard substitution
# variable pattern "${{VAR_*}}" where "*" is the variable identifier.
# All substitution variables are replaced by an empty string.
#
# Returns:
# 0 - If no unreplaced vars could be found.
# 1 - If at least one unreplaced var was found.
#
# Globals:
# CACHE_ALL_FILES - The entries of all files that will be
#                   checked by this function.
#
function _check_unreplaced_vars() {
  local found_subvars=();
  for f in $CACHE_ALL_FILES; do
    # Check if file still exists
    if ! [ -f "$f" ]; then
      _make_func_hl "find_all_files";
      logW "Project file was removed but is still present in the file cache:";
      logW "at: '$f'";
      logW "Please call the $HYPERLINK_VALUE function after" \
           "adding/moving/deleting files";

      continue;
    fi
    # Seach for substitution variable pattern
    for subvar in $(grep -o '\${{VAR_[0-9A-Z_]\+}}' "$f"); do
      found_subvars+=("$subvar");
    done
  done

  # Check if at least one substitution var was found
  if (( ${#found_subvars[@]} > 0 )); then
    # Filter out duplicates to simplify warn messages
    found_subvars=( $(_unique_items "${found_subvars[@]}") );
    for subvar in "${found_subvars[@]}"; do
      local subvar_id="${subvar:3:-2}";
      logW "Substitution variable not replaced: '$subvar_id'";
      # Check for copyright header substitution variable
      if [[ "$subvar_id" == "VAR_COPYRIGHT_HEADER" ]]; then
        _make_func_hl "project_init_license";
        logW "Possible cause:";
        logW "Have you specified all file extensions in the call ";
        logW "to the $HYPERLINK_VALUE function?";
      fi
      # Replace with an empty string
      replace_var "$subvar_id" "";
    done
    warning "Unreplaced substitution variable detected. Project might not build or run";
    return 1;
  else
    return 0;
  fi
}

# Reads the specified extension_map.txt file and populates
# the $COPYRIGHT_HEADER_EXT_MAP global variable with the corresponding
# key-value pairs.
#
# Args:
# $1 - The extension map file to read.
#
# Returns:
# 0 - If the specified file file was successfully read.
# 1 - If the file could be read but is incorrectly formatted.
# 2 - If the specified file could not be read.
#
# Globals:
# COPYRIGHT_HEADER_EXT_MAP - The variable to which the read key-value pairs
#                            are written to. Must be an already declared
#                            associative array.
#
function _read_license_extension_map() {
  local ext_file="$1";
  local invalid_format=false;
  if [ -z "$ext_file" ]; then
    logE "Programming error: No file specified in call to _read_license_extension_map()";
    return 2;
  fi
  if [ -r "$ext_path" ]; then
    local ext_key="";
    local ext_val="";
    local line="";
    while read -r line || [ -n "$line" ]; do
      # Ignore comments and blank lines
      if [[ ! -z "$line" && "$line" != \#* ]]; then
        # Check that the line is a key-value pair
        if [[ "$line" == *"=>"* ]]; then
          # Split by separator and remove surrounding whitespaces
          ext_key=$(echo "$line" |awk -F'=>' '{print $1}' |xargs);
          ext_val=$(echo "$line" |awk -F'=>' '{print $2}' |xargs);
          # Check against empty key and value
          if [[ -z "$ext_key" || -z "$ext_val" ]]; then
            invalid_format=true;
          else
            COPYRIGHT_HEADER_EXT_MAP["$ext_key"]="$ext_val";
          fi
        else
          invalid_format=true;
        fi
      fi
    done < "$ext_file";
  else
    return 2;
  fi
  if [[ $invalid_format == true ]]; then
    logW "The license header extension map file is incorrectly formatted:";
    logW "at: '$ext_path'";
    return 1;
  fi
  return 0;
}

# Loads all found extension_map.txt files and populates
# the $COPYRIGHT_HEADER_EXT_MAP global variable with the corresponding
# key-value pairs.
#
# Globals:
# COPYRIGHT_HEADER_EXT_MAP - The variable to which the read key-value pairs
#                            are written to. This global associative array
#                            is created by this function.
#
function _load_extension_map() {
  declare -g -A COPYRIGHT_HEADER_EXT_MAP;
  local ext_file="extension_map.txt";
  local ext_path="$SCRIPT_LVL_0_BASE/licenses/$ext_file";
  # Read base file
  if [ -r "$ext_path" ]; then
    _read_license_extension_map "$ext_path";
  fi
  # Read addons extension map file
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    ext_path="$PROJECT_INIT_ADDONS_DIR/licenses/$ext_file";
    if [ -r "$ext_path" ]; then
      _read_license_extension_map "$ext_path";
    fi
  fi
}

# Indicates whether the specified string represents a valid absolute path
# to a project target directory.
#
# This function can be used to validate the given string representing
# an absolute path. This path can then be used to indicate the project target
# directory of the project to initialize. As the target directory may not
# exist yet, this function also checks whether the directory denoted by the
# specified path can be in principle created by the underlying user.
#
# If the specified string represents an invalid path, then this function will
# exit the program by means of the failure() function.
#
# Args:
# $1 - A string representing the absolute path to check.
#
# Returns:
# 0 - If the specified argument is a valid path.
#
function _check_is_valid_project_dir() {
  local arg_project_dir="$1";
  # Check for invalid paths
  if [[ "$arg_project_dir" == "/" ]]; then
    logE "Cannot create project directory in root directory '/'";
    failure "Please choose a valid project directory";
  fi
  # Check against double slashes
  if [[ "$arg_project_dir" == *"//"* ]]; then
    logE "Invalid path entered: '//' (double slashes)";
    failure "Please enter a valid project directory path";
  fi
  # Must be an absolute path
  if ! [[ "$arg_project_dir" == /* ]]; then
    logE "The entered path is not absolute";
    failure "Please enter a valid absolute path for the project directory";
  fi
  local existent_base_dir="$arg_project_dir";
  local found_existent_base_dir=false;
  # Traverse the path until an already existent
  # base directory is found. We need to check for
  # write permission on that directory later
  while [[ "$existent_base_dir" != "/" ]]; do
    if [ -d "$existent_base_dir" ]; then
      found_existent_base_dir=true;
      break;
    fi
    existent_base_dir=$(dirname "$existent_base_dir");
  done
  if [[ $found_existent_base_dir == false ]]; then
    logE "No valid base directory found";
    failure "Please enter a valid absolute path for the project directory";
  fi
  # Check for write permissions
  if ! [ -w "$existent_base_dir" ]; then
    logE "You do not have permission to write to the directory:"
    logE "at: '$existent_base_dir'";
    failure "Please enter a valid absolute path for the project directory" \
            "and make sure that you have the filesystem rights to write"   \
            "at that location";
  fi
  return 0;
}

# Queries the answer for the form question with the currently set question ID.
#
# The currently used question ID is taken from the value of
# the $FORM_QUESTION_ID global variable. It is reset by this function
# to an empty string. The queried form answer is stored in
# the $FORM_QUESTION_ANSWER global variable.
#
# Globals:
# FORM_QUESTION_ID     - The variable holding the question ID to use.
# FORM_QUESTION_ANSWER - The variable where the queried answer will be stored.
# _FORM_ANSWERS        - The associative array variable which is queried.
#                        Must be set before this function is called.
#
# Returns:
# 0 - If an answer is found and successfully set.
# 1 - If no answer is found for the underlying question ID.
# 2 - If no question ID was set.
#
function _get_form_answer() {
  if [ -z "$FORM_QUESTION_ID" ]; then
    FORM_QUESTION_ANSWER="";
    return 2;
  fi
  # Check if the map contains the specified key
  if [[ "${_FORM_ANSWERS[$FORM_QUESTION_ID]+1}" == "1" ]]; then
    # Set the value associated with the key
    FORM_QUESTION_ANSWER="${_FORM_ANSWERS[${FORM_QUESTION_ID}]}";
    FORM_QUESTION_ID="";
    return 0;
  else
    # Set to empty string
    FORM_QUESTION_ANSWER="";
    FORM_QUESTION_ID="";
    return 1;
  fi
}

# [API function]
# Shows the specified strings as numbered selection items and lets
# the user select one of them.
#
# This function can be used to present a pick list to the user and get the
# index of the selected item. The chosen index will be saved in
# the $USER_INPUT_ENTERED_INDEX global variable. The saved index is zero-based
# and represents a numeric type.
#
# The entered input of the user is checked for validity. In the case of
# an invalid input, such as an out of range selection number, this function
# will exit the program by means of the failure() function.
#
# A special case for the selection item is the occurrence of the "None" string.
# If the last specified item equals "None", then if the user chooses that item
# the $USER_INPUT_ENTERED_INDEX variable will be set to an empty string.
#
# Args:
# $@ - A series of selection items.
#
# Stdout:
# A selection list is printed.
#
# Returns:
# 0 - In the case of a valid item selection.
#
# Globals:
# USER_INPUT_ENTERED_INDEX - Will be set by this function to contain
#                            the zero-based index of the item selected
#                            by the user.
#
# Examples:
# my_list=("Item A" "Item B" "Item C");
# logI "Choose an item out of the list:";
# read_user_input_selection "${my_list[@]}";
# index=$USER_INPUT_ENTERED_INDEX;
# logI "Selected Item: ${my_list[index]}";
#
function read_user_input_selection() {
  local selection_names=("$@");
  local length=${#selection_names[@]};
  # Check that we have something to select
  if (( $length == 0 )); then
    _make_func_hl "read_user_input_selection";
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to $HYPERLINK_VALUE function: " \
            "No selection items specified";
  fi
  echo "";
  # Print all selectable options
  local number=0;
  for (( i=0; i<${length}; ++i )); do
    number=$((i+1));
    echo "[$number] ${selection_names[$i]}";
  done
  echo "";

  local prompt_input=$(echo -e "[${COLOR_CYAN}INPUT${COLOR_NC}] ");
  local selected_item="";
  if [[ "$PROJECT_INIT_TESTS_ACTIVE" == "1" ]]; then
    # In test mode. Print the configured answer
    _get_form_answer;
    selected_item="$FORM_QUESTION_ANSWER";
    echo -e "${prompt_input}${selected_item}";
  else
    # Read user input
    read -p "$prompt_input" selected_item;
  fi

  # Check special case for "None" option
  if [ -z "$selected_item" ]; then
    local last_item_index=$((length-1));
    local last_item="${selection_names[last_item_index]}";
    if [[ "$last_item" == "None" ]]; then
      USER_INPUT_ENTERED_INDEX="";
      return 0;
    fi
  fi

  # Validate user input
  local re="^[0-9]+$";
  if ! [[ $selected_item =~ $re ]]; then
    # Input is not a number.
    # Check if it matches one of the selection items
    local is_valid=false;
    for (( i=0; i<${length}; ++i )); do
      if [[ "$selected_item" == "${selection_names[$i]}" ]]; then
        selected_item=$((i+1));
        is_valid=true;
        break;
      fi
    done
    if [[ $is_valid == false ]]; then
      logE "Invalid input";
      failure "Please enter a valid number";
    fi
  fi
  if ((selected_item < 1 || selected_item > $length)); then
    logE "Invalid number entered";
    failure "Please enter the number of your selected item";
  fi

  local index=$((selected_item-1));
  USER_INPUT_ENTERED_INDEX=$index;

  get_boolean_property "sys.input.selection.numsubst" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    local selection_item="${selection_names[index]}";
    # Move cursor to line above and erase line
    echo -ne "\033[1A\033[2K";
    echo -e "[${COLOR_CYAN}INPUT${COLOR_NC}] $selection_item";
  fi

  return 0;
}

# [API function]
# Shows a prompt to the user and lets him enter arbitrary text.
#
# This function can be used to get text input from the user. The entered text
# will be saved in the $USER_INPUT_ENTERED_TEXT global variable. The saved
# text can be potentially empty if the user simply presses enter without
# actually entering any text.
#
# The entered input of the user is not checked for any kind of validity
# or pattern. If the entered text should be constrained further, this needs to
# be implemented by the calling code.
#
# Returns:
# 0 - In the case of a valid text input.
#
# Globals:
# USER_INPUT_ENTERED_TEXT  - Will be set by this function to contain the text
#                            entered by the user.
#
# Examples:
# logI "What's your name?";
# read_user_input_text;
# name=$USER_INPUT_ENTERED_TEXT;
# logI "Hi ${name}! Nice to meet you.";
#
function read_user_input_text() {
  local entered_text="";
  local prompt_input=$(echo -e "[${COLOR_CYAN}INPUT${COLOR_NC}] ");
  local entered_text="";
  if [[ "$PROJECT_INIT_TESTS_ACTIVE" == "1" ]]; then
    _get_form_answer;
    entered_text="$FORM_QUESTION_ANSWER";
    echo -e "${prompt_input}${entered_text}";
  else
    read -p "$prompt_input" entered_text;
  fi
  USER_INPUT_ENTERED_TEXT="$entered_text";
  return 0;
}

# [API function]
# Shows a prompt to the user and lets him answer a yes/no question.
#
# This function can be used to get a boolean input from the user.
# The entered text will be processed as a boolean and then saved in
# the $USER_INPUT_ENTERED_BOOL global variable. The saved value will
# represent the type bool.
#
# The entered input of the user is checked for validity, i.e. whether the
# entered text represents or can be converted to a valid boolean.
#
# Supported text values for the boolean value of true:
# "true", "yes", "y", "1"
#
# Supported text values for the boolean value of false:
# "false", "no", "n", "0"
#
# All accepted text input is case insensitive.
#
# If the entered value does not represent a valid boolean, then
# this function will exit the program by means of the failure() function.
#
# For the case where the user does not enter anything and simply presses
# enter, a default answer can be specified as the first argument
# to this function.
#
# Args:
# $1 - The default value to use if the user does not enter anything.
#      Must respresent a valid answer. This argument is optional.
#
# Returns:
# 0 - In the case of a valid text input.
#
# Globals:
# USER_INPUT_ENTERED_BOOL  - Will be set by this function to contain the boolean
#                            value corresponding to the entered text by the user.
#
# Examples:
# logI "Do you like cheese? (Y/n)";
# read_user_input_yes_no true;
# answer=$USER_INPUT_ENTERED_BOOL;
# if [[ $answer == true ]]; then
#   logI "You said that you like cheese.";
# else
#   logI "You said that you do not like cheese.";
# fi
#
function read_user_input_yes_no() {
  local default_value=$1;
  local prompt_input=$(echo -e "[${COLOR_CYAN}INPUT${COLOR_NC}] ");
  local entered_yes_no=="";
  if [[ "$PROJECT_INIT_TESTS_ACTIVE" == "1" ]]; then
    _get_form_answer;
    entered_yes_no="$FORM_QUESTION_ANSWER";
    echo -e "${prompt_input}${entered_yes_no}";
  else
    read -p "$prompt_input" entered_yes_no;
  fi
  # Validate user input
  if [ -z "$entered_yes_no" ]; then
    if [ -z "$default_value" ]; then
      logE "Invalid input";
      failure "Please enter either yes or no";
    else
      entered_yes_no=$default_value;
    fi
  fi
  local canonical_answer="";
  # Validate against supported pattern
  case "$entered_yes_no" in
    1|YES|yes|Yes|Y|y|true|True)
    entered_yes_no=true;
    canonical_answer="Yes";
    ;;
    0|NO|no|No|N|n|false|False)
    entered_yes_no=false;
    canonical_answer="No";
    ;;
    *)
    logE "Invalid input";
    failure "Please enter either yes or no";
    ;;
  esac
  USER_INPUT_ENTERED_BOOL=$entered_yes_no;

  get_boolean_property "sys.input.yesno.boolsubst" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    # Move cursor to line above and erase line
    echo -ne "\033[1A\033[2K";
    echo -e "[${COLOR_CYAN}INPUT${COLOR_NC}] $canonical_answer";
  fi

  return 0;
}

# [API function]
# Loads the variable value with the specified key from
# the corresponding var file.
#
# The argument represents the variable key for which a var file
# might exist in the current init level directory.
#
# This function only loads the variable value from its
# corresponding file. It does not assign that (global) variable
# the loaded value. The assignment has to be done manually
# if necessary.
#
# The loaded variable value is dumped to stdout.
# If no variable file can be found in the currently active init
# level directory, then an empty string is dumped to stdout by this function.
#
# Stdout:
# The string value of the variable with the specified key, or an
# empty string if the corresponding var file does not exist.
#
# Globals:
# CURRENT_LVL_PATH - The absolute path to the currently
#                    active init level directory.
#
# Examples:
# var_my_key="$(load_var MY_KEY)";
#
function load_var() {
  local arg_file="$1";
  # Convert to lower case
  arg_file=$(echo "$arg_file" |tr '[:upper:]' '[:lower:]');
  # Check for variable prefix
  if [[ "$arg_file" != var_* ]]; then
    arg_file="var_$arg_file";
  fi
  # Add file extension
  arg_file="$arg_file.txt";
  local var_content="";  # Default if no file is found
  # Load var content from file in current init level
  if [ -f "$CURRENT_LVL_PATH/$arg_file" ]; then
    # Read file content
    var_content="$(cat $CURRENT_LVL_PATH/$arg_file)";
  fi
  echo "$var_content";
}

# [API function]
# Replaces all occurrences of the specified variable with the specified value.
#
# This function will go through every file listed in the $CACHE_ALL_FILES
# global variable, find all occurrences of the substitution variable and replace
# them with the specified value. The variable key can be specified in its full
# canonical form or in an abbreviated form without the "VAR_"-prefix.
#
# The variable value can be any arbitrary string, including an empty string.
# Using an empty string will effectively remove the variable from the
# file (replacing it with nothing). If the variable key corresponds to the only
# characters on the respective line, then that entire line is removed from the
# underlying file.
# If only the variable key is specified, then this function will try to load
# the variable value from the corresponding var file by means of the load_var()
# function. If such a file does not exist, then the variable value is set to the
# empty string, thus potentially removing the entire line containing the variable
# from the underlying source file. Therefore, if a variable should be explicitly
# replaced by an empty string, regardless of any var file, then the value
# argument ($2) must be specified as an empty string.
#
# Besides the key and value, a third argument can be passed to this function.
# That argument represents the file ending by which all present files in the
# $CACHE_ALL_FILES global variable will be filtered by. That way, it is
# possible to replace the same variable with different values in
# different files. Only one file ending can be specified in each function call.
# A full file name (e.g. Readme.txt) may also be used as such an argument.
#
# Args:
# $1 - The name of the variable to replace. The "VAR_" prefix is optional
#      and can be omitted. This argument is mandatory.
# $2 - The value that the variable will be replaced by. Can be an empty string.
#      This argument is optional.
# $3 - The file extension or file name to match files against. Only files which
#      are matched are processed by this function. This argument is optional.
#
# Globals:
# CACHE_ALL_FILES - The entries of all files that will
#                   be processed by this function.
#
# Examples:
# replace_var "MY_KEY";
# replace_var "MY_KEY" "";
# replace_var "MY_KEY" "This will be the var value";
# replace_var "VAR_TEST" "value only in .java files" "java";
#
function replace_var() {
  local _all_files="$CACHE_ALL_FILES";
  local _arg_count=$#;
  local _var_key="$1";
  local _var_value="$2";
  local _var_file_ext="$3";
  # Check given args
  if (( ${_arg_count} == 0 )); then
    _make_func_hl "replace_var";
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to $HYPERLINK_VALUE function: " \
            "No arguments specified";
  fi
  if [ -z "${_var_key}" ]; then
    _make_func_hl "replace_var";
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to $HYPERLINK_VALUE function: " \
            "Key argument cannot be an empty string";
  fi
  if [ -z "${_all_files}" ]; then
    _make_func_hl "replace_var";
    local hl_replace_var="$HYPERLINK_VALUE";
    _make_func_hl "project_init_copy";
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to $hl_replace_var function: "       \
            "No source files found. Substitution variables can only be replaced " \
            "after the $HYPERLINK_VALUE function has been called";
  fi
  # Remove the 'VAR_' prefix if necessary as
  # it is set explicitly when using awk
  if [[ "${_var_key}" == VAR_* ]]; then
    _var_key="${_var_key:4}";
  fi

  for f in ${_all_files}; do
    # Check if a specific file extension was specified
    if [ -n "${_var_file_ext}" ]; then
      # Skip all file which do not have the specified extension
      if [[ "$f" != *${_var_file_ext} ]]; then
        continue;
      fi
    fi
    # Check whether the file can be read
    if ! [ -r "$f" ]; then
      if [[ ${_FLAG_FCACHE_ERR} == false ]]; then
        _make_func_hl "find_all_files";
        logW "Project files seem to have changed but the" \
             "file cache was not updated.";
        logW "Please call the $HYPERLINK_VALUE function after" \
             "adding/moving/deleting files";
      fi
      # Set the global file cache error flag to signal
      # that the cache should be refreshed
      _FLAG_FCACHE_ERR=true;
      continue;
    fi

    # If this function was called with only the key arg, then we
    # load the var value from the corresponding var file
    if [ -z "${_var_value}" ]; then
      if (( ${_arg_count} == 1 )); then
        # If the file does not exist, then the empty string
        # is assigned to the variable value
        _var_value="$(load_var ${_var_key})";
      fi
    fi
    # For an enhanced formatting we remove every line entirely if
    # it contains only a variable declaration and the given variable
    # value is empty. Otherwise the handled file would contain
    # additional blank lines.
    if [ -z "${_var_value}" ]; then
      # Find all line numbers of lines containing the given variable key
      for line_num in $(grep -n "\${{VAR_${_var_key}}}" "$f" \
                          |awk -F  ":" '{print $1}'); do

        # Get the line text and trim leading and trailing whitespaces
        local line="$(sed -n "${line_num}p" < "$f" |xargs)";
        if [[ "$line" == "\${{VAR_${_var_key}}}" ]]; then
          # The line only contains the given variable key
          # without any other static text. So we remove that
          # line from the string
          local removed="$(awk 'NR!~/^('"$line_num"')$/' "$f")";
          # Overwrite the source file
          echo "$removed" > "$f";
        fi
      done
    fi

    # Replace declared variable
    local replaced="$(awk -v key='\\${{VAR_'"${_var_key}"'}}' \
                          -v value="${_var_value}"            \
                          '{ gsub(key, value); print; }'      \
                          "$f")";

    # Remove leading control characters.
    # The following solution using bash-builtins is really slow:
    # shopt -s extglob;
    # replaced="${replaced##+([[:cntrl:]])}";

    # We therefore do the following using external utilities:
    # Find the index of the line containing the first printable char.
    # Note: Since grep below immediately exits when it finds the first
    # printable char, echo might still be writing to the then
    # broken pipe. This is harmless here but we want to suppress
    # the message which is then printed to stderr.
    local index="$(echo "$replaced" 2> /dev/null \
                  |grep -n -m 1 "[[:print:]]"    \
                  |awk -F ":" '{print $1}')";

    # Convert to zero-based index
    index=$((index-1));
    # Trim the file content string
    replaced="${replaced:index}";

    # Write formatted text to file
    echo "$replaced" > "$f";
  done
}

# [API function]
# Processes the license and copyright information for the
# project to be initialized.
#
# This function copies to the project target directory all relevant files with
# regard to legal information, such as license text files. Furthermore, it is
# also responsible for setting up copyright boilerplate text in code
# source files. As part of this process, the corresponding variables are
# replaced by the correct values.
#
# The file extensions of all project source code files for which copyright
# information should be set must be specified as arguments to this function.
# Otherwise copyright substitution variables are not replaced by their
# corresponding boilerplate text.
#
# Args:
# $@ - A series of file extensions representing the project source files in
#      which license and copyright information should be processed.
#
# Globals:
# var_project_dir         - The path to the project directory to which
#                           the files will be copied (target).
# var_project_license     - The name of the license applied
#                           to the target project.
# var_project_license_dir - The absolute path to the license template
#                           source directory where all license and copyright
#                           information is stored for the
#                           concrete license type.
#
# Examples:
# project_init_license "java" "xml" "js";
#
function project_init_license() {
  local all_file_ext="$@";
  # Check API call order
  if [[ ${_FLAG_PROJECT_FILES_COPIED} == false ]]; then
    _make_func_hl "project_init_license";
    local _hl_project_init_license="$HYPERLINK_VALUE";
    _make_func_hl "project_init_copy";
    local _hl_project_init_copy="$HYPERLINK_VALUE";
    logE "Programming error in init script:";
    logE "at: '${CURRENT_LVL_PATH}/init.sh' (line ${BASH_LINENO[0]})";
    failure "Missing call to project_init_copy() function:"                              \
            ""                                                                           \
            "The script in init level $CURRENT_LVL_NUMBER has called the "               \
            "${_hl_project_init_license} function without having previously called "     \
            "the ${_hl_project_init_copy} function. Please make sure that the 'init.sh'" \
            "script calls all mandatory API functions in the correct order."             \
            "";
  fi

  if [ -z "$all_file_ext" ]; then
    _make_func_hl "project_init_license";
    logW "No file extensions specified in the call" \
         "to the $HYPERLINK_VALUE function.";
    logW "Copyright header variables in source files will not be replaced.";
    logW "Please specify in the call to the project_init_license() function all file";
    logW "extensions of project source files for which copyright headers exist";
    warning "Copyright header variables could not be replaced";
  fi
  # Check if a license was specified by the user
  if [ -n "$var_project_license_dir" ]; then
    if [ "$var_project_license_dir" != "NONE" ]; then
      # Copy the main license file
      if [ -r "$var_project_license_dir/license.txt" ]; then
        cp "$var_project_license_dir/license.txt" "$var_project_dir/LICENSE";
        if (( $? != 0 )); then
          logE "An error occurred while trying to copy the following file:";
          logE "Source: '$var_project_license_dir/license.txt'";
          logE "Target: '$var_project_dir/LICENSE'";
          failure "Failed to copy license file to project directory";
        fi

        # The content of the target directory has changed.
        # Update the list of relevant files
        find_all_files;
      else
        logW "License file could not be created.";
        logW "Failed to find license legal text file for '$var_project_license'.";
        logW "Please add the legal text to the" \
             "file '$var_project_license_dir/license.txt'.";
        warning "The initialized project has a missing 'LICENSE' file";
      fi
      # Set up copyright headers in all specified files
      _load_extension_map;
      for file_ext in $all_file_ext; do
        local header_ext="$file_ext";
        # Check if the file extension is mapped to some other extension
        if [[ "${COPYRIGHT_HEADER_EXT_MAP[$header_ext]+1}" == "1" ]]; then
          header_ext="${COPYRIGHT_HEADER_EXT_MAP[${header_ext}]}";
        fi
        local var_copyright_header="";
        local copyright_header_file="$var_project_license_dir/header.$header_ext";
        if [ -r "$copyright_header_file" ]; then
          # Read in the license declaration legal text from the file
          var_copyright_header=$(cat "$copyright_header_file");
        else
          logW "License header template file not found for '$var_project_license'";
          logW "Please create a template" \
               "file '$var_project_license_dir/header.$header_ext'";
        fi
        # First substitute the header var and then later the
        # year and copyright holder vars inside the header
        replace_var "COPYRIGHT_HEADER" "$var_copyright_header" "$file_ext";
      done
    fi

    # Replace additional copyright info vars, which also might be
    # part of the copyright boilerplate text already inserted
    replace_var "COPYRIGHT_YEAR"   "$var_copyright_year";
    replace_var "COPYRIGHT_HOLDER" "$var_copyright_holder";
    replace_var "PROJECT_LICENSE"  "$var_project_license";
    if [[ $var_project_license_dir == "NONE" ]]; then
      replace_var "LICENSE_README_NOTE" "This project has not been licensed.";
      # Remove all copyright vars
      replace_var "COPYRIGHT_HEADER" "";
    else
      replace_var "LICENSE_README_NOTE" \
                  "This project is licensed under $var_project_license.";
    fi
  fi
  # Signal license is set up
  _FLAG_PROJECT_LICENSE_PROCESSED=true;
}

# [API function]
# Processes the project source template files copied to the project
# target directory.
#
# This function replaces some generally applicable substitution variables and
# then proceeds to call the process_files_lvl_*() functions in
# their corresponding init level order.
#
# Globals:
# var_project_*      - Various global variables holding general
#                      project information.
# CURRENT_LVL_NUMBER - The number of the current active init level.
#
function project_init_process() {
  # Check API call order
  if [[ ${_FLAG_PROJECT_LICENSE_PROCESSED} == false ]]; then
    _make_func_hl "project_init_process";
    local _hl_project_init_process="$HYPERLINK_VALUE";
    _make_func_hl "project_init_license";
    local _hl_project_init_license="$HYPERLINK_VALUE";
    logE "Programming error in init script:";
    logE "at: '${CURRENT_LVL_PATH}/init.sh' (line ${BASH_LINENO[0]})";
    failure "Missing call to project_init_license() function:"                              \
            ""                                                                              \
            "The script in init level $CURRENT_LVL_NUMBER has called the "                  \
            "${_hl_project_init_process} function without having previously called "        \
            "the ${_hl_project_init_license} function. Please make sure that the 'init.sh'" \
            "script calls all mandatory API functions in the correct order."                \
            "";
  fi

  replace_var "PROJECT_NAME"               "$var_project_name";
  replace_var "PROJECT_NAME_LOWER"         "$var_project_name_lower";
  replace_var "PROJECT_NAME_UPPER"         "$var_project_name_upper";
  replace_var "PROJECT_DESCRIPTION"        "$var_project_description";
  replace_var "PROJECT_DIR"                "$var_project_dir";
  replace_var "PROJECT_ORGANISATION_NAME"  "$var_project_organisation_name";
  replace_var "PROJECT_ORGANISATION_URL"   "$var_project_organisation_url";
  replace_var "PROJECT_ORGANISATION_EMAIL" "$var_project_organisation_email";
  replace_var "PROJECT_LANG"               "$var_project_lang";
  replace_var "PROJECT_SLOGAN_STRING"      "$var_project_slogan_string";

  # Call all functions for processing project files in the level order
  local max_lvl_number=$CURRENT_LVL_NUMBER;
  local max_lvl_path=$CURRENT_LVL_NUMBER;
  local _varname_script_lvl_path="";
  for lvl in $(seq 1 $max_lvl_number); do
    # Check if function in this level is declared
    if [[ $(type -t "process_files_lvl_${lvl}") == function ]]; then
      # Adjust global vars as functions are located in different levels
      CURRENT_LVL_NUMBER=$lvl;
      _varname_script_lvl_path="SCRIPT_LVL_${lvl}_BASE";
      CURRENT_LVL_PATH="${!_varname_script_lvl_path}";
      # Call function
      process_files_lvl_${lvl};
    fi
  done

  # Reset vars
  CURRENT_LVL_NUMBER=$max_lvl_number;
  CURRENT_LVL_PATH="$max_lvl_path";

  _check_unreplaced_vars;
  if (( $? != 0 )); then
    _make_func_hl "replace_var";
    logW "";
    logW "Substitution variables for which no value was specified were";
    logW "removed from the project source files.";
    logW "";
    logW "Please specify a value in the corresponding init script by";
    logW "calling the $HYPERLINK_VALUE function";
  fi

  # Signal files have been processed
  _FLAG_PROJECT_FILES_PROCESSED=true;
}

# [API function]
# Adds the specified language standard version and its corresponding label to
# the list of supported language versions.
#
# This function can be called by init code to specify that a particular
# project does support the given language standard.
# The arguments represent the plain version number (e.g. "17" for C++ version 17)
# and the corresponding label string (e.g. "C++17") used when such
# versions are displayed.
# If the specified version number is already supported, then the function
# call has no effect.
#
# Args:
# $1 - The version number to add. This argument is mandatory.
# $2 - The version label to add. This argument is mandatory.
#
# Globals:
# SUPPORTED_LANG_VERSIONS_IDS    - The array holding all supported
#                                  language version numbers.
# SUPPORTED_LANG_VERSIONS_LABELS - The array holding all supported
#                                  language version labels.
#
# Examples:
# add_lang_version "99" "C99";
# add_lang_version "17" "C++17";
# add_lang_version "8" "Java8";
#
function add_lang_version() {
  local _lang_version_num="$1";
  local _lang_version_str="$2";
  if [ -z "${_lang_version_num}" ]; then
    _make_func_hl "add_lang_version";
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to $HYPERLINK_VALUE function: " \
            "No version number specified";
  fi
  if [ -z "${_lang_version_str}" ]; then
    _make_func_hl "add_lang_version";
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to $HYPERLINK_VALUE function: " \
            "No version label specified";
  fi
  if [[ ! "${SUPPORTED_LANG_VERSIONS_IDS[*]}" =~ "${_lang_version_num}" ]]; then
    SUPPORTED_LANG_VERSIONS_IDS+=("${_lang_version_num}");
    SUPPORTED_LANG_VERSIONS_LABELS+=("${_lang_version_str}");
  fi
}

# [API function]
# Removes the specified language standard from the list
# of supported language versions.
#
# This function can be called by init code to specify that a particular
# project does not support the given language standard.
# The argument represents the plain version number, e.g. "17" for C++ version 17.
# If the specified version number is not currently supported anyway, then
# the function call has no effect.
#
# Args:
# $1 - The version number to remove. This argument is mandatory.
#
# Globals:
# SUPPORTED_LANG_VERSIONS_IDS    - The array holding all supported
#                                  language version numbers.
# SUPPORTED_LANG_VERSIONS_LABELS - The array holding all supported
#                                  language version labels.
#
# Examples:
# remove_lang_version "17";
#
function remove_lang_version() {
  local _lang_version="$1";
  if [ -z "${_lang_version}" ]; then
    _make_func_hl "remove_lang_version";
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to $HYPERLINK_VALUE function: " \
            "No arguments specified";
  fi
  for i in "${!SUPPORTED_LANG_VERSIONS_IDS[@]}"; do
    if [[ "${SUPPORTED_LANG_VERSIONS_IDS[$i]}" == "${_lang_version}" ]]; then
      unset 'SUPPORTED_LANG_VERSIONS_IDS[$i]';
      unset 'SUPPORTED_LANG_VERSIONS_LABELS[$i]';
      # We need to recreate both arrays as their indices might not
      # match anymore because of the unset operation
      SUPPORTED_LANG_VERSIONS_IDS=("${SUPPORTED_LANG_VERSIONS_IDS[@]}");
      SUPPORTED_LANG_VERSIONS_LABELS=("${SUPPORTED_LANG_VERSIONS_LABELS[@]}");
      break;
    fi
  done
}

# [API function]
# Clears all set language versions and their corresponding labels from
# the list of supported language standards.
#
# Globals:
# SUPPORTED_LANG_VERSIONS_IDS    - The array holding all supported
#                                  language version numbers.
# SUPPORTED_LANG_VERSIONS_LABELS - The array holding all supported
#                                  language version labels.
#
function clear_lang_versions() {
  SUPPORTED_LANG_VERSIONS_IDS=();
  SUPPORTED_LANG_VERSIONS_LABELS=();
}

# [API function]
# Prompts the user to select the next init directory.
#
# This function searches for subordinate init level directories under the currently
# active init level directory and lets the user select the next init level directory
# into which to descend. The path to the currently active init level is taken from
# the $CURRENT_LVL_PATH global variable. At least one subordinate init level
# directory must exist at the time this function is called, otherwise the program
# is terminated by means of the failure() function.
#
# The found init level directories are presented to the user by a call to
# the read_user_input_selection() function. The result of that operation is handled
# by this function, which sets the global variables $SELECTED_NEXT_LEVEL_DIR and
# $SELECTED_NEXT_LEVEL_DIR_NAME to indicate the user selection.
# Please note that this function does not show any questions to the user. It only
# displays the selection of init level directories. Any appropriate questions must
# be handled by the caller prior to calling this function.
# The result of this function can then be used, for example, as an argument to
# the proceed_next_level() function to perform the actual descent into the next
# init level.
#
# Globals:
# SELECTED_NEXT_LEVEL_DIR      - The name of the directory of the init level selected
#                                by the user. This is the name of the directory in
#                                the filesystem. Is set by this function.
# SELECTED_NEXT_LEVEL_DIR_NAME - The display name of the directory of the init level
#                                selected by the user. This is the name as defined by
#                                the 'name.txt' file of the selected init directory.
#                                Is set by this function.
# CURRENT_LVL_PATH             - The path to the active init level directory are the
#                                time this function is called. Is used to search for
#                                subordinate init level directories under this path.
#
# Examples:
# logI "Select the next init level directory:";
# select_next_level_directory;
#
# selected_dir="$SELECTED_NEXT_LEVEL_DIR";
# selected_dir_name="$SELECTED_NEXT_LEVEL_DIR_NAME";
# logI "You have selected '$selected_dir_name' which is directory '$selected_dir'";
#
# proceed_next_level "$selected_dir";
#
function select_next_level_directory() {
  local next_dirs=();
  local next_names=();
  # Take path at current init level
  for dir in $(ls -d "$CURRENT_LVL_PATH"/*); do
    if [ -d "$dir" ]; then
      local dir_name=$(basename "$dir");
      if [ -f "$dir/init.sh" ]; then
        next_dirs+=("$dir_name");
        if [ -r "$dir/name.txt" ]; then
          local name=$(cat "$dir/name.txt");
          next_names+=("$name");
        else
          logW "Project init level directory '$dir_name' has no name file:";
          logW "at: '$dir'";
          next_names+=("$dir_name");
        fi
        # Check for invalid characters
        if [[ "$dir" == *"?"* ]]; then
          logE "Invalid path encountered:";
          logE "'$dir'";
          logE "Path contains an invalid character: '?'";
          failure "One or more paths to a component has an invalid character." \
                  "Please make sure that the path to any directory does not"   \
                  "contain '?' characters";

        fi
      fi
    fi
  done
  local n_dirs=${#next_dirs[@]};
  if (( $n_dirs == 0 )); then
    _make_func_hl "select_next_level_directory";
    logE "Cannot descend to next init level. No init level directories found";
    failure "You have called the $HYPERLINK_VALUE function:"              \
            "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})"            \
            ""                                                            \
            "No subordinate init directory is available at that level."   \
            "Add at least one init directory (with an 'init.sh' script)"  \
            "at that location and try again.";
  fi

  local selected_name="";
  local selected_dir="";
  # Automatically pick the only available init directory if there is only one
  if (( $n_dirs > 1 )); then
    read_user_input_selection "${next_names[@]}";
    selected_dir=${next_dirs[USER_INPUT_ENTERED_INDEX]};
    selected_name=${next_names[USER_INPUT_ENTERED_INDEX]};
  else
    selected_dir=${next_dirs[0]};
    selected_name=${next_names[0]};
  fi
  # Set global vars to selected values
  SELECTED_NEXT_LEVEL_DIR="$selected_dir";
  SELECTED_NEXT_LEVEL_DIR_NAME="$selected_name";
}

# [API function]
# Shows the form question for the project type selection.
#
# This function lets the user select one out of the available project
# types for the previously chosen programming language and sets the
# $FORM_PROJECT_TYPE_NAME and $FORM_PROJECT_TYPE_DIR global variables
# to reflect the user choice.
#
# Args:
# $1 - The ID of the project language to be used. This arg represents
#      the name of the language subdirectory where the project type
#      subdirectories are located.
# $2 - The human readable name of the language to be used.
#
# Returns:
# 0 - In the case of a valid project type selection.
#
# Globals:
# FORM_PROJECT_TYPE_NAME - The name selected out of the project
#                          type list displayed to the user.
# FORM_PROJECT_TYPE_DIR  - The path to the directory of the
#                          selected project type.
#
# Examples:
# select_project_type "js" "JavaScript";
# selected_name="$FORM_PROJECT_TYPE_NAME";
# selected_dir="$FORM_PROJECT_TYPE_DIR";
#
function select_project_type() {
  local lang_id="$1";
  local lang_name="$2";
  if [ -z "$lang_id" ]; then
    _make_func_hl "select_project_type";
    logE "Programming error: Illegal function call:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Programming error: Invalid call to $HYPERLINK_VALUE function: " \
            "No language ID argument specified";
  fi
  if [ -z "$lang_name" ]; then
    _make_func_hl "select_project_type";
    logW "No language name argument specified in call" \
         "to $HYPERLINK_VALUE function:";
    logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    lang_name="$lang_id";
  fi
  # Check current init level
  if (( $CURRENT_LVL_NUMBER != 1 )); then
    _make_func_hl "select_project_type";
    logE "Project types can only be selected at init level 1.";
    logE "The call to the $HYPERLINK_VALUE function was made:";
    logE "at init level: $CURRENT_LVL_NUMBER";
    logE "at: '$CURRENT_LVL_PATH'";
    failure "Programming error: Invalid call to $HYPERLINK_VALUE function."      \
            "Project types under a given language can only be selected while at" \
            "init level 1";
  fi
  # Array for storing the paths to all project
  # template dirs provided by the language
  local all_ptypes=();
  if [[ ${_FLAG_PROJECT_LANG_IS_FROM_ADDONS} == false ]]; then
    get_boolean_property "${lang_id}.baseprojects.disable" "false";
    if [[ "$PROPERTY_VALUE" == "false" ]]; then
      for dir in $(ls -d "$CURRENT_LVL_PATH"/*); do
        if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
          local ptype_id="$(basename $dir)";
          if [ -f "$PROJECT_INIT_ADDONS_DIR/${lang_id}/${ptype_id}/DISABLE" ]; then
            continue;
          fi
        fi
        all_ptypes+=("$dir");
      done
    fi
  fi

  # Add projects templates from addons
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -d "$PROJECT_INIT_ADDONS_DIR/$lang_id" ]; then
      all_ptypes+=("$PROJECT_INIT_ADDONS_DIR/$lang_id/*");
      # Check if the separator char used in the sort function
      # is part of one of the path strings
      for fpath in ${all_ptypes[@]}; do
        if [[ "$fpath" == *"?"* ]]; then
          logE "Invalid path encountered:";
          logE "'$fpath'";
          logE "Path contains an invalid character: '?'";
          failure "One or more paths to a component of an addon has an invalid character." \
                  "Please make sure that the path to the addons directory does not"        \
                  "contain '?' characters";
        fi
      done
      all_ptypes=( $(_sort_file_paths "${all_ptypes[@]}") );
    fi
  fi

  # Construct the list of project dirs and names
  local project_type_dirs=();
  local project_type_names=();

  # Loop over all paths and filter viable candidates
  # representing base project types
  for dir in "${all_ptypes[@]}"; do
    if [ -d "$dir" ]; then
      local dir_name=$(basename "$dir");
      if [ -f "$dir/init.sh" ]; then
        project_type_dirs+=("$dir");
        if [ -r "$dir/name.txt" ]; then
          local name=$(cat "$dir/name.txt");
          project_type_names+=("$name");
        else
          logW "Project init type directory '$dir_name' has no name file:";
          logW "at: '$dir'";
          project_type_names+=("$dir_name");
        fi
      fi
    fi
  done

  logI "";
  # Check that at least one project type can be selected
  local n_ptypes=${#project_type_dirs[@]};
  if (( $n_ptypes == 0 )); then
    logE "Cannot prompt for project type selection. No options available";
    failure "You have chosen to create a project using $lang_name,"     \
            "however, no type of $lang_name project can be initialized" \
            "because no project template files could be found."         \
            "Please add at least one project type directory under"      \
            "the '$lang_id' folder.";
  fi

  # Either prompt for a selection or automatically pick the
  # only available project type
  if (( $n_ptypes > 1 )); then
    FORM_QUESTION_ID="project.type";
    logI "Select the type of $lang_name project to be created:";
    read_user_input_selection "${project_type_names[@]}";
    local selected_name=${project_type_names[USER_INPUT_ENTERED_INDEX]};
    local selected_dir=${project_type_dirs[USER_INPUT_ENTERED_INDEX]};
  else
    local selected_name=${project_type_names[0]};
    local selected_dir=${project_type_dirs[0]};
  fi

  # Update the current init level absolute path so that the proceed_next_level()
  # function finds the correct directory in the case that an addon project type
  # was selected. If a normal base project type was selected, then the following
  # assignment has no effect as it assigns the current path
  CURRENT_LVL_PATH=$(dirname "$selected_dir");
  # Set result vars
  FORM_PROJECT_TYPE_NAME="$selected_name";
  FORM_PROJECT_TYPE_DIR="$selected_dir";
  return 0;
}

# [API function]
# Proceeds to the next applicable init level and sources its init.sh script.
#
# This function should be called when the next init level is ready
# to be loaded. The directory name for the next init level, relative to the
# currently active init level directory, should be passed as an argument
# to this function. If that argument is omitted, the first directory containing
# an init.sh script will be automatically used as the next init level.
# If no such directory can be found inside the currently active init
# level directory, then this function will terminate the program
# by means of the failure() function.
#
# The global variables $CURRENT_LVL_PATH, $CURRENT_LVL_NUMBER are changed
# accordingly to reflect the changed init level. Additionally, for each
# immersion into the next init level, a supplementary global
# variable $SCRIPT_LVL_\*_BASE is declared by this function to point to
# the corresponding init level directory, where the '\*' corresponds to
# the init level number.
#
# Args:
# $1 - The directory containing the init.sh script for the next init level.
#      This argument is optional although it should always be specified.
#
# Globals:
# CURRENT_LVL_PATH   - The absolute path to the currently active
#                      init level directory. Will be set to the
#                      next init level.
# CURRENT_LVL_NUMBER - The number of the current active init level. Will be
#                      incremented by one to reflect the changed init level.
# SCRIPT_LVL_*_BASE  - Will be set to the next init level directory path,
#                      according to the corresponding init level number (*).
#
# Examples:
# proceed_next_level "my_level_dir";
#
function proceed_next_level() {
  # Only take the directory name not the full path
  local dir_next="$(basename "$1")";
  if [[ "$dir_next" == "" ]]; then
    # Search all subdirs in current level dir
    # and pick the first applicable as the next
    for dir in $(ls -d $CURRENT_LVL_PATH/*); do
      if [ -f "${dir}/init.sh" ]; then
        dir_next="$(basename $dir)";
        logW "No next init directory specified in current" \
             "init level $CURRENT_LVL_NUMBER";
        logW "at '$CURRENT_LVL_PATH'";
        logW "Automatically selected directory '$dir_next' for" \
             "proceeding to next init level";

        break;
      fi
    done
    # Check again if any applicable dir was found
    if [[ "$dir_next" == "" ]]; then
      _make_func_hl "proceed_next_level";
      logE "Cannot find directory to source next init script";
      _show_helptext "E" "Introduction#init-levels";
      failure "Failed to proceed to next init level from current level directory:" \
              "at: '$CURRENT_LEVEL_PATH'" "  "                                     \
              "Please specify the directory for the next init level in your"       \
              "call to the $HYPERLINK_VALUE function";
    fi
  fi
  # Set global vars to new values
  CURRENT_LVL_PATH="$CURRENT_LVL_PATH/$dir_next";
  CURRENT_LVL_NUMBER=$((CURRENT_LVL_NUMBER + 1));
  declare SCRIPT_LVL_${CURRENT_LVL_NUMBER}_BASE="$CURRENT_LVL_PATH";

  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    _ADDONS_CURRENT_LVL_PATH="${_ADDONS_CURRENT_LVL_PATH}/$dir_next";
  fi

  # Check whether directory and level script can be sourced
  if ! [ -d "$CURRENT_LVL_PATH" ]; then
    logE "Cannot source init script for level $CURRENT_LVL_NUMBER";
    _show_helptext "E" "Introduction#init-levels";
    failure "Failed to source init script for next init level:" \
            "at: '$CURRENT_LVL_PATH':"                          \
            "Directory does not exist";
  fi

  # Check for notification icons.
  # First check dynamic icon based on init levels
  if [[ ${_FLAG_NOTIF_SUCCESS_ICON_ADDON} == false ]]; then
    if [ -r "$CURRENT_LVL_PATH/icon.notif.png" ]; then
      # Set new icon from base resources
      _STR_NOTIF_SUCCESS_ICON="$CURRENT_LVL_PATH/icon.notif.png";
    fi
  fi
  # Then check for addon override
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -r "${_ADDONS_CURRENT_LVL_PATH}/icon.notif.png" ]; then
      # Override icon from addons resource
      _STR_NOTIF_SUCCESS_ICON="${_ADDONS_CURRENT_LVL_PATH}/icon.notif.png";
      _FLAG_NOTIF_SUCCESS_ICON_ADDON=true;
    fi
  fi

  # Set new init script ot load
  local next_lvl_script="$CURRENT_LVL_PATH/init.sh";

  if ! [ -f "$next_lvl_script" ]; then
    logE "Cannot source init script for level $CURRENT_LVL_NUMBER";
    _show_helptext "E" "Introduction#init-scripts";
    failure "Failed to source init script for next init level." \
            "Script does not exist: "                           \
            "File: '$next_lvl_script'";
  fi

  source "$next_lvl_script";
}
