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
# *                  ***   Project Init Core Libraries   ***                  *
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
# API users if their identifying name is written in all caps, unless the
# corresponding documentation states that the variable can be used otherwise.
# Do not manually assign a value to read-only global variables.
# The values of variables whose identifying name starts with an underscore
# should only be changed by functions defined in this file or init system code.
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
# corresponding shell variable. The replace_var() function implements
# this mechanism.
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
# project source files are processed and potentially changed, renamed or moved.
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
# the initialized project contains syntactically correct source code and can
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
# The library code in this file does not implement the concrete form to
# be shown to the user. This has to be provided separately. However, as part
# of the API contract, any consuming component must ensure that the library
# lifecycle functions are called in the appropriate order. That is:
#   * project_init_start()
#   * project_init_finish()
#
# In between these function calls, a consuming component may use any
# provided API function to implement a concrete project initialization form
# and descend into more init levels.
#
# When the arguments given to the project_init_start() lifecycle function
# result in the activation of the Quickstart mode,
# the PROJECT_INIT_QUICKSTART_REQUESTED global variable is set to true and
# the consuming component may proceed by calling the
# project_init_process_quickstart() function to load and execute
# the requested Quickstart function.
#
# The developer documentation is available on GitHub:
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
# The status code a Quickstart function should return in the
# case of a successful operation.
# Since:
# 1.4.0
readonly QUICKSTART_STATUS_OK=$EXIT_SUCCESS;

# [API Global]
# The status code a Quickstart function should return in the case of a
# failed operation. This indicates to the system that the entire operation,
# which might consist of multiple chained functions, should be cancelled.
# A warning is shown to the user about the failed operation.
# Use $QUICKSTART_STATUS_NOWARN instead to suppress that warning.
# Since:
# 1.4.0
readonly QUICKSTART_STATUS_FAILURE=$EXIT_FAILURE;

# [API Global]
# The status code a Quickstart function should return in the case of a
# failed operation, suppressing some warnings emitted by the system. This status
# code is the same as $QUICKSTART_STATUS_FAILURE but gives the underlying function
# the opportunity to show its own warning messages to the user before returning.
# Please note that the system will still emit other warnings and errors not related
# to the returned status of the Quickstart function.
# Since:
# 1.4.0
readonly QUICKSTART_STATUS_NOWARN=50;

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
# The path to the loaded addon resource directory. This is only set if an addon
# is available and loaded, otherwise it remains empty. It indicates the source
# root of the addon within the local filesystem, which may or may not be
# a temporary location.  
# This variable must be regarded as read-only.
# Since:
# 1.4.0
PROJECT_INIT_ADDONS_PATH="";

# [API Global]
# The path of the current working directory of the user when he
# started Project Init.  
# This variable must be regarded as read-only.
# Since:
# 1.4.0
USER_CWD="";

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
# Used by the read_user_input_text() function to determine the text value to use
# by default when a user does not provide an answer in the text prompt.
# Since:
# 1.7.0
USER_INPUT_DEFAULT_TEXT="";

# [API Global]
# Contains the selection index of the user choice from
# the last call to the read_user_input_selection() function.
# Please note that this index is always zero-based, even when
# the selection numbers shown to the user within the
# form selections exhibit a different behaviour.
USER_INPUT_ENTERED_INDEX="";

# [API Global]
# Used by the read_user_input_selection() function to determine the
# zero-based index of the item to use by default when a user does not
# provide an answer in the item selection prompt.
# Since:
# 1.7.0
USER_INPUT_DEFAULT_INDEX="";

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
# The identifier of the question for which form input is requested.
# This variable can be set before calling the read_user_input_selection() ,
# read_user_input_text() or read_user_input_yes_no() function to make the form
# question that follows assignable by a unique identifier. Currently, this is
# only used during testing. When a value is set before calling any of the
# aforementioned functions, it instructs those functions to read the
# user-provided answer from a prepared internal data structure.
# Since:
# 1.2.0
FORM_QUESTION_ID="";

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
# Holds the value loaded and set by the load_var_from_file() function.
# The string value might contain arbitrary characters, including special
# characters. It might be empty if no corresponding var file was found.
# Since:
# 1.3.0
VAR_FILE_VALUE="";

# [API Global]
# The message to show when a project is successfully initialized.
# This text is shown in the terminal and in the desktop notification.
# A new value can be set to this variable to change the success message.
# Since:
# 1.1.0
PROJECT_INIT_SUCCESS_MESSAGE="Project has been initialized";

# [API Global]
# The name of the file which is generated for the legal text of
# the selected license. A new value can be set to this variable to
# change the file name.
# Since:
# 1.6.0
PROJECT_INIT_LICENSE_FILE_NAME="LICENSE";

# [API Global]
# Indicates whether the user has requested a quickstart.
# Is either true or false.  
# This variable must be regarded as read-only.
# Since:
# 1.4.0
PROJECT_INIT_QUICKSTART_REQUESTED=false;

# [API Global]
# Indicates the path to the project source template directory used
# to initialize a new project. This variable is only set after project
# initialization process has started and the source template files have
# been copied to the project target directory by means of
# the project_init_copy() function.  
# This variable must be regarded as read-only.
# Since:
# 1.4.0
PROJECT_INIT_USED_SOURCE="";

# [API Global]
# Can be set to `true` in order to suppress the printing of a deprecation
# warning for the next call of any deprecated function. This variable is
# automatically reset to `false` by a deprecated function once it returns.
# Thus, code using deprecated functions must set this variable before each
# call if deprecation warnings should be suppressed for all of them. Please
# note that the automatic reset of the variable value only applies if the
# underlying deprecated function is called within the same shell environment.
# Since:
# 1.3.0
SUPPRESS_DEPRECATION_WARNING=false;

# The path to the target directory where to save files in Quickstart mode.
_PROJECT_INIT_QUICKSTART_OUTPUT_DIR="";

# An array for holding all supported language version
# numbers/identifiers
SUPPORTED_LANG_VERSIONS_IDS=();

# An array for holding the corresponding labels for all
# supported language versions
SUPPORTED_LANG_VERSIONS_LABELS=();

# The associative array for the data in project.properties files.
declare -A PROPERTIES;

# The associative array for the data in extension_map.txt files.
declare -A COPYRIGHT_HEADER_EXT_MAP;

# The paths to the directories of all available project licenses.
# Is set by the _load_available_licenses() function.
# The order of the paths is in sync with the names.
_PROJECT_AVAILABLE_LICENSES_PATHS=();

# The names of all project licenses.
# Is set by the _load_available_licenses() function.
# The order of the names is in sync with the paths.
_PROJECT_AVAILABLE_LICENSES_NAMES=();

# The path to the license resource selected in the active process.
_PROJECT_SELECTED_LICENSE_PATH="";

# The name of the license resource selected in the active process.
_PROJECT_SELECTED_LICENSE_NAME="";

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

# The array of files which are tracked by Project Init in a target location.
# In general, the file cache contains the absolute paths to all files and
# directories that are generated by Project Init so that the system knows what
# files to process and to be able to distinguish the generated files from
# preexisting files when generating in an already existing project directory.
# However, the behaviour/usage differs slightly between modes. In the form-based
# mode directories are excluded from the file cache upon project initialization
# as an optimization since all files are generated under a single project source
# root, so the system knows about the subdirectories implicitly. The regular
# files must be filtered depending on the patterns in LIST_FILES_TXT.
# In Quickstart mode the file cache only contains files and directories which are
# explicitly created by the program through the file processing API functions.
CACHE_ALL_FILES=();

# Used by the _find_files_impl() function to store
# the found files as a separate item in this array.
_FOUND_FILES=();

# Used by the _find_subst_vars() function to store
# the found substitution variables.
_FOUND_SUBST_VARS=();

# Used by the _array_contains() function to store the
# index of a found array member. May be empty.
_FOUND_ARRAY_MEMBER_IDX="";

# A literal new line character. Can be used in values
# for variable substitutions.
readonly _NL="
";

# The absolute path to the location where
# Project Init resources, including addons, are cached.
readonly RES_CACHE_LOCATION="/tmp";

# The base URL pointing to the Project Init source repository.
readonly PROJECT_BASE_URL="https://github.com/raven-computing/project-init";

# The base URL to be used when creating hyperlinks
# to the Project Init documentation, e.g. for help texts.
readonly DOCS_BASE_URL="${PROJECT_BASE_URL}/wiki";

# Contains the absolute path to the directory of the current theoretic
# init level within the addons resource. This is essentially the addons
# counterpart to $CURRENT_LVL_PATH, but the path is always pointing
# to the addons resource directory. This variable is automatically
# adjusted to always point to the init level directory of the addons
# resource that is or would be applicable, even when no such directory
# is provided by the addon. If no addon is active, then this variable
# will be left empty.
_ADDONS_CURRENT_LVL_PATH="";

# An associative array used to track which deprecated functions
# have already been called. Maps function names (without any '()' at the end)
# to constant values. This is effectively used as a set.
declare -A _DEPRECATED_FUNCTIONS;
# Indicates whether some deprecated feature/behaviour was used by any code.
# Does not track the calling of deprecated functions.
_FLAG_DEPRECATED_FEATURE_USED=false;
# Special deprecation file used by the load_var() function.
_FILE_DEPRECATED_FN_LOAD_VAR_USED="$RES_CACHE_LOCATION/pi_deprfnloadvarused";

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

# The text shown in prompts when requesting user input.
_READ_FN_INPUT_PROMPT="$(echo -e "[${COLOR_CYAN}INPUT${COLOR_NC}] ")";
readonly _READ_FN_INPUT_PROMPT;


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
# will be shown on a separate line. Duplicate warning messages will be ignored.
#
# Args:
# $1 - A string message to log
#
function warning() {
  local warning_message="$1";
  if ! _array_contains "$warning_message" "${_WARNING_LOG[@]}"; then
    _WARNING_LOG+=("$warning_message");
  fi
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
  if (( warn_size > 0 )); then
    local warning_msg="";
    for warning_msg in "${_WARNING_LOG[@]}"; do
      logW "${COLOR_ORANGE}Warning:${COLOR_NC}";
      logW "$warning_msg";
      logW "";
    done
  fi
}

# Triggers a program failure with the specified error message.
#
# This function can be used to stop the program due to an illegal function call.
#
# Args:
# $1 - The error message to print. This argument is mandatory.
#
function _fail_illegal_call() {
  local error_message="$1";
  local func="${FUNCNAME[1]}";
  local source_file="${BASH_SOURCE[2]}";
  local lineno="${BASH_LINENO[1]}";
  if [[ "$func" == "_require_arg" ]]; then
    func="${FUNCNAME[2]}";
    source_file="${BASH_SOURCE[3]}";
    lineno="${BASH_LINENO[2]}";
  fi
  _make_func_hl "$func";
  logE "Programming error: Illegal function call:";
  logE "at: '${source_file}' (line ${lineno})";
  failure "Programming error: Invalid call to ${HYPERLINK_VALUE} function: " \
          "$error_message";
}

# Ensures that the specified argument is non-empty.
#
# This function will perform the argument check and exit the program with
# a failure and the specified error message if the argument is empty
# or left unspecified.
#
# Args:
# $1 - The argument value to check.
# $2 - The error message to print (optional).
#
function _require_arg() {
  local required_arg="$1";
  local error_message="$2";
  if [ -z "$error_message" ]; then
    error_message="Missing required argument";
  fi
  if [ -z "$required_arg" ]; then
    _fail_illegal_call "$error_message";
  fi
}

# Checks that an init script has called project_init_copy() before
# requesting any file operations.
function _ensure_project_files_copied() {
  if [[ ${_FLAG_PROJECT_FILES_COPIED} == false ]]; then
    local func="${FUNCNAME[1]}";
    _make_func_hl "$func";
    local _hl_f="$HYPERLINK_VALUE";
    _make_func_hl "project_init_copy";
    local _hl_pic="$HYPERLINK_VALUE";
    logE "Programming error in init script:";
    logE "at: '${BASH_SOURCE[2]}' (line ${BASH_LINENO[1]})";
    failure "Missing call to project_init_copy() function:"                     \
            "When calling the ${_hl_f} function, the target project directory " \
            "must already be created. "                                         \
            "Make sure you first call the ${_hl_pic} function in your init script";
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
                  --app-name "Project Init"        \
                  "${_project_name}"               \
                  "${PROJECT_INIT_SUCCESS_MESSAGE}";
    else
      notify-send -t ${_INT_NOTIF_SUCCESS_TIMEOUT} \
                  --app-name "Project Init"        \
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
  # shellcheck disable=SC2206
  local version_spec=( ${PROJECT_INIT_VERSION//./ } );
  local _m="${version_spec[0]}"; # Major version
  make_hyperlink "${DOCS_BASE_URL}/API-Reference-v${_m}#${_func_name}" "${_func_name}()";
  return $?;
}

# Safely change the active working directory or fail with an error message.
#
# Args:
# $1 - The path to the directory to change to. This is a mandatory argument.
#
function _cd_or_die() {
  local _target_path="$1";
  if ! cd "${_target_path}"; then
    failure "Failed to change active working directory to '${_target_path}'";
  fi
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
  local i;
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

  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    _cancel_quickstart;
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

# Cancels a Quickstart operation.
#
# This function potentially cleans up already copied resources in the project
# target directory. If no argument is given, then this function returns
# normally, otherwise it exits the entire application with the exit code
# specified by the first argument.
# If not in Quickstart mode, then this function has no effect.
#
# Args:
# $1 - Optional exit status of the application.
#
# Returns:
# 0 - If no exit status was specified as an argument and the Quickstart
#     operation was successfully cancelled.
# 1 - If no Quickstart operation is active at the time this
#     function was called. This means that this function call was a NO-OP.
#
# Globals:
# CACHE_ALL_FILES - The files already copied to the project target directory.
#
function _cancel_quickstart() {
  local arg_do_exit_with_status="$1";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == false ]]; then
    return 1;
  fi
  if (( ${#CACHE_ALL_FILES[@]} > 0 )); then
    local file="";
    for file in "${CACHE_ALL_FILES[@]}"; do
      if [ -d "$file" ]; then
        if ! rm -rf "$file"; then
          logW "Failed to clean up directory created by quickstart function.";
          logW "Check directory '${file}'";
        fi
      elif [ -f "$file" ]; then
        if ! rm "$file"; then
          logW "Failed to clean up file created by quickstart function.";
          logW "Check file '${file}'";
        fi
      fi
    done
  fi
  if [ -n "$arg_do_exit_with_status" ]; then
    exit $arg_do_exit_with_status;
  fi
  return 0;
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
  local path_version_base="${SCRIPT_LVL_0_BASE}/VERSION";
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
      logW "at: '${path_version_base}'";
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
  local path_version_addons="${PROJECT_INIT_ADDONS_DIR}/VERSION";
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
      logW "at: '${path_version_addons}'";
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

# Loads the specified addon library script file.
#
# The specified script path must be valid and the file
# to be loaded must exist. If any condition is not satisfied, then
# this function will exit the program by means of the failure() function.
#
# Args:
# $1 - The name of the file to load, relative to the source tree root
#      of the active addon. This is a mandatory argument.
#
function _load_addon_declared_libs() {
  local addon_libs="$1";
  if _is_absolute_path "$addon_libs"; then
    logE "Addon code path is invalid.";
    logE "Invalid property with key 'sys.addon.code.load': '${addon_libs}'";
    logE "File path must be relative to addon directory.";
    _show_helptext "E" "Addons#loading-common-code";
    failure "An addon configuration has errors";
  fi
  if [[ "${addon_libs}" == *"../"* ]]; then
    logE "Addon code path is invalid.";
    failure "An addon configuration has errors";
  fi
  addon_libs="${PROJECT_INIT_ADDONS_DIR}/${addon_libs}";
  if ! [ -r "${addon_libs}" ]; then
    logE "Addon code file not found:";
    logE "at: '${addon_libs}'";
    logE "Invalid property with key 'sys.addon.code.load'";
    _show_helptext "E" "Addons#loading-common-code";
    failure "An addon configuration has errors";
  fi
  source "$addon_libs";
}

# Loads the quickstart function definitions.
#
# The path to the directory containing the quickstart script
# file must be specified.
#
# Args:
# $1 - The path to the quickstart script directory.
#      This is a mandatory argument.
#
# Returns:
# 0 - If the quickstart function definitions could be successfully loaded.
# 1 - If the quickstart script file was not found.
# 2 - If the quickstart script file was found but could not be loaded.
#
function _load_quickstart_definitions() {
  local quickstart_path_base="$1";
  local quickstart_code_file="${quickstart_path_base}/quickstart.sh";
  if ! [ -r "$quickstart_code_file" ]; then
    return 1;
  fi
  source "$quickstart_code_file";
  if (( $? != 0 )); then
    return 2;
  fi
  return 0;
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
# ARG_QUICKSTART_NAMES - Represents the quickstart '@' argument(s).
# ARG_NO_CACHE         - Represents the '--no-cache' option.
# ARG_NO_PULL          - Represents the '--no-pull' option.
# ARG_HELP             - Represents the '-?|--help' option.
# ARG_VERSION          - Represents the '--version' option.
# ARG_VERSION_STR      - Represents the '-#' option.
#
function _parse_args() {
  ARG_QUICKSTART_NAMES=();
  ARG_NO_CACHE=false;
  ARG_NO_PULL=false;
  ARG_HELP=false;
  ARG_VERSION=false;
  ARG_VERSION_STR=false;
  local quickstart_requested=false;
  local arg="";
  local qs_arg="";
  local qs_names=();
  local qs_name="";
  for arg in "$@"; do
    case $arg in
      @*)
      quickstart_requested=true;
      qs_arg="${arg:1}";
      # shellcheck disable=SC2206
      qs_names=(${qs_arg//,/ });
      for qs_name in "${qs_names[@]}"; do
        ARG_QUICKSTART_NAMES+=("$qs_name");
      done
      shift;
      ;;
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
      echo "Unknown argument: '${arg}'";
      echo "";
      echo "Use the '--help' option for more information.";
      echo "";
      exit $EXIT_FAILURE;
      ;;
    esac
  done
  # Make sure API global is read-only
  if [[ $quickstart_requested == true ]]; then
    readonly PROJECT_INIT_QUICKSTART_REQUESTED=true;
  else
    readonly PROJECT_INIT_QUICKSTART_REQUESTED=false;
  fi
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
    echo "Copyright (C) 2025 Raven Computing";
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
    echo "Alternatively, specify one or more Quickstart functions to run.";
    echo "";
    echo "The following optional arguments are supported:"
    echo "";
    echo "Arguments:";
    echo "";
    echo "  [@Quickstart...] The name of the Quickstart to run. This argument can be applied ";
    echo "                   multiple times, either separately or in a single argument as a ";
    echo "                   comma-separated list of Quickstart names. The '@'-prefix in each ";
    echo "                   separate argument is mandatory.";
    echo "";
    echo "Options:";
    echo "";
    if [[ "$PROJECT_INIT_BOOTSTRAP" == "1" ]]; then
      echo "  [--no-cache]     Clear the caches before and after the program runs.";
      echo "";
    fi
    echo "  [--no-pull]      Do not update existing caches and use them as is.";
    echo "";
    echo "  [-#|--version]   Show program version information.";
    echo "";
    echo "  [-?|--help]      Show this help message.";
    echo "";
    exit $EXIT_SUCCESS;
  fi
}

# Event handling function to be called when an interrupt
# signal SIGINT is received.
function _handle_interrupt_event() {
  echo "";
  logI "Cancelling...";
  # Ensure proper cleanup but exit under any circumstance
  _cancel_quickstart $EXIT_CANCELLED;
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

# Adds the specified file to the internal file cache.
#
# The given path may point to a regular file or directory. In latter case,
# all files in the directory are also added to the file cache. No checks for
# duplicate entries with regards to the argument file are performed.
#
# Args:
# $1 - The absolute path of the file or directory to add to the file cache.
#
# Globals:
# CACHE_ALL_FILES - The file cache which will be updated.
#
function _file_cache_add() {
  local arg_file="$1";
  CACHE_ALL_FILES+=("$arg_file");
  if [ -d "$arg_file" ]; then
    if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
      _find_files_impl "$arg_file" "f,d";
    else
      _find_files_impl "$arg_file" "f" "${LIST_FILES_TXT[@]}";
    fi
    if (( $? != 0 )); then
      logE "Failed to add directory to internal file cache: '${arg_file}'";
      return 1;
    fi
    local dir_child;
    for dir_child in "${_FOUND_FILES[@]}"; do
      if [[ "$dir_child" != "$arg_file" ]]; then
        CACHE_ALL_FILES+=("$dir_child");
      fi
    done
  fi
  return 0;
}

# Removes the specified file from the internal file cache.
#
# The given path may point to a regular file or directory. In latter case,
# all files in the directory are also removed from the file cache.
#
# Args:
# $1 - The absolute path of the file or directory to remove from the file cache.
#
# Globals:
# CACHE_ALL_FILES - The file cache which will be updated.
#
function _file_cache_remove() {
  local arg_file="$1";
  local file_cache_update=();
  local file="";
  for file in "${CACHE_ALL_FILES[@]}"; do
    if [[ "$file" != "$arg_file" && "$file" != "${arg_file}/"* ]]; then
      file_cache_update+=("$file");
    fi
  done
  CACHE_ALL_FILES=("${file_cache_update[@]}");
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
  local ficon="${SCRIPT_LVL_0_BASE}/icon.ascii.txt";
  # Check for addons overwrite
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -r "${PROJECT_INIT_ADDONS_DIR}/icon.ascii.txt" ]; then
      ficon="${PROJECT_INIT_ADDONS_DIR}/icon.ascii.txt";
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
      if [[ -n "$line" && "$line" != \#* ]]; then
        # Check that the line does not contain spaces
        if [[ "$line" != *" "* ]]; then
          # Avoid duplicates
          if ! _array_contains "$line" "${SYS_DEPENDENCIES[@]}"; then
            SYS_DEPENDENCIES+=("$line");
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
    logW "at: '${dependencies_file}' (at line ${invalid_line})";
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
  if (( bash_version_major < REQUIREMENT_BASH_VERSION )); then
    logW "Unsatisfied compatibility requirement.";
    if (( bash_version_major == 0 )); then
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
  if [[ "$PROJECT_INIT_TESTS_ACTIVE" != "1" ]]; then
    # Check for EoL OS
    if _command_dependency "lsb_release"; then
      local os_name;
      os_name="$(lsb_release --id      \
                |grep "Distributor ID" \
                |cut -d: -f2 |xargs    \
                |tr '[:upper:]' '[:lower:]')";
      if [[ "$os_name" == "ubuntu" ]]; then
        local os_version;
        os_version="$(lsb_release --release \
                      |grep "Release"       \
                      |cut -d: -f2 |xargs   \
                      |tr '[:upper:]' '[:lower:]')";
        if [[ "$os_version" == "20.04" ]]; then
          logW "You are using Ubuntu ${os_version} which has reached its EoL on 1st of June 2025.";
          logW "Future versions of project-init might not support this operating system version";
          logW "and generated projects might not build as Raven Computing has discontinued";
          logW "support for Ubuntu ${os_version} on 1st of June 2025.";
        fi
      fi
    fi
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
  local dependency="";
  for dependency in "${SYS_DEPENDENCIES[@]}"; do
    if ! _command_dependency "$dependency"; then
      logE "Could not find the '${dependency}' executable.";
      logE "Please make sure that ${dependency} is correctly installed.";
      failure "Unsatisfied compatibility requirement. Missing system dependency";
    fi
  done

  # Check for addons sys dependencies
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -f "${PROJECT_INIT_ADDONS_DIR}/dependencies.txt" ]; then
      _read_dependencies "${PROJECT_INIT_ADDONS_DIR}/dependencies.txt";
      for dependency in "${SYS_DEPENDENCIES[@]}"; do
        if ! _command_dependency "$dependency"; then
          get_boolean_property "sys.dependencies.onmissing.fail" "true";
          if [[ "$PROPERTY_VALUE" == "true" ]]; then
            logE "Could not find the '${dependency}' executable.";
            logE "Please make sure that ${dependency} is correctly installed.";
            failure "Unsatisfied compatibility requirement. Missing system dependency";
          else
            logW "Missing system dependency: '${dependency}'";
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
# Text to indicate the loading operation.
# Encountered errors are also printed on stdout.
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
  _cd_or_die "$RES_CACHE_LOCATION";
  # Effective user ID
  local _EUID="";
  _EUID=$(id -u);
  # Find suitable cache dir
  local cache_dir_pattern="piar_cache_${_EUID}_*";
  # Intentional splitting and globbing.
  # shellcheck disable=SC2206
  local cache_dirs=( $cache_dir_pattern );
  local addons_res_dir="";
  # Check if a cache dir already exists
  if [[ "${cache_dirs[0]}" == "$cache_dir_pattern" ]]; then
    # No cache dir found
    _command_dependency "mktemp";
    # Create new cache dir
    addons_res_dir="$(mktemp -d piar_cache_${_EUID}_XXXXXXXXXX 2>&1)";
    cmd_exit_status=$?;
    if (( cmd_exit_status != 0 )); then
      _cd_or_die "$SCRIPT_LVL_0_BASE";
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
    git clone $git_branch --depth 1 "$git_res" "${RES_CACHE_LOCATION}/${addons_res_dir}" &> /dev/null;
    cmd_exit_status=$?;
    if (( cmd_exit_status != 0 )); then
      echo "FAILURE";
      rm -r "$addons_res_dir";
      _cd_or_die "$SCRIPT_LVL_0_BASE";
      logE "Command 'git clone' returned non-zero exit status $cmd_exit_status";
      logE "Make sure that '${git_res}' is a valid git repository and that ";
      logE "you have the necessary access rights.";
      if [ -n "$branch" ]; then
        failure "Failed to fetch Project Init addons resources from '${git_res}' " \
                "on branch '${branch}' and caching it under '${RES_CACHE_LOCATION}/${addons_res_dir}'";
      else
        failure "Failed to fetch Project Init addons resources from '$git_res' " \
                "and caching it under '${RES_CACHE_LOCATION}/${addons_res_dir}'";
      fi
    fi
    echo "OK";
  else
    # At least one cache dir found
    addons_res_dir="${cache_dirs[0]}";
    _cd_or_die "$addons_res_dir";
    echo -n "Loading addons...";
    if [[ $ARG_NO_PULL == false ]]; then
      # Update cache so that we always use the latest version
      git pull &> /dev/null;
      cmd_exit_status=$?;
    fi
    if (( cmd_exit_status != 0 )); then
      echo "FAILURE";
      _cd_or_die "$SCRIPT_LVL_0_BASE";
      local cache_dir="${RES_CACHE_LOCATION}/${addons_res_dir}";
      logE "Command 'git pull' returned non-zero exit status $cmd_exit_status";
      failure "Failed to update cached Project Init addons resources: "     \
              "at: '${cache_dir}'"                                          \
              "You could try to remove the cache directory '${cache_dir}' " \
              "and try again.";
    fi
    echo "OK";
  fi
  # Set global var and switch back to the system init base dir
  logI "";
  PROJECT_INIT_ADDONS_DIR="${RES_CACHE_LOCATION}/${addons_res_dir}";
  _cd_or_die "$SCRIPT_LVL_0_BASE";
}

# Loads the Project Init addons resources if available and sets
# the corresponding system variables.
#
# Calling this function only has an effect if the $PROJECT_INIT_ADDONS_RES
# environment variable is set or the underlying user has created
# the 'project-init-addons-res' config file. Addons can be loaded
# in two ways: directly via a directory in the filesystem or via
# a Git repository. In any case, however, this function makes the underlying
# addons resources available to the rest of the init system by setting
# the $PROJECT_INIT_ADDONS_DIR global variable.
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
  # First check if addons res is specified by config file, as that should
  # take precedence when available over the env var
  if [ -r "${HOME}/project-init-addons-res" ]; then
    PROJECT_INIT_ADDONS_RES=$(head -n 1 "${HOME}/project-init-addons-res");
  elif [ -r "${HOME}/.project-init-addons-res" ]; then
    PROJECT_INIT_ADDONS_RES=$(head -n 1 "${HOME}/.project-init-addons-res");
  fi
  # Also check for branch/tag specification in file
  if [ -r "${HOME}/project-init-addons-res-branch" ]; then
    PROJECT_INIT_ADDONS_RES_BRANCH=$(head -n 1 "${HOME}/project-init-addons-res-branch");
  elif [ -r "${HOME}/.project-init-addons-res-branch" ]; then
    PROJECT_INIT_ADDONS_RES_BRANCH=$(head -n 1 "${HOME}/.project-init-addons-res-branch");
  fi
  # Process environment variable
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
      if ! [ -r "${PROJECT_INIT_ADDONS_DIR}/INIT_ADDONS" ]; then
        # Do not show warnings when in test mode
        if [[ "$PROJECT_INIT_TESTS_ACTIVE" != "1" ]]; then
          if [[ $addons_is_git_res == true ]]; then
            logW "Repository is not marked as a Project Init addons resource:";
            logW "Accessed via: '${PROJECT_INIT_ADDONS_RES}'";
            logW "Please add an empty file named 'INIT_ADDONS' in the repository root";
            logW "in order to use it as a Project Init addons resource.";
          else
            logW "Directory is not marked as a Project Init addons resource:";
            logW "at: '${PROJECT_INIT_ADDONS_DIR}'";
            logW "Please create an empty file '${PROJECT_INIT_ADDONS_DIR}/INIT_ADDONS'";
            logW "in order to use the directory as a Project Init addons resource.";
          fi
          logW "";
          logW "Ignoring 'PROJECT_INIT_ADDONS_RES' resource";
          PROJECT_INIT_ADDONS_DIR="";
        fi
      fi
    else
      logW "Cannot use Project Init addons resource:";
      logW "at: '${PROJECT_INIT_ADDONS_DIR}'";
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
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -r "${PROJECT_INIT_ADDONS_DIR}/title.txt" ]; then
      _print_text_from_file "${PROJECT_INIT_ADDONS_DIR}/title.txt";
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
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -r "${PROJECT_INIT_ADDONS_DIR}/description.txt" ]; then
      _print_text_from_file "${PROJECT_INIT_ADDONS_DIR}/description.txt";
      has_addons_text=true;
    fi
  fi
  if [[ $has_addons_text == false ]]; then
    logI "This program will guide you through the steps of initializing";
    logI "a new software project. Please answer the following questions";
    logI "to get started.";
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

# Prints a deprecation warning for a function.
#
# This function can be called from inside deprecated API functions to show a
# warning to the user about that deprecation. It should only be used for
# deprecated API functions, not internal functions.
# A warning is only shown once per function.
#
# Args:
# $1 - The name of the API function for which a deprecation warning
#      should be printed. This is an optional argument. If it is omitted,
#      then the function name is automatically looked up in the call stack.
#
# Returns:
# 0 - If a deprecation warning was fired.
# 1 - If no deprecation warning was was shown because it has aleady
#     been fired in a previous call.
# 2 - If the showing of deprecation warnings is disabled by
#     the SUPPRESS_DEPRECATION_WARNING global variable.
# 3 - If the showing of deprecation warnings is disabled altogether
#     by the system configuration.
#
# Globals:
# SUPPRESS_DEPRECATION_WARNING - A boolean flag indicating whether the printing
#                                of a deprecation warning is suppressed. If this
#                                is true at the time this function is called, it
#                                is automatically reset to false by this function.
# _DEPRECATED_FUNCTIONS        - The associative array to be used to track which
#                                deprecated functions were already warned about.
#                                Must be an already declared associative array.
#
function _warn_deprecated() {
  local deprecated_fn="$1";
  if [ -z "$deprecated_fn" ]; then
    deprecated_fn="${FUNCNAME[1]}";
  fi
  if [[ $SUPPRESS_DEPRECATION_WARNING == true ]]; then
    SUPPRESS_DEPRECATION_WARNING=false;  # Reset
    return 2;
  fi
  get_boolean_property "sys.warn.deprecation" "true";
  if [[ "$PROPERTY_VALUE" == "false" ]]; then
    return 3;
  fi
  local depr_value="${_DEPRECATED_FUNCTIONS[$deprecated_fn]}";
  if [[ "$depr_value" == "1"  ]]; then
    # Deprecation warning for that function already shown
    return 1;
  fi
  _DEPRECATED_FUNCTIONS[$deprecated_fn]=1;
  _make_func_hl $deprecated_fn;
  local depr_conf="sys.warn.deprecation=false";
  logW "The function $HYPERLINK_VALUE is deprecated.";
  logW "See the API documentation for how to replace the function call or use '${depr_conf}'";
  logW "in your project.properties configuration to suppress this warning.";
  return 0;
}

# Checks that the application is not running in Quickstart mode.
#
# Shows a warning if Quickstart mode is activated. This function shoud only
# be used by API functions if they wish to show a warning if called while in
# Quickstart mode but they are only applicable in regular mode.
#
# Returns:
# 0 - If the application is not running in Quickstart mode.
# 1 - If Quickstart mode is active.
#
function _check_no_quickstart() {
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    local api_fn="${FUNCNAME[1]}";
    _make_func_hl "$api_fn";
    logW "Calling $HYPERLINK_VALUE in Quickstart mode has no effect:";
    logW "at: '${BASH_SOURCE[2]}' (line ${BASH_LINENO[1]})";
    return 1;
  else
    return 0;
  fi
}

# Normalises the given Quickstart name.
#
# Args:
# $1 - The unnormalised Quickstart name.
#
# Stdout:
# The normalised Quickstart name, dumped to stdout.
#
function _normalise_quickstart_name() {
  local quickstart_name="$1";
  # Convert to all lower-case
  quickstart_name=$(echo "$quickstart_name" |tr '[:upper:]' '[:lower:]');
  # Convert slashes and dots to underscores
  quickstart_name="${quickstart_name//\//_}";
  quickstart_name="${quickstart_name//./_}";
  echo "$quickstart_name";
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
#      The variable must already be declared before calling this function.
#      Supported variable names are 'PROPERTIES' and '_FORM_ANSWERS'.
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
# # Or:
# _read_properties "myfile.properties" PROPERTIES;
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
      if [[ -n "$line" && "$line" != \#* ]]; then
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
            # Assign value to key
            if [[ "$container" == "PROPERTIES" ]]; then
              PROPERTIES["$p_key"]="$p_val";
            elif [[ "$container" == "_FORM_ANSWERS" ]]; then
              _FORM_ANSWERS["$p_key"]="$p_val";
            else
              failure "Invalid container name '$container'";
            fi
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
# This function queries the value with the specified key in the global property
# store and writes the result to the $PROPERTY_VALUE global variable.
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
# This function queries the boolean value with the specified key in the global
# property store and writes the result to the $PROPERTY_VALUE global variable.
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
    if [ -f "${PROJECT_INIT_ADDONS_DIR}/load-hook.sh" ]; then
      # Check if hook is executable
      if [ -x "${PROJECT_INIT_ADDONS_DIR}/load-hook.sh" ]; then
        # Run hook script, in a subshell-process,
        # redirect stdout and stderr to /dev/null
        (cd "$PROJECT_INIT_ADDONS_DIR" \
            && exec "${PROJECT_INIT_ADDONS_DIR}/load-hook.sh" > /dev/null 2>&1);

        local hook_exit_status=$?;
        if (( hook_exit_status != 0 )); then
          logW "Load-hook finished with exit status $hook_exit_status";
          warning "The load-hook of the Project Init addon did not exit successfully";
        fi
      else
        logW "The addons load hook is not marked as executable.";
        logW "Please set as executable: '${PROJECT_INIT_ADDONS_DIR}/load-hook.sh'";
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
    if [ -f "${PROJECT_INIT_ADDONS_DIR}/after-init-hook.sh" ]; then
      # Check if hook is executable
      if [ -x "${PROJECT_INIT_ADDONS_DIR}/after-init-hook.sh" ]; then
        logI "Running after-init hook";
        local exported_project_dir="$var_project_dir";
        if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
          exported_project_dir="$USER_CWD";
        fi
        # Run hook script, in a subshell-process, define env var,
        # redirect stdout and stderr to /dev/null
        # shellcheck disable=SC2030
        (cd "$PROJECT_INIT_ADDONS_DIR" \
            && export VAR_PROJECT_DIR="$exported_project_dir" \
            && export PROJECT_INIT_QUICKSTART_REQUESTED; \
            exec "${PROJECT_INIT_ADDONS_DIR}/after-init-hook.sh" > /dev/null 2>&1);

        local hook_exit_status=$?;
        if (( hook_exit_status != 0 )); then
          logW "After-init-hook finished with exit status $hook_exit_status";
          warning "The after-init-hook of the Project Init addon did not exit successfully";
        fi
      else
        logW "The addons after-init hook is not marked as executable.";
        logW "Please set as executable:" \
             "'${PROJECT_INIT_ADDONS_DIR}/after-init-hook.sh'";
        _show_helptext "W" "Addons#hooks";

        warning "The after-init-hook of the Project Init script was not executed";
      fi
    fi
  fi
}

# Runs the used-defined after-init-hook if available.
#
# This function can be safely called even when no used-defined
# hook is available. The hook is executed in a subprocess, for which both
# stdout and stderr are redirected to /dev/null
#
function _run_user_after_init_hook() {
  get_property "sys.user.hook.afterinit";
  local user_hook="$PROPERTY_VALUE";
  if [ -z "$user_hook" ]; then
    return 0;
  fi
  if _is_absolute_path "$user_hook"; then
    logW "User-defined after-init hook is invalid.";
    logW "File path must be relative to user home directory.";
    logW "Invalid property with key 'sys.user.hook.afterinit': '${user_hook}'";
    _show_helptext "W" "Addons#hooks";
    warning "The user-defined after-init hook was not executed";
    return 1;
  fi
  if [ -z "$HOME" ]; then
    logE "Cannot find user home";
    return 1;
  fi
  if [[ "${user_hook}" == *"../"* ]]; then
    logW "Invalid user-defined after-init hook.";
    warning "The user-defined after-init hook was not executed";
    return 1;
  fi
  user_hook="${HOME}/${user_hook}";
  if ! [ -r "${user_hook}" ]; then
    logW "User-defined after-init hook not found:";
    logW "at: '${user_hook}'";
    _show_helptext "W" "Addons#hooks";
    warning "The user-defined after-init hook was not executed";
    return 1;
  fi
  if ! [ -O "${user_hook}" ]; then
    logW "User-defined after-init hook is not owned by current user:";
    logW "at: '${user_hook}'";
    _show_helptext "W" "Addons#hooks";
    warning "The user-defined after-init hook was not executed";
    return 1;
  fi
  if ! [ -x "${user_hook}" ]; then
    logW "User-defined after-init hook is not marked as executable:";
    logW "Please set as executable: '${user_hook}'";
    _show_helptext "W" "Addons#hooks";
    warning "The user-defined after-init hook was not executed";
    return 1;
  fi
  logI "Running user-defined after-init hook";
  local exported_project_dir="$var_project_dir";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    exported_project_dir="$USER_CWD";
  fi
  # Run hook script, in a subshell-process, define env var,
  # redirect stdout and stderr to /dev/null
  # shellcheck disable=SC2031
  (cd "$HOME" \
      && export VAR_PROJECT_DIR="$exported_project_dir" \
      && export PROJECT_INIT_QUICKSTART_REQUESTED; \
      exec "${user_hook}" > /dev/null 2>&1);

  local hook_exit_status=$?;
  if (( hook_exit_status != 0 )); then
    logW "User-defined after-init hook finished with exit status $hook_exit_status";
    warning "The user-defined after-init hook did not exit successfully";
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
    local file_item="";
    while read -r line || [ -n "$line" ]; do
      # Ignore comments and blank lines
      if [[ -n "$line" && "$line" != \#* ]]; then
        # Trim surrounding whitespaces
        file_item="$(echo "$line" |xargs)";
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

# Handler function for when the addon-specific configuration file was loaded.
#
# This function can be used to perform checks for the addon-specific
# 'project.properties' configuration file after the base variant was loaded
# but before the user variant is loaded. It is only called if
# the addon-specific file was loaded.
#
function _after_addons_properties_loaded() {
  get_property "sys.addon.code.load";
  local addon_libs="$PROPERTY_VALUE";
  if [ -n "$addon_libs" ]; then
    _load_addon_declared_libs "$addon_libs";
  fi
  get_property "sys.user.hook.afterinit";
  local user_hook="$PROPERTY_VALUE";
  if [ -n "$user_hook" ]; then
    logW "Invalid property defined by addon.";
    logW "The property with key 'sys.user.hook.afterinit' must only be ";
    logW "defined by the user-specific 'project.properties' file.";
    _show_helptext "W" "Addons#hooks";
    PROPERTIES[sys.user.hook.afterinit]="";
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
  _read_properties "project.properties";

  # Check for addons properties
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -f "$PROJECT_INIT_ADDONS_DIR/project.properties" ]; then
      _read_properties "$PROJECT_INIT_ADDONS_DIR/project.properties";
      _after_addons_properties_loaded;
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
    if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == false ]]; then
      if [ -z "$PROJECT_INIT_TESTS_RUN_CONFIG" ]; then
        logE "Environment variable 'PROJECT_INIT_TESTS_ACTIVE' is set";
        logE "but 'PROJECT_INIT_TESTS_RUN_CONFIG' is missing";
        failure "Failed to execute test run";
      fi
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

# Initializes standard substitution variables to default values.
#
# This function sets the following substitution variables:
#
# VAR_PROJECT_ORGANISATION_NAME: The name of the organisation for the project
# VAR_PROJECT_ORGANISATION_URL: The URL for the organisation website
# VAR_PROJECT_ORGANISATION_EMAIL: The E-Mail of the organisation of the project
# VAR_COPYRIGHT_YEAR: The year used in copyright notices
# VAR_COPYRIGHT_HOLDER: The name of the copyright holder
# VAR_PROJECT_SLOGAN_STRING: The example string to use within the generated
#                            example source code, e.g. when printing something
#                            to the screen
#
function _load_default_subst_vars() {
  get_property "project.organisation.name" "Raven Computing";
  var_project_organisation_name="$PROPERTY_VALUE";

  get_property "project.organisation.url" "https://www.raven-computing.com";
  var_project_organisation_url="$PROPERTY_VALUE";

  get_property "project.organisation.email" "info@raven-computing.com";
  var_project_organisation_email="$PROPERTY_VALUE";

  get_property "project.slogan.string" "Created by Project Init system";
  var_project_slogan_string="$PROPERTY_VALUE";

  var_copyright_year=$(date +%Y);
  if (( $? != 0 )); then
    logW "Failed to get current date:";
    logW "Command 'date' returned non-zero exit status.";
    warning "Check date in copyright headers of source files";
    var_copyright_year="1970";
  fi
  var_copyright_holder="$var_project_organisation_name";
}

# Replaces standard substitution variables according to the
# set global variable value.
function _replace_default_subst_vars() {
  replace_var "PROJECT_ORGANISATION_NAME"  "$var_project_organisation_name";
  replace_var "PROJECT_ORGANISATION_URL"   "$var_project_organisation_url";
  replace_var "PROJECT_ORGANISATION_EMAIL" "$var_project_organisation_email";
  replace_var "PROJECT_SLOGAN_STRING"      "$var_project_slogan_string";
  replace_var "COPYRIGHT_YEAR"             "$var_copyright_year";
  replace_var "COPYRIGHT_HOLDER"           "$var_copyright_holder";
}

# Shows the start information to the user according to the set configuration.
function _project_init_show_start_info() {
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

# [API function]
# Startup function for the Project Init system.
#
# Initializes the state of the Project Init system, processes the given
# arguments, loads configurations and potentially addons resources. This function
# either brings the system to a state in which a regular form-based init process
# or Quickstart function can be run, or it exits the process by means of
# the failure() function. The general contract of the Project Init lifecycle
# applies. When this function returns normally, the startup procedure has
# succeeded and the caller can proceed with the desired action. The global
# variable $PROJECT_INIT_QUICKSTART_REQUESTED will indicate whether the init
# system is running in Quickstart mode or regular form-based mode, however, the
# caller is in principle free to ignore the request as he sees fit. The provided
# implementation for processing Quickstart requests can be launched by
# calling the project_init_process_quickstart() function. When running in regular
# form-based mode, it is the responsibility of the caller to provide a suitable
# implementation of the main form and launch it after this function returns.
# Once the Project Init system is initialized, a caller must ensure he calls
# the project_init_finish() function as the shutdown procedure. Anything which
# needs to be handled in between the startup and shutdown procedure
# is implementation-specific.
#
# **WARNING:**
#
# This API function should **NOT** be called by an addon.
# An addon is part of an already initialized lifecycle. This API function is
# only intended to be used for providers of specialised Project Init
# implementations, e.g. providers with a specialised main form implementation.
# Normal users and organisations wishing to adapt and extend the default
# Project Init implementation should do so by using the addon mechanism.
# Normally, there is no need for an external consumer of Project Init to
# provide his own lifecycle or main form implementation.
# Only use this function if you know what you are doing.
#
# Args:
# $@ - The arguments to Project Init.
#
# Globals:
# PROJECT_INIT_QUICKSTART_REQUESTED - A boolean value indicating whether the
#                                     given arguments resulted in a request to
#                                     run a Quickstart function. Is either true
#                                     or false. Is set by this function.
#
function project_init_start() {
  # Keep track of the current working directory of the user when he
  # executed the main script, even though we change it below to make
  # it easier throughout the Project Init system.
  readonly USER_CWD="$PWD";
  # Script root directory
  SCRIPT_LVL_0_BASE="$(_get_script_path "${BASH_SOURCE[0]}")";
  CURRENT_LVL_PATH="$SCRIPT_LVL_0_BASE";
  CURRENT_LVL_NUMBER=0;
  # Ensure we are at level 0 base
  _cd_or_die "$SCRIPT_LVL_0_BASE";

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

  # Set public API variant and protect as read-only.
  readonly PROJECT_INIT_ADDONS_PATH="$PROJECT_INIT_ADDONS_DIR";

  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    ARG_QUICKSTART_NAMES_NORM=();
    local quickstart_name="";
    for quickstart_name in "${ARG_QUICKSTART_NAMES[@]}"; do
      quickstart_name=$(_normalise_quickstart_name "$quickstart_name");
      ARG_QUICKSTART_NAMES_NORM+=("$quickstart_name");
    done
    # Set where to save files in Quickstart mode
    _PROJECT_INIT_QUICKSTART_OUTPUT_DIR="$USER_CWD";
  fi

  _load_configuration;
  _check_system_dependencies;

  # Check for addons load hook
  _run_addon_load_hook;

  # Initialize some common substitution variables
  _load_default_subst_vars;
  return 0;
}

# [API function]
# Finish function for the Project Init system.
#
# Performs lifecycle checks, shows warnings and success messages and handles
# the shutdown state of the Project Init system. This function does not exit
# the underlying process in the case of a successful operation, in which case
# it returns with $EXIT_SUCCESS. However, in the case of an encountered error,
# this function might exit the process by means of the failure() function.
#
# **WARNING:**
#
# This API function should **NOT** be called by an addon.
# An addon is part of an already initialized lifecycle. This API function is
# only intended to be used for providers of specialised Project Init
# implementations, e.g. providers with a specialised main form implementation.
# Normal users and organisations wishing to adapt and extend the default
# Project Init implementation should do so by using the addon mechanism.
# Normally, there is no need for an external consumer of Project Init to
# provide his own lifecycle or main form implementation.
# Only use this function if you know what you are doing.
#
# Returns:
# 0 - In the case of a successful finish procedure.
#
function project_init_finish() {
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == false ]]; then
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
      failure "The script in last init level was executed without a call to the"    \
              "$HYPERLINK_VALUE function. Please make sure that the 'init.sh'"      \
              "script in the lowermost init level calls the project_init_license()" \
              "function when ready. The function must always be called, even"       \
              "when no license was selected or there is no intention in using"      \
              "any license or copyright notice";
    fi
    if [[ ${_FLAG_PROJECT_FILES_PROCESSED} == false ]]; then
      _make_func_hl "project_init_process";
      failure "The script in last init level was executed without a call to the" \
              "$HYPERLINK_VALUE function. Please make sure that the"             \
              "'init.sh' script in the lowermost init level calls the"           \
              "project_init_process() function when ready.";
    fi
  fi

  get_boolean_property "sys.warn.deprecation" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    # Special handling of deprecated load_var() function
    if [ -r "${_FILE_DEPRECATED_FN_LOAD_VAR_USED}" ]; then
      local magic_depr_value="";
      magic_depr_value=$(head -n 1 ${_FILE_DEPRECATED_FN_LOAD_VAR_USED});
      if [[ "$magic_depr_value" == "pi_deprecated_fn_load_var_used=1" ]]; then
        rm "${_FILE_DEPRECATED_FN_LOAD_VAR_USED}" > /dev/null 2>&1;
        _warn_deprecated "load_var";
      fi
    fi
    if (( ${#_DEPRECATED_FUNCTIONS[@]} > 0 )); then
      warning "Init code is using deprecated API functions.";
    fi
    if [[ ${_FLAG_DEPRECATED_FEATURE_USED} == true ]]; then
      warning "Init code is relying on deprecated behaviour.";
    fi
  fi

  # Check for addons and used-defined after-init hooks.
  _run_addon_after_init_hook;
  _run_user_after_init_hook;

  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == false ]]; then
    # Finish
    _log_success;

    get_boolean_property "sys.notification.success.show" "true";
    if [[ "$PROPERTY_VALUE" == "true" ]]; then
      _show_notif_success;
    fi
  fi

  return $EXIT_SUCCESS;
}

# [API function]
# Primary processing function for the quickstart mode.
#
# This function handles the execution of one or more requested
# Quickstart functions. This is the default implementation for
# handling Quickstarts. In the case of an encountered error,
# this function might exit the process by means of
# the failure() function. All return values from called Quickstart
# functions are handled by this function.
#
# **WARNING:**
#
# This API function should **NOT** be called by an addon.
# An addon is part of an already initialized lifecycle. This API function is
# only intended to be used for providers of specialised Project Init
# implementations, e.g. providers with a specialised main form implementation.
# Normal users and organisations wishing to adapt and extend the default
# Project Init implementation should do so by using the addon mechanism.
# Normally, there is no need for an external consumer of Project Init to
# provide his own lifecycle or main form implementation.
# Only use this function if you know what you are doing.
#
function project_init_process_quickstart() {
  _load_version_base;

  if (( ${#ARG_QUICKSTART_NAMES[@]} == 0 )); then
    logW "No quickstart name specified";
    _cancel_quickstart $EXIT_FAILURE;
  fi

  get_boolean_property "sys.quickstart.base.disable" "false";
  if [[ "$PROPERTY_VALUE" == "false" ]]; then
    if ! _load_quickstart_definitions "${SCRIPT_LVL_0_BASE}"; then
      failure "Failed to load base system quickstart code file";
    fi
  fi

  # Check for quickstart addons
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    _load_quickstart_definitions "$PROJECT_INIT_ADDONS_DIR";
    if (( $? == 2 )); then
      failure "Failed to load quickstart function definitions from addon";
    fi
  fi

  local quickstart_function="";
  local qs_fn_prefix="quickstart_";
  local n=${#ARG_QUICKSTART_NAMES[@]};
  local i;
  # First validate that all Quickstart functions are defined
  # and cancel early if one is not available
  for (( i=0; i<n; ++i )); do
    quickstart_function="${qs_fn_prefix}${ARG_QUICKSTART_NAMES_NORM[$i]}";
    if [[ $(type -t "$quickstart_function") != function ]]; then
      logW "No quickstart function found for name '${ARG_QUICKSTART_NAMES[$i]}'";
      _cancel_quickstart $EXIT_FAILURE;
    fi
  done

  local quickstart_fn_status=0;
  for (( i=0; i<n; ++i )); do
    quickstart_function="${qs_fn_prefix}${ARG_QUICKSTART_NAMES_NORM[$i]}";
    # Call Quickstart function
    $quickstart_function;
    quickstart_fn_status=$?;
    if (( quickstart_fn_status != QUICKSTART_STATUS_OK )); then
      if (( quickstart_fn_status != QUICKSTART_STATUS_NOWARN )); then
        logW "Quickstart function ${quickstart_function}() returned" \
             "non-zero status code $quickstart_fn_status";
        logW "Cancelling operation due to failed Quickstart function";
      fi
      _cancel_quickstart $QUICKSTART_STATUS_FAILURE;
    fi
    _replace_default_subst_vars;
    # Check for unreplaced substitution variables
    if _find_subst_vars; then
      local substvar="";
      for substvar in "${_FOUND_SUBST_VARS[@]}"; do
        logW "Substitution variable was not replaced: '${substvar}'";
        # Remove subst var from copied file
        replace_var "$substvar" "";
      done
    fi
  done
  return 0;
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
# With read:
# out_array=();
# while IFS='' read -r line; do
#   out_array+=("$line");
# done < <(_sort_file_paths "${in_array[@]}");
#
# Or shorter with mapfile:
# mapfile -t in_array < <(_sort_file_paths "${in_array[@]}");
#
function _sort_file_paths() {
  local _fpaths=("$@");
  local _path="";
  local _fname="";
  for _fpath in "${_fpaths[@]}"; do
    # Get the file name from the absolute path
    _fname=$(basename "${_fpath}");
    # Add the file name in front of the absolute path
    echo "${_fname}?${_fpath}";
  done |sort |cut -d? -f2
}

# Finds all files located under the specified base directory.
#
# This function searches for the files and/or directories located under
# the base directory specified by the first argument. It searches either for
# regular files, directories or both based on the second argument.
# The paths of the found files/directories are filtered based on the names
# and/or name patterns given as an optional list after second argument and then
# stored in the $_FOUND_FILES global variable.
#
# Args:
# $1 - The target path where to start search from. This is a mandatory argument.
# $2 - The file type to filter the results by. Either 'f' for regular files,
#      'd' for directories or 'f,d' for both regular files and directories.
#      This is a mandatory argument.
# $@ - The list of file/directory names and/or patterns to filter the results by.
#      This is an optional argument.
#
# Returns:
# 0  - If the search operation was successful.
# nz - If an error occurred. Is effectively the exit status of the 'find'
#      command used internally.
#
# Globals:
# _FOUND_FILES - The array variable in which the paths of all found
#                files will be stored.
#
function _find_files_impl() {
  local target_path="$1";
  local file_types="$2";
  shift 2;
  local match_ext_list=("$@");
  # Build arg string for find command
  local file_args=();
  local isfirst=true;
  local f="";
  for f in "${match_ext_list[@]}"; do
    if [[ $isfirst == true ]]; then
      isfirst=false;
      # The first item does not have an '-o' option
      file_args+=(-name "$f");
    else
      file_args+=( -o -name "$f");
    fi
  done

  local find_args=("-type");
  find_args+=("$file_types");
  if (( ${#file_args[@]} > 0 )); then
    find_args+=("${file_args[@]}");
  fi

  _FOUND_FILES=();
  local found_files="";
  # List all files matching an ext or file name
  found_files=$(find "$target_path" "${find_args[@]}");
  local cmd_find_status=$?;
  if (( cmd_find_status != 0 )); then
    return $cmd_find_status;
  fi
  # Save the internal field separator
  local IFS_ORIG="$IFS";
  # Set the IFS to a new line char
  IFS="${_NL}";
  for f in $found_files; do
    _FOUND_FILES+=("$f");
  done
  # Reset the original IFS value
  IFS="$IFS_ORIG";
  return 0;
}

# [API function]
# Finds all files to be processed by the project initialization operation.
#
# This function searches for files eligible for variable substitution.
# The search is conducted in the project target directory
# and is done recursively. The paths to the found files are then cached
# for internal usage.
#
# This function should be called every time the files in the project target
# directory are changed, i.e. files are added, moved, or deleted manually
# without the usage of the file processing functions, e.g. the move_file()
# or copy_resource() function. Changes of the file contents are irrelevant.
# Calling this function ensures that the internally used file cache is
# up-to-date after the project structure has changed. The file processing API
# functions handle this for the user so usually this function only has to be
# called when init code changes the project files manually, e.g. by directly
# using the mv or cp commands, etc. In Quickstart mode this function is not
# applicable as files should only be copied by the respective API functions.
#
function find_all_files() {
  if ! _check_no_quickstart; then
    return 1;
  fi
  CACHE_ALL_FILES=(); # Clear cache
  # Find all regular files matching an ext or file name
  _find_files_impl "$var_project_dir" "f" "${LIST_FILES_TXT[@]}";
  local cmd_status=$?;
  if (( cmd_status != 0 )); then
    logE "Failed to update internal file cache:";
    logE "Command 'find' returned non-zero exit status $cmd_status";
    failure "Failed to update internal file cache." \
            "Your system might be using an incompatible version of 'find'";
  fi
  # Copy found files to cache
  local found_file="";
  for found_file in "${_FOUND_FILES[@]}"; do
    CACHE_ALL_FILES+=("$found_file");
  done
}

# [API function]
# Copies all project source template files to the project target directory.
#
# This function copies all files in the Project Init source directory to the
# Project Init target directory indicated by the $var_project_dir variable.
# The project template source directory must exist and not be empty.
#
# As a result of this operation, file processing functions can be used after
# the call to this function returns, with the relative path arguments to those
# file processing functions usually being relative to the project target directory.
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
# CURRENT_LVL_PATH - The path to the current init level dir.
#                    Used when no path arg is specified
#
function project_init_copy() {
  local files_source="$1";
  if ! _check_no_quickstart; then
    return 1;
  fi
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
  if [ -z "$files_source" ]; then
    files_source="$CURRENT_LVL_PATH/source";
  fi
  # Check if source is directory
  if ! [ -d "$files_source" ]; then
    logE "Project source template directory does not exist" \
         "or is not a directory:";
    logE "at: '$files_source'";
    failure "Project source template directory not found";
  fi
  # Check that the source directory is not empty
  if [ -z "$(ls $files_source)" ]; then
    logE "Project source template directory is empty:";
    logE "at: '$files_source'";
    failure "Cannot initialize new project." \
            "Project source template directory must not be empty";
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
  readonly PROJECT_INIT_USED_SOURCE="$files_source";
  # Set file cache
  find_all_files;
  # Signal files have been copied
  _FLAG_PROJECT_FILES_COPIED=true;
}

# Removes all duplicates from the specified strings.
#
# This function returns all provided strings, dumped to stdout, while
# removing duplicates, i.e. all unique items are returned. The output lines
# are sorted by means of the 'sort' command.
#
# Args:
# $@ - A series of strings to be filtered for uniqueness.
#
# Stdout:
# All unique strings, on separate lines, in the series of specified strings,
# dumped to stdout.
#
function _unique_items() {
  local items=("$@");
  local item="";
  for item in "${items[@]}"; do
    echo "$item";
  done |sort -u;
}

# Indicates whether the specified element is part of the given array.
#
# The first argument is the element to check whether it is part of the array,
# all subsequent arguments are considered part of the array.
#
# Args:
# $1 - The element to check for membership in the array of subsequent elements.
# $@ - The array of elements to go through.
#
# Returns:
# 0 - If the specified element is in the specified array.
# 1 - If the specified element is not in the specified array.
#
# Globals:
# _FOUND_ARRAY_MEMBER_IDX - The array index at which the specified element was found.
#                           This variable is set by this function. If the array
#                           does not contain the specified element, this variable is
#                           set to an empty string.
#
function _array_contains() {
  local element="$1";
  shift;
  local array=("$@");
  local item_idx=0;
  local item="";
  for item in "${array[@]}"; do
    if [[ "$item" == "$element" ]]; then
      _FOUND_ARRAY_MEMBER_IDX=$item_idx;
      return 0;
    fi
    ((++item_idx));
  done
  _FOUND_ARRAY_MEMBER_IDX="";
  return 1;
}

# Finds all substitution variables contained in the tracked files.
#
# This function searches all files within the cache for any unreplaced substitution
# variable and stores the unique names of all such found items (without the
# leading '${{' and trailing '}}') in the $_FOUND_SUBST_VARS global variable.
#
# Returns:
# 0 - If the search operation found at least one unreplaced substitution variable.
# 1 - If no unreplaced substitution variable was found.
#
# Globals:
# CACHE_ALL_FILES   - The list of files to be scanned for unreplaced
#                     substitution variables.
# _FOUND_SUBST_VARS - The array variable in which the names of all found
#                     substitution variable will be stored.
#
function _find_subst_vars() {
  _FOUND_SUBST_VARS=(); # Reset
  local subvar;
  local subvar_len=0;
  local file;
  for file in "${CACHE_ALL_FILES[@]}"; do
    if [ -d "$file" ]; then
      continue; # Ignore directories
    fi
    if ! [ -r "$file" ]; then
      continue; # Ignore non-existing/non-readable regular files
    fi
    # Subst vars cannot have IFS chars or special chars used
    # in glob expansion, so here one line equals one word.
    # shellcheck disable=SC2013
    for subvar in $(grep -o '\${{VAR_[0-9A-Z_]\+}}' "$file"); do
      subvar_len=$(( ${#subvar}-5 ));
      _FOUND_SUBST_VARS+=("${subvar:3:subvar_len}");
    done
  done

  # Remove duplicates
  if (( ${#_FOUND_SUBST_VARS[@]} > 0 )); then
    mapfile -t _FOUND_SUBST_VARS < <(_unique_items "${_FOUND_SUBST_VARS[@]}");
    return 0;
  else
    return 1;
  fi
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
  local subvar="";
  local subvar_len=0;
  local f="";
  for f in "${CACHE_ALL_FILES[@]}"; do
    if [ -d "$f" ]; then
      continue; # Ignore directories
    fi
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
    # Subst vars cannot have IFS chars or special chars used
    # in glob expansion, so here one line equals one word.
    # shellcheck disable=SC2013
    for subvar in $(grep -o '\${{VAR_[0-9A-Z_]\+}}' "$f"); do
      found_subvars+=("$subvar");
    done
  done

  # Check if at least one substitution var was found
  if (( ${#found_subvars[@]} > 0 )); then
    # Filter out duplicates to simplify warn messages
    mapfile -t found_subvars < <(_unique_items "${found_subvars[@]}");
    for subvar in "${found_subvars[@]}"; do
      subvar_len=$(( ${#subvar}-5 ));
      local subvar_id="${subvar:3:subvar_len}";
      logW "Substitution variable not replaced: '${subvar_id}'";
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
      if [[ -n "$line" && "$line" != \#* ]]; then
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
#                            must already be set when calling this function.
#
function _load_extension_map() {
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

# Indicates whether the given path is absolute.
#
# Args:
# $1 - The path to check. This is a mandatory argument.
#
# Returns:
# 0 - If the specified argument represents an absolute path.
# 1 - If the specified argument does not represent an absolute path.
#
function _is_absolute_path() {
  local path_to_check="$1";
  if [[ "$path_to_check" == /* ]]; then
    return 0;
  else
    return 1;
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
# print the corresponding information by means of the logI() function and
# return a non-zero status code.
#
# Args:
# $1 - A string representing the absolute path to check.
#
# Returns:
# 0 - If the specified argument is a valid path.
# 1 - If the specified path contains an invalid char.
# 2 - If the specified path is the root ('/').
# 3 - If the specified path contains double slashes ('//').
# 4 - If the specified path is not absolute.
# 5 - If the specified path has to valid base directory.
# 6 - If the underlying user has no write permission for the base directory
#     of the specified path.
#
function _check_is_valid_project_dir() {
  local arg_project_dir="$1";
  # Validate charset of given path.
  # Never allow ':' (colon) characters as this could lead to
  # problems with template includes where ':' is used as a delimiter
  local re="^[0-9a-zA-Z/_. -]+$";
  local pchar="";
  local i;
  for (( i=0; i<${#arg_project_dir}; ++i )); do
    pchar="${arg_project_dir:$i:1}";
    if ! [[ "${pchar}" =~ $re ]]; then
      logI "The project directory path has an invalid character: '${pchar}'";
      return 1;
    fi
  done
  # Check for invalid paths
  if [[ "$arg_project_dir" == "/" ]]; then
    logI "Cannot create project directory in root directory '/'";
    return 2;
  fi
  # Check against double slashes
  if [[ "$arg_project_dir" == *"//"* ]]; then
    logI "Invalid path entered: '//' (double slashes)";
    return 3;
  fi
  # Must be an absolute path
  if ! _is_absolute_path "$arg_project_dir"; then
    logI "The entered path is not absolute";
    return 4;
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
    logI "No valid base directory found";
    return 5;
  fi
  # Check for write permissions
  if ! [ -w "$existent_base_dir" ]; then
    logI "You do not have permission to write to the directory:"
    logI "at: '$existent_base_dir'";
    logI "Please enter a valid absolute path for the project directory";
    logI "and make sure that you have the filesystem rights to write";
    logI "at that location";
    return 6;
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
# will let the user reenter his answer until he provides a valid input or
# otherwise cancels the program.
#
# A special case for the selection item is the occurrence of the "None" string.
# If the last specified item equals "None", then if the user chooses that item
# the $USER_INPUT_ENTERED_INDEX variable will be set to an empty string.
#
# Since 1.7.0 a caller can use the $USER_INPUT_DEFAULT_INDEX variable
# to specify a default item for the case in which the user does not enter
# anything when prompted and simply hits enter.
#
# Args:
# $@ - A series of selection items.
#
# Stdout:
# A selection list is printed.
#
# Returns:
# 0 - In the case of a valid item selection made by the user.
# 1 - In the case of a default item selection due to the user
#     having hit enter.
#
# Globals:
# USER_INPUT_ENTERED_INDEX - Will be set by this function to contain
#                            the zero-based index of the item selected
#                            by the user, or the default index if specified.
# USER_INPUT_DEFAULT_INDEX - Can be set by the caller to contain the zero-based
#                            index of the item which should be selected by
#                            default if the user does not enter
#                            anything when prompted.
#
# Examples:
# my_list=("Item A" "Item B" "Item C");
# logI "Choose an item out of the list:";
# USER_INPUT_DEFAULT_INDEX=1; # Default to "Item B"
# read_user_input_selection "${my_list[@]}";
# index=$USER_INPUT_ENTERED_INDEX;
# logI "Selected Item: ${my_list[index]}";
#
function read_user_input_selection() {
  local selection_names=("$@");
  local length=${#selection_names[@]};
  # Check that we have something to select
  if (( length == 0 )); then
    _fail_illegal_call "No selection items specified";
  fi
  echo "";
  # Print all selectable options.
  # Align item names independent from total number of items.
  local spaces=1;
  local padding=${#length};
  ((++padding));
  local number=0;
  local i;
  for (( i=0; i<length; ++i )); do
    number=$((i+1));
    # Compute how many spaces need to be added between the
    # number of the item and its name.
    spaces=$(( padding - ${#number} ));
    echo -n "[$number]";
    local j;
    for (( j=0; j<spaces; ++j )); do
      echo -n " ";
    done
    echo "${selection_names[$i]}";
  done
  echo "";

  local valid_answer_given=false;
  local retry_prompt=true;
  local selected_item="";

  while [[ $valid_answer_given == false ]]; do
    if [[ "$PROJECT_INIT_TESTS_ACTIVE" == "1" ]]; then
      # In test mode. Print the configured answer.
      # If the provided test answer is invalid, then fail.
      retry_prompt=false;
      _get_form_answer;
      selected_item="$FORM_QUESTION_ANSWER";
      echo -e "${_READ_FN_INPUT_PROMPT}${selected_item}";
    else
      # Read user input
      read -e -r -p "${_READ_FN_INPUT_PROMPT}" selected_item;
    fi

    local default_index_used=false;
    local is_number="^[0-9]+$";
    # Check special case for "None" option
    if [ -z "$selected_item" ]; then
      if [ -n "$USER_INPUT_DEFAULT_INDEX" ]; then
        if [[ $USER_INPUT_DEFAULT_INDEX =~ $is_number ]]; then
          selected_item=$((USER_INPUT_DEFAULT_INDEX+1));
          default_index_used=true;
        else
          logE "Expected numeric value for variable USER_INPUT_DEFAULT_INDEX" \
               "but found '${USER_INPUT_DEFAULT_INDEX}'";
        fi
      fi
      local last_item_index=$((length-1));
      local last_item="${selection_names[last_item_index]}";
      if [[ "$last_item" == "None" ]]; then
        USER_INPUT_ENTERED_INDEX="";
        USER_INPUT_DEFAULT_INDEX=""; # Reset
        return 0;
      fi
    fi

    # Validate user input
    if ! [[ $selected_item =~ $is_number ]]; then
      # Input is not a number.
      # Check if it matches one of the selection items
      local is_valid=false;
      for (( i=0; i<length; ++i )); do
        if [[ "$selected_item" == "${selection_names[$i]}" ]]; then
          selected_item=$((i+1));
          is_valid=true;
          break;
        fi
      done
      if [[ $is_valid == false ]]; then
        if [[ $retry_prompt == true ]]; then
          logI "Invalid input";
          continue;
        else
          logE "Invalid input";
          failure "Please enter a valid number";
        fi
      fi
    fi
    if ((selected_item < 1 || selected_item > length)); then
      if [[ $retry_prompt == true ]]; then
        logI "Invalid number entered";
        continue;
      else
        logE "Invalid number entered";
        failure "Please enter the number of your selected item";
      fi
    fi
    valid_answer_given=true;
  done

  local index=$((selected_item-1));
  USER_INPUT_ENTERED_INDEX=$index;
  USER_INPUT_DEFAULT_INDEX=""; # Reset

  if [[ $default_index_used == true ]]; then
    return 1;
  fi

  get_boolean_property "sys.input.selection.numsubst" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    local selection_item="${selection_names[index]}";
    # Move cursor to line above and erase line
    echo -ne "\033[1A\033[2K";
    echo -e "${_READ_FN_INPUT_PROMPT}${selection_item}";
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
# If this function is called with no arguments, then the entered input of the
# user is not checked for any kind of validity or pattern. If the acceptable
# text should be constrained further, then this can be done by specifying an
# input validation function as the first argument. Such a validation function,
# if provided, will be called by this function after the user has submitted
# his answer. The user input is provided to the validation function as the
# first argument. The validation function should then validate the user input
# according to the underlying use case and return either 0 (zero) if the input
# is deemed valid, or non-zero if the input is deemed invalid.
# In the case of an invalid input, the user is prompted again to provide a
# new input. This process repeats until a valid input is provided by the user
# or the program is terminated or cancelled. It is recommended that a validation
# function logs some information in the case of a detected invalid input such
# that a user is informed about the cause of the invalidity.
#
# Since 1.7.0 a caller can use the $USER_INPUT_DEFAULT_TEXT variable
# to specify a default value for the case in which the user does not enter
# anything when prompted and simply hits enter. When the default value applies,
# a validation function is not used and the $USER_INPUT_ENTERED_TEXT variable
# is assigned the default value as is.
#
# Args:
# $1 - The input validation function to use. This is an optional argument.
#
# Returns:
# 0 - In the case of a valid text input.
# 1 - In the case of a default text value due to non-provided input by the user.
#
# Globals:
# USER_INPUT_ENTERED_TEXT - Will be set by this function to contain the text
#                           entered by the user, or the default value if specified.
# USER_INPUT_DEFAULT_TEXT - Can be set by the caller to contain the text value
#                           which should be assigned by default if the user
#                           does not enter anything when prompted.
#
# Examples:
# function _my_validation_name() {
#   local input="$1";
#   if [[ "$input" != "Hans" && "$input" != "Franz" ]]; then
#     logI "Only 'Hans' and 'Franz' are allowed names";
#     return 1;
#   fi
#   return 0;
# }
# 
# logI "What's your name?";
# USER_INPUT_DEFAULT_TEXT="Hans";
# read_user_input_text;
# name="$USER_INPUT_ENTERED_TEXT";
# logI "Hi ${name}! Nice to meet you.";
# 
# logI "What's the name of the other person?";
# read_user_input_text _my_validation_name;
# other_name="$USER_INPUT_ENTERED_TEXT";
# logI "So, the other person's name is ${other_name}.";
#
function read_user_input_text() {
  local _validation_function_arg=$1;
  local entered_text="";
  local entered_text="";
  local user_input_default_text="$USER_INPUT_DEFAULT_TEXT";
  USER_INPUT_DEFAULT_TEXT=""; # Reset
  local retry_prompt=true;

  while [[ $retry_prompt == true ]]; do
    if [[ "$PROJECT_INIT_TESTS_ACTIVE" == "1" ]]; then
      retry_prompt=false;
      _get_form_answer;
      entered_text="$FORM_QUESTION_ANSWER";
      echo -e "${_READ_FN_INPUT_PROMPT}${entered_text}";
    else
      read -e -r -p "${_READ_FN_INPUT_PROMPT}" entered_text;
    fi
    if [ -z "$entered_text" ] && [ -n "$user_input_default_text" ]; then
      USER_INPUT_ENTERED_TEXT="$user_input_default_text";
      return 1;
    fi
    if [ -n "${_validation_function_arg}" ]; then
      if [[ $(type -t ${_validation_function_arg}) == function ]]; then
        # Call given input validation function
        ${_validation_function_arg} "$entered_text";
        if (( $? == 0 )); then
          retry_prompt=false;
        elif [[ "$PROJECT_INIT_TESTS_ACTIVE" == "1" ]]; then
          # For invalid input in test mode: terminate to avoid further
          # execution of the program with potentially unsafe values.
          failure "Invalid input";
        fi
      else
        _make_func_hl "read_user_input_text";
        logE "Programming error: Invalid argument in function call:";
        logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
        logE "Validation function argument given to $HYPERLINK_VALUE is not" \
             "a callable function: '${_validation_function_arg}'";
        failure "Failed to process user input";
      fi
    else
      retry_prompt=false;
    fi
  done
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
# If the entered input is invalid, then this function will let the user
# reenter his answer until he provides a valid input or otherwise cancels
# the program.
#
# Supported text values for the boolean value of true:
# "true", "yes", "y", "1"
#
# Supported text values for the boolean value of false:
# "false", "no", "n", "0"
#
# All accepted text input is case insensitive.
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
  local entered_yes_no="";
  local valid_answer_given=false;
  local retry_prompt=true;

  while [[ $valid_answer_given == false ]]; do
    if [[ "$PROJECT_INIT_TESTS_ACTIVE" == "1" ]]; then
      retry_prompt=false;
      _get_form_answer;
      entered_yes_no="$FORM_QUESTION_ANSWER";
      echo -e "${_READ_FN_INPUT_PROMPT}${entered_yes_no}";
    else
      read -e -r -p "${_READ_FN_INPUT_PROMPT}" entered_yes_no;
    fi
    # Validate user input
    if [ -z "$entered_yes_no" ]; then
      if [ -z "$default_value" ]; then
        if [[ $retry_prompt == true ]]; then
          logI "Invalid input. Please enter either yes or no";
          continue;
        else
          logE "Invalid input";
          failure "Please enter either yes or no";
        fi
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
      if [[ $retry_prompt == true ]]; then
        logI "Invalid input. Please enter either yes or no";
        continue;
      else
        logE "Invalid input";
        failure "Please enter either yes or no";
      fi
      ;;
    esac
    valid_answer_given=true;
    USER_INPUT_ENTERED_BOOL=$entered_yes_no;
  done

  get_boolean_property "sys.input.yesno.boolsubst" "true";
  if [[ "$PROPERTY_VALUE" == "true" ]]; then
    # Move cursor to line above and erase line
    echo -ne "\033[1A\033[2K";
    echo -e "${_READ_FN_INPUT_PROMPT}${canonical_answer}";
  fi

  return 0;
}

# [API function]
# Copies a template resource to the destination path.
#
# This function makes the template resource specified by the first argument
# available to the project target at the path specified by the second argument.
# The source and destination arguments are handled differently depending on
# the underlying application mode.
#
# In the regular (form-based) application mode, if the source argument is
# relative, it is interpreted as being relative to the used project template
# source directory, i.e. the 'source' directory of the concrete project type
# selected by the user. The destination argument is interpreted as being relative
# to the project target directory. The underlying target project directory must
# already be created before calling this function. If the file in the project
# target directory does already exist, it will be replaced by the specified
# template resource.
#
# In Quickstart mode, if the source argument is relative, it is interpreted as
# being relative to the source root of the addon and base resources. If an addon
# resource exists at the path of the source argument, it takes precedence over
# any existing base resource. The destination argument is interpreted as being
# relative to the underlying current working directory. If the file at the
# specified destination already exists, it is not overwritten and this function
# will cause the application to cancel the entire Quickstart operation.
# 
# An absolute source path is used as is. The destination path must never be absolute.
# Regardless of the underlying application mode, if the source path denotes
# a directory instead of a regular file, the directory is copied as is
# including the entire content and all previously mentioned conditions
# and behaviours still hold.
#
# Since:
# 1.4.0
#
# Args:
# $1 - The path to the resource to copy. Either an absolute or relative path.
# $2 - The destination path to copy the resource to. The path must not be absolute.
#
# Returns:
# 0 - If the resource was successfully copied.
# 1 - If the resource could not be found.
# 2 - If the source resource exists but could not be copied.
#
# Examples:
# copy_resource "copy/this/res" "to/this/path/in/my/project";
#
function copy_resource() {
  local arg_src="$1";
  local arg_dest="$2";
  _require_arg "$arg_src" "No arguments specified";
  if [ -z "$arg_dest" ]; then
    arg_dest=$(basename "$arg_src");
  fi
  if _is_absolute_path "$arg_dest"; then
    _fail_illegal_call "The resource destination argument must not be absolute";
  fi
  # Mode-dependent path argument handling
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    #--------------------#
    # In Quickstart mode #
    #--------------------#
    if ! _is_absolute_path "$arg_src"; then
      local src_base_dir="${SCRIPT_LVL_0_BASE}";
      if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
        if [ -r "${PROJECT_INIT_ADDONS_DIR}/${arg_src}" ]; then
          src_base_dir="${PROJECT_INIT_ADDONS_DIR}";
        fi
      fi
      arg_src="${src_base_dir}/${arg_src}";
    fi
    arg_dest="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}/${arg_dest}";
    if [ -e "$arg_dest" ]; then
      logW "Cannot copy resource.";
      logW "File or directory already exists at destination and would be overwritten:";
      logW "at: '$arg_dest'";
      _cancel_quickstart $EXIT_FAILURE;
    fi
  else
    #----------------------------#
    # In regular form-based mode #
    #----------------------------#
    _ensure_project_files_copied;
    if ! _is_absolute_path "$arg_src"; then
      arg_src="${PROJECT_INIT_USED_SOURCE}/${arg_src}";
    fi
    arg_dest="${var_project_dir}/${arg_dest}";
  fi
  # Check whether source actually exists before calling cp
  if ! [ -r "$arg_src" ]; then
    logW "Cannot copy file resource '$arg_src'";
    logW "Resouce not found";
    return 1;
  fi
  # Differentiate between copying of regular files and directories
  if [ -d "$arg_src" ]; then
    #----------------#
    # Copy directory #
    #----------------#
    cp -r "$arg_src" "$arg_dest" 2>/dev/null;
    if (( $? != 0 )); then
      logW "Could not copy the following directory:";
      logW "Source: '$arg_src'";
      logW "Target: '$arg_dest'";
      return 2;
    fi
  else
    #-------------------#
    # Copy regular file #
    #-------------------#
    cp "$arg_src" "$arg_dest" 2>/dev/null;
    if (( $? != 0 )); then
      logW "Could not copy the following regular file:";
      logW "Source: '$arg_src'";
      logW "Target: '$arg_dest'";
      return 2;
    fi
  fi
  _file_cache_add "$arg_dest";
  return 0;
}

# [API function]
# Loads a shared template resource and copies it to the destination path.
#
# This function searches for a shared source template resource specified by
# the first argument, loads it if it exists and copies it to the location
# in the project target directory specified by the second argument.
# The underlying target project directory must already be created before
# calling this function.
#
# Addons resources are considered and can potentially override any shared
# template from the base resources. If the file in the project target
# directory, specified by the second argument, does already exist, it will
# be replaced by the specified shared template resource.
#
# Since:
# 1.3.0
#
# Args:
# $1 - The name of the shared resource to load and copy. This is the path of
#      the file, relative to the 'share' directory. The path must not be absolute.
# $2 - The destination file to copy the shared resource to. Must be a path
#      to a file in the project target directory. The path must not be absolute.
#
# Returns:
# 0 - If the shared resource was successfully copied.
# 1 - If the shared resource could not be found.
# 2 - If the shared resource exists but could not be copied.
#
# Examples:
# copy_shared "copy/this/shared/res" "to/this/path/in/my/project";
#
function copy_shared() {
  local arg_shared_name="$1";
  local arg_dest_path="$2";
  _require_arg "$arg_shared_name" "No arguments specified";
  if _is_absolute_path "$arg_shared_name"; then
    _fail_illegal_call "The shared resource name must not be an absolute path";
  fi
  _require_arg "$arg_dest_path" "No destination path argument specified";
  if _is_absolute_path "$arg_dest_path"; then
    _fail_illegal_call "The file destination must not be an absolute path";
  fi
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == false ]]; then
    _ensure_project_files_copied;
  fi
  # Check which file to load (from addon or base)
  local shared_res_file="${SCRIPT_LVL_0_BASE}/share/${arg_shared_name}";
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    local addon_res_file="${PROJECT_INIT_ADDONS_DIR}/share/${arg_shared_name}";
    if [ -r "$addon_res_file" ]; then
      shared_res_file="$addon_res_file";
    fi
  fi
  if ! [ -r "$shared_res_file" ]; then
    logW "Cannot copy shared resource '$arg_shared_name'";
    logW "Shared resouce not found";
    return 1;
  fi
  copy_resource "$shared_res_file" "$arg_dest_path";
  return $?;
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
# level directory, then the upper init levels are searched in reversed
# order, until the root init level is reached. If the root init level
# was reached and no suitable file can be found, then an empty string
# is dumped to stdout by this function.
#
# Deprecated:
# Since 1.3.0 this function is deprecated. Use load_var_from_file() instead.
#
# Args:
# $1 - The key of the substitution variable to load.
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
  if [[ $SUPPRESS_DEPRECATION_WARNING == false ]]; then
    # Cannot call _warn_deprecated() directly here because it prints
    # a warning to stdout, which would end up in the string value
    # dumped by this function
    echo "pi_deprecated_fn_load_var_used=1" > "${_FILE_DEPRECATED_FN_LOAD_VAR_USED}";
  fi
  # Convert to lower case
  arg_file=$(echo "$arg_file" |tr '[:upper:]' '[:lower:]');
  # Check for variable prefix
  if [[ "$arg_file" != var_* ]]; then
    arg_file="var_${arg_file}";
  fi
  # Add file extension
  arg_file="${arg_file}.txt";
  local var_content="";  # Default if no file is found
  # Load var content from first found file, starting in current init
  # level and sequentially going backwards.
  local init_lvl="$CURRENT_LVL_PATH";
  local i;
  for (( i=CURRENT_LVL_NUMBER; i>=0; --i )); do
    if [ -r "${init_lvl}/${arg_file}" ]; then
      # Read file content
      var_content="$(cat "${init_lvl}/${arg_file}")";
      break;
    fi
    init_lvl="$(dirname "$init_lvl")";
  done
  echo "$var_content";
}

# [API function]
# Loads the variable value with the specified key from
# the corresponding substitution variable file.
#
# The argument to this function represents the key of the substitution variable
# for which a var file should be loaded. The key can be specified in the
# complete format, i.e. with a 'VAR_'-prefix, or without that prefix.
# The variable key argument is case insensitive.
#
# The loaded variable value is assigned to the $VAR_FILE_VALUE global variable.
# Usually, this is then subsequently used to assign the actual
# global substitution variable (see example below).
#
# Variable files located in init levels always take precedence over
# equivalent variable files in shared var directories. Generally, the content
# of the first found applicable variable file is used. The search order depends
# on the currently active init level when this function is called.
# If no variable file can be found in the currently active init
# level directory, then the upper init levels are searched in reversed
# order, until the root init level is reached. Please note that all variable
# files within init levels must be placed in 'var' subdirectories of the
# underlying init level directories. If the root init level
# is reached and no suitable file can be found, then shared variable
# directories are searched. If still no applicable variable file is found,
# then the $VAR_FILE_VALUE global variable is set to an empty string.
#
# Shared variable files may be overridden by addons resources.
#
# Since:
# 1.3.0
#
# Args:
# $1 - The key of the substitution variable for which the value from
#      a var file should be loaded. This is a mandatory argument.
#
# Returns:
# 0 - If a substitution variable value file was found.
# 1 - If no substitution variable file was found.
#
# Globals:
# VAR_FILE_VALUE   - Holds the string value of the found substitution
#                    variable file. Might be empty if no var file was found.
#                    Is set by this function.
# CURRENT_LVL_PATH - The absolute path to the currently
#                    active init level directory.
#
# Examples:
# load_var_from_file "MY_KEY";
# var_my_key="$VAR_FILE_VALUE";
#
function load_var_from_file() {
  local arg_file="$1";
  _require_arg "$arg_file" "No argument specified";
  # Convert to lower case
  arg_file=$(echo "$arg_file" |tr '[:upper:]' '[:lower:]');
  # Check for variable prefix and remove if necessary
  if [[ "$arg_file" == var_* ]]; then
    arg_file="${arg_file:4}";
  fi
  # Variable value files are located in 'var' subdirectories
  arg_file="var/${arg_file}";
  local found=false;
  local var_value="";  # Default if no file is found
  # Load var content from first found file, starting in current init
  # level and sequentially going backwards.
  local init_lvl="$CURRENT_LVL_PATH";
  local i;
  for (( i=CURRENT_LVL_NUMBER; i>=0; --i )); do
    if [ -r "${init_lvl}/${arg_file}" ]; then
      found=true;
      # Read file content
      var_value="$(cat "${init_lvl}/${arg_file}")";
      break;
    fi
    init_lvl="$(dirname "$init_lvl")";
  done
  # Search in shared var store of addon resource
  if [[ $found == false ]]; then
    if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
      local addon_shared_var="${PROJECT_INIT_ADDONS_DIR}/share/${arg_file}";
      if [ -r "$addon_shared_var" ]; then
        found=true;
        var_value="$(cat "$addon_shared_var")";
      fi
    fi
  fi
  # Search in shared var store of base resource
  if [[ $found == false ]]; then
    local shared_var="${SCRIPT_LVL_0_BASE}/share/${arg_file}";
    if [ -r "$shared_var" ]; then
      found=true;
      var_value="$(cat "$shared_var")";
    fi
  fi
  VAR_FILE_VALUE="$var_value";
  if [[ $found == true ]]; then
    return 0;
  else
    return 1;
  fi
}

# Replaces all string occurrences in the given file.
#
# Args:
# $1 - The string to replace.
# $2 - The replacement string.
# $3 - The file to process.
#
# Returns:
# n - The exit status of the awk command.
#
# Stdout:
# The processed file content if in test mode.
#
function _replace_all_str_impl() {
  local arg_source="$1";
  local arg_target="$2";
  local arg_file="$3";
  local replaced_data;
  local awk_stat;
  arg_source="${arg_source//\\/\\\\}";
  arg_target="${arg_target//&/\\&}";
  # shellcheck disable=SC2030
  replaced_data=$(
      export replacement="$arg_target" &&                   \
        awk -v str="$arg_source"                            \
            '{ gsub(str, ENVIRON["replacement"]); print; }' \
            "$arg_file");

  awk_stat=$?
  if (( awk_stat == 0 )); then
    if [[ "$PROJECT_INIT_COMPAT_TESTS_ACTIVE" == "1" ]]; then
      echo "$replaced_data";
    else
      echo "$replaced_data" > "$arg_file";
    fi
  fi
  return $awk_stat;
}

# Replaces maximum the specified number of found occurrences in the given file.
#
# Args:
# $1 - The string to replace.
# $2 - The replacement string.
# $3 - The file to process.
# $4 - The maximum number of occurrences to replace.
#
# Returns:
# n - The exit status of the awk command.
#
# Stdout:
# The processed file content if in test mode.
#
function _replace_max_n_str_impl() {
  local arg_source="$1";
  local arg_target="$2";
  local arg_file="$3";
  local arg_limit="$4";
  local replaced_data;
  local awk_stat;
  arg_source="${arg_source//\\/\\\\}";
  arg_target="${arg_target//&/\\&}";
  # shellcheck disable=SC2031
  replaced_data=$(
      export replacement="$arg_target" && \
        awk -v limit=$arg_limit           \
            -v str="$arg_source"          \
            '{ while (limit>0 && sub(str, ENVIRON["replacement"])){limit-=1} }; { print; }' \
            "$arg_file");

  awk_stat=$?
  if (( awk_stat == 0 )); then
    if [[ "$PROJECT_INIT_COMPAT_TESTS_ACTIVE" == "1" ]]; then
      echo "$replaced_data";
    else
      echo "$replaced_data" > "$arg_file";
    fi
  fi
  return $awk_stat;
}

# [API function]
# Replaces strings in source files with the specified string.
#
# This function can be used in all modes. It searches for the text string pattern
# as specified by the first argument and replaces found occurrences with the text
# string of the second argument. The search pattern is interpreted as a regular
# expression, so character escaping might need to be applied by the caller if
# certain characters (e.g. '[' and ']') should be matched literally. If left
# unspecified, all files eligible for variable substitution are searched, otherwise
# the third argument may specify a concrete source file or a file extension pattern
# to limit the search process to the specified files. A file extension pattern must
# be indicated by the presence of a wildcard ('*') character in the argument. If the
# argument is a single wildcard character, then all files are matched (the default).
# By default, all found occurrences in each considered file are replaced with the
# specified string. This can be adjusted by the fourth argument, which can be a
# positive integer number specifying the maximum number of occurrences that should
# be replaced per file.
#
# When in regular (form-based) application mode, the project target directory must
# have already been created by means of the project_init_copy() function.
# When in Quickstart mode, the project target directory is the underlying
# Quickstart current working directory, i.e. where the Quickstart was initiated.
#
# Since:
# 1.8.0
#
# Args:
# $1 - The string to replace. This is interpreted as a regular expression.
#      This is a mandatory argument.
# $2 - The replacement string to use. This is a mandatory argument.
# $3 - The files or file extension to consider. This is an optional argument.
# $4 - The maximum number of times to replace a found string per processed file.
#      This is an optional argument.
#
# Returns:
# 0 - If all relevant files were successfully processed.
# 1 - If a specified source file does not exist or is not a regular file.
#
# Examples:
# # Replace all found strings everywhere in all files:
# replace_str "MyConstString" "The_Replacement_String";
#
# # Replace all occurrences of the pattern only in a specific file:
# replace_str "My[0-9].*A" "OtherB" "src/main/raven/Main.java";
#
# # Replace all occurrences only in all .java files:
# replace_str "MyA" "OtherB" "*.java";
#
# # Replace only the first occurrence in all files:
# replace_str "MyA" "OtherB" "*" 1;
#
function replace_str() {
  local arg_count=$#;
  local arg_source_str="$1";
  local arg_target_str="$2";
  local arg_file_spec="$3";
  local arg_file_count="$4";
  _require_arg "$arg_source_str" "No source string argument specified";
  if [ -z "$arg_target_str" ]; then
    if (( arg_count == 1 )); then
      _fail_illegal_call "No replacement string argument specified";
    fi
  fi
  if [ -n "$arg_file_spec" ]; then
    if _is_absolute_path "$arg_file_spec"; then
      _fail_illegal_call "The file filter argument must not be absolute";
    fi
  fi
  if [ -n "$arg_file_count" ]; then
    local is_number='^[0-9]+$';
    if ! [[ $arg_file_count =~ $is_number ]]; then
      _fail_illegal_call "The file count argument must be numeric";
    fi
  fi
  local scan_base_dir="";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    scan_base_dir="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}";
  else
    _ensure_project_files_copied;
    scan_base_dir="${var_project_dir}";
  fi

  # Determine the files to be searched
  local files_to_scan=();
  local file="";
  if [ -n "$arg_file_spec" ]; then
    if [[ "$arg_file_spec" == *'*'* ]]; then
      for file in "${CACHE_ALL_FILES[@]}"; do
        if [[ "$file" == "${scan_base_dir}/"${arg_file_spec} ]]; then
          files_to_scan+=("$file");
        fi
      done
    else
      file="${scan_base_dir}/${arg_file_spec}";
      if ! [ -e "$file" ]; then
        logW "Cannot replace strings in file '${arg_file_spec}': File does not exist";
        _make_func_hl "replace_str";
        logW "Cannot handle argument given to ${HYPERLINK_VALUE} function:";
        logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
        return 1;
      fi
      if [ -d "$file" ]; then
        logW "Cannot replace strings in file '${arg_file_spec}': File is a directory";
        _make_func_hl "replace_str";
        logW "Cannot handle argument given to ${HYPERLINK_VALUE} function:";
        logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
        return 1;
      fi
      files_to_scan+=("$file");
    fi
  else
    files_to_scan=("${CACHE_ALL_FILES[@]}");
  fi

  # Search and replace in all relevant files
  local awk_stat;
  for file in "${files_to_scan[@]}"; do
    if [ -z "$arg_file_count" ]; then
      _replace_all_str_impl "$arg_source_str" "$arg_target_str" "$file";
      awk_stat=$?
      if (( awk_stat != 0 )); then
        logE "Failed to replace occurrences of strings in file '${file}'"
        logE "Command awk returned non-zero exit status ${awk_stat}"
        failure "An error has occurred during source file processing";
      fi
    else
      _replace_max_n_str_impl "$arg_source_str" "$arg_target_str" "$file" $arg_file_count;
      awk_stat=$?
      if (( awk_stat != 0 )); then
        logE "Failed to replace string in file '${file}'"
        logE "Command awk returned non-zero exit status ${awk_stat}"
        failure "An error has occurred during source file processing";
      fi
    fi
  done
  return 0;
}

# [API function]
# Replaces all occurrences of the specified variable with the specified value.
#
# This function will go through every generated regular file, find all occurrences
# of the substitution variable and replace them with the specified value.
# The variable key can be specified in its full canonical form or in an
# abbreviated form without the "VAR_"-prefix.
#
# The variable value can be any arbitrary string, including an empty string.
# Using an empty string will effectively remove the variable from the
# file (replacing it with nothing). If the variable key corresponds to the only
# characters on the respective line, then that entire line is removed from the
# underlying file.
#
# If only the variable key is specified, then this function will try to load
# the variable value from the corresponding var file by means of the
# load_var_from_file() function. If such a file does not exist, then the variable
# value is set to the empty string, thus potentially removing the entire line
# containing the variable from the underlying source file. Therefore, if a
# variable should be explicitly replaced by an empty string, regardless of any
# var file, then the value argument ($2) must be specified as an empty string.
#
# Besides the key and value, a third argument can be passed to this function.
# That argument represents the file ending by which all present files will be
# filtered by. That way, it is possible to replace the same variable with
# different values in different files. Only one file ending can be specified
# in each function call. A full file name (e.g. Readme.txt) may also be used
# as such an argument.
#
# Args:
# $1 - The name of the variable to replace. The "VAR_" prefix is optional
#      and can be omitted. This argument is mandatory.
# $2 - The value that the variable will be replaced by. Can be an empty string.
#      This argument is optional.
# $3 - The file extension or file name to match files against. Only files which
#      are matched are processed by this function. This argument is optional.
#
# Examples:
# replace_var "MY_KEY";
# replace_var "MY_KEY" "";
# replace_var "MY_KEY" "This will be the var value";
# replace_var "VAR_TEST" "value only in .java files" "java";
#
function replace_var() {
  local _arg_count=$#;
  local _var_key="$1";
  local _var_value="$2";
  local _var_file_ext="$3";
  # Check given args
  if (( _arg_count == 0 )); then
    _fail_illegal_call "No arguments specified";
  fi
  _require_arg "${_var_key}" "Key argument cannot be an empty string";
  if (( ${#CACHE_ALL_FILES[@]} == 0 )); then
    if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
      return 1;
    fi
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

  # If this function was called with only the key arg, then we
  # load the var value from the corresponding var file
  if [ -z "${_var_value}" ]; then
    if (( _arg_count == 1 )); then
      load_var_from_file "${_var_key}";
      _var_value="$VAR_FILE_VALUE";
      # Backwards compatibility:
      # Var files might still exist in older format/location, so if not found by the
      # newer load_var_from_file() function, then call the deprecated load_var()
      # function to stay compatible.
      if [ -z "${_var_value}" ]; then
        SUPPRESS_DEPRECATION_WARNING=true;
        # If the file does not exist, then the empty string
        # is assigned to the variable value
        _var_value="$(load_var ${_var_key})";
        SUPPRESS_DEPRECATION_WARNING=false;
        if [ -n "${_var_value}" ]; then
          _FLAG_DEPRECATED_FEATURE_USED=true;
          get_boolean_property "sys.warn.deprecation" "true";
          if [[ "$PROPERTY_VALUE" == "true" ]]; then
            local depr_conf="sys.warn.deprecation=false";
            _make_func_hl "replace_var";
            logW "Deprecated behaviour:";
            logW "Calling $HYPERLINK_VALUE with only the key argument while" \
                 "using var files directly";
            logW "in init levels without a 'var' subdirectory is deprecated:";
            logW "with argument: '${_var_key}'";
            logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
            logW "Place your var file in a 'var' subdirectory instead or use '${depr_conf}'";
            logW "in your project.properties configuration to suppress this warning.";
            _show_helptext "W" "Addons#variable-substitution-files";
          fi
        fi
      fi
    fi
  fi

  # When the variable value contains literal ampersand chars ('&'), then those
  # must be escaped so that they are not interpreted by awk to mean the
  # matched text (i.e. the variable key) when using gsub() below. Since the
  # literal ampersand should end up like that in the final output, it must pass
  # both lexical as well as runtime level processing of awk. Only the latter is
  # still a concern since the used awk command below was changed to pass the
  # substitution value via the subshell environment instead of a command variable.
  # Therefore we must only replace each literal '&' with '\&' (one literal backslash).
  _var_value="${_var_value//&/\\&}";

  local f="";
  local line_num="";
  for f in "${CACHE_ALL_FILES[@]}"; do
    # Skip if file is a directory
    if [ -d "$f" ]; then
      continue;
    fi
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

    # For an enhanced formatting we remove every line entirely if
    # it contains only a variable declaration and the given variable
    # value is empty. Otherwise the handled file would contain
    # additional blank lines.
    if [ -z "${_var_value}" ]; then
      # Find all line numbers of lines containing the given variable key
      # shellcheck disable=SC2013
      for line_num in $(grep -n "\${{VAR_${_var_key}}}" "$f" \
                          |awk -F  ":" '{print $1}'); do

        # Get the line text and trim leading and trailing whitespaces
        local line="";
        line="$(sed -n "${line_num}p" < "$f" |xargs)";
        if [[ "$line" == "\${{VAR_${_var_key}}}" ]]; then
          # The line only contains the given variable key
          # without any other static text. So we remove that
          # line from the string
          local removed="";
          removed="$(awk 'NR!~/^('"$line_num"')$/' "$f")";
          # Overwrite the source file
          echo "$removed" > "$f";
        fi
      done
    fi

    # Replace declared variable
    local replaced="";
    # shellcheck disable=SC2030
    replaced="$(export value="${_var_value}" &&               \
                awk -v key='\\${{VAR_'"${_var_key}"'}}'       \
                    '{ gsub(key, ENVIRON["value"]); print; }' \
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
    local index="";
    index="$(echo "$replaced" 2> /dev/null \
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

# Loads all available project licenses.
#
# Searches in the 'licenses' resource directories of both the base
# resource directory and, if active, of the addon and populates
# the _PROJECT_AVAILABLE_LICENSES_* global arrays with the paths to the
# license resource and the names of the licenses, respectively.
# The arrays are populated in sync. The last item in both arrays will be set
# to 'NONE' for the path and 'None' for the name, to represent the choice of
# using no license for a project, but only if other license choices
# are available.
#
# Globals:
# _PROJECT_AVAILABLE_LICENSES_PATHS - Is reset and filled by this function.
# _PROJECT_AVAILABLE_LICENSES_NAMES - Is reset and filled by this function.
#
function _load_available_licenses() {
  local license_name="";
  local all_license_dirs=();
  local fpath="";
  get_boolean_property "sys.baselicenses.disable" "false";
  local baselicenses_disabled="$PROPERTY_VALUE";
  if [[ "$baselicenses_disabled" == "false" ]]; then
    for fpath in "${SCRIPT_LVL_0_BASE}/licenses"/*; do
      if [ -d "$fpath" ]; then
        license_name=$(basename "$fpath");
        if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
          if [ -f "${PROJECT_INIT_ADDONS_DIR}/licenses/${license_name}/DISABLE" ]; then
            continue;
          fi
        fi
        all_license_dirs+=("$fpath");
      fi
    done
  fi

  # Add the license directories from the addons to the list
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -d "$PROJECT_INIT_ADDONS_DIR/licenses" ]; then
      for fpath in "${PROJECT_INIT_ADDONS_DIR}/licenses"/*; do
        if [ -d "$fpath" ]; then
          if ! [ -f "${fpath}/DISABLE" ]; then
            all_license_dirs+=("$fpath");
          fi
        fi
      done
      # Check if the separator char used in the sort function
      # is part of one of the path strings
      for fpath in "${all_license_dirs[@]}"; do
        if [[ "$fpath" == *"?"* ]]; then
          logE "Invalid path encountered:";
          logE "'${fpath}'";
          logE "Path contains an invalid character: '?'";
          failure "One or more paths to a component of an addon has an invalid character." \
                  "Please make sure that the path to the addons directory does not"        \
                  "contain '?' characters";
        fi
      done
      mapfile -t all_license_dirs < <(_sort_file_paths "${all_license_dirs[@]}");
    fi
  fi

  # Construct the list of license dirs and names
  _PROJECT_AVAILABLE_LICENSES_PATHS=();
  _PROJECT_AVAILABLE_LICENSES_NAMES=();

  local dir="";
  local name="";
  local dir_name="";
  for dir in "${all_license_dirs[@]}"; do
    dir_name=$(basename "$dir");
    if [ -r "${dir}/license.txt" ]; then
      _PROJECT_AVAILABLE_LICENSES_PATHS+=("$dir");
      if [ -r "${dir}/name.txt" ]; then
        name=$(head -n 1 "${dir}/name.txt");
        _PROJECT_AVAILABLE_LICENSES_NAMES+=("$name");
      else
        logW "The license directory '${dir_name}' has no name file";
        _PROJECT_AVAILABLE_LICENSES_NAMES+=("$dir_name");
      fi
    else
      logW "The license directory does not have a 'license.txt' file:";
      logW "at: '${dir}'";
    fi
  done

  # Do not add 'None' option if nothing else is available
  if (( ${#_PROJECT_AVAILABLE_LICENSES_PATHS[@]} > 0 )); then
    # Add an option for no license
    _PROJECT_AVAILABLE_LICENSES_PATHS+=("NONE");
    _PROJECT_AVAILABLE_LICENSES_NAMES+=("None");
  fi
}

# Processes copyright substitution variables.
#
# Substitutes all copyright header variables with the copyright text applicable
# according to the file extension of the underlying file. If the active license
# is set to 'NONE', then copyright header substitution variables are removed
# from the files.
#
# Args:
# $@ - A series of file extensions representing the project source
#      files in which copyright information should be processed.
#
# Globals:
# _PROJECT_SELECTED_LICENSE_PATH - The path to the active license resource.
# _PROJECT_SELECTED_LICENSE_NAME - The name of the active license resource.
# var_copyright_year             - The copyright year used in substitutions.
# var_copyright_holder           - The copyright holder info used in substitutions.
#
function _process_copyright_headers() {
  local all_file_ext=("$@");
  local active_license_dir="${_PROJECT_SELECTED_LICENSE_PATH}";
  local active_license_name="${_PROJECT_SELECTED_LICENSE_NAME}";
  if [ -n "$active_license_dir" ]; then
    if [[ "$active_license_dir" != "NONE" ]]; then
      _load_extension_map;
      local file_ext="";
      local header_ext="";
      local copyright_header_file="";
      local copyright_header_value="";
      for file_ext in "${all_file_ext[@]}"; do
        header_ext="$file_ext";
        # Check if the file extension is mapped to some other extension
        if [[ "${COPYRIGHT_HEADER_EXT_MAP[$header_ext]+1}" == "1" ]]; then
          header_ext="${COPYRIGHT_HEADER_EXT_MAP[${header_ext}]}";
        fi
        copyright_header_value="";
        copyright_header_file="${active_license_dir}/header.${header_ext}";
        if [ -r "$copyright_header_file" ]; then
          # Read in the license declaration legal text from the file
          copyright_header_value=$(cat "$copyright_header_file");
        else
          logW "License header template file not found for '${active_license_name}'";
          logW "Please create a template" \
               "file '${active_license_dir}/header.${header_ext}'";
        fi
        # First substitute the header var and then later the
        # year and copyright holder vars inside the header
        replace_var "COPYRIGHT_HEADER" "$copyright_header_value" "$file_ext";
      done
    fi
  fi

  # Replace additional copyright info vars, which also might be
  # part of the copyright boilerplate text already inserted
  replace_var "COPYRIGHT_YEAR"   "$var_copyright_year";
  replace_var "COPYRIGHT_HOLDER" "$var_copyright_holder";
  if [[ "$active_license_dir" == "NONE" ]]; then
    # Remove all copyright vars
    replace_var "COPYRIGHT_HEADER" "";
  fi
}

# [API function]
# Processes the copyright information for created project files.
#
# This function can only be used in Quickstart mode. Based on the given
# license name, this function will process and replace the copyright-related
# substitution variables in all files generated by the Quickstart process up
# to this point. Only files with an appropriate file extension in their name
# are considered for processing.
# The special license name argument 'None' will cause all copyright header
# substitution variables to be removed.
#
# Since:
# 1.6.0
#
# Args:
# $1 - The canonical name of the license for which to handle copyright headers.
#      May be specified as 'None' to remove copyright headers.
#
# Returns:
# 0  - In the case of success.
# nz - In the case of any failures.
#
# Examples:
# project_init_copyright_headers "Apache License 2.0";
#
function project_init_copyright_headers() {
  local license_name="$1";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == false ]]; then
    _make_func_hl "project_init_copyright_headers";
    logW "Calling $HYPERLINK_VALUE while not in Quickstart mode has no effect";
    logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    _make_func_hl "project_init_license";
    logW "Use the $HYPERLINK_VALUE function instead";
    return 1;
  fi
  _load_available_licenses;
  local license_path="";
  local i;
  for (( i=0; i<${#_PROJECT_AVAILABLE_LICENSES_NAMES}; ++i )); do
    if [[ "${_PROJECT_AVAILABLE_LICENSES_NAMES[i]}" == "$license_name" ]]; then
      license_path="${_PROJECT_AVAILABLE_LICENSES_PATHS[i]}";
      break;
    fi
  done
  if [[ "$license_path" == "" ]]; then
    _make_func_hl "project_init_copyright_headers";
    local _hl_project_init_license="$HYPERLINK_VALUE";
    logW "Invalid license name specified: '${license_name}'";
    logW "in the call to the $HYPERLINK_VALUE function";
    logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    return 2;
  fi
  _PROJECT_SELECTED_LICENSE_PATH="$license_path";
  _PROJECT_SELECTED_LICENSE_NAME="$license_name";

  # Get all unique applicable file extensions
  local all_file_ext=();
  local _file="";
  local _file_ext="";
  for _file in "${CACHE_ALL_FILES[@]}"; do
    if [ -d "${_file}" ]; then
      continue;
    fi
    _file="$(basename "${_file}")";
    _file_ext="${_file##*.}";
    if [[ "${_file_ext}" != "" && "${_file_ext}" != "${_file}" ]]; then
      all_file_ext+=("${_file_ext}");
    fi
  done
  mapfile -t all_file_ext < <(_unique_items "${all_file_ext[@]}");
  _process_copyright_headers "${all_file_ext[@]}";
  return 0;
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
  local all_file_ext=("$@");
  if ! _check_no_quickstart; then
    return 1;
  fi
  # Check API call order
  if [[ ${_FLAG_PROJECT_FILES_COPIED} == false ]]; then
    _make_func_hl "project_init_license";
    local _hl_project_init_license="$HYPERLINK_VALUE";
    _make_func_hl "project_init_copy";
    local _hl_project_init_copy="$HYPERLINK_VALUE";
    logE "Programming error in init script:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Missing call to project_init_copy() function:"                              \
            ""                                                                           \
            "The script in init level $CURRENT_LVL_NUMBER has called the "               \
            "${_hl_project_init_license} function without having previously called "     \
            "the ${_hl_project_init_copy} function. Please make sure that the 'init.sh'" \
            "script calls all mandatory API functions in the correct order."             \
            "";
  fi

  if (( ${#all_file_ext[@]} < 2 )); then
    if [ -z "${all_file_ext[0]}" ]; then
      _make_func_hl "project_init_license";
      logW "No file extensions specified in the call" \
           "to the $HYPERLINK_VALUE function.";
      logW "Copyright header variables in source files will not be replaced.";
      logW "Please specify in the call to the project_init_license() function all file";
      logW "extensions of project source files for which copyright headers exist";
      warning "Copyright header variables could not be replaced";
    fi
  fi
  # Check if a license was specified by the user
  if [ -n "$var_project_license_dir" ]; then
    if [[ "$var_project_license_dir" != "NONE" ]]; then
      if [ -z "$PROJECT_INIT_LICENSE_FILE_NAME" ]; then
        logW "Project license file name must not be empty.";
        PROJECT_INIT_LICENSE_FILE_NAME="LICENSE";
      fi
      # Copy the main license file
      local license_src="${var_project_license_dir}/license.txt";
      if [ -r "$license_src" ]; then
        if ! copy_resource "$license_src" "$PROJECT_INIT_LICENSE_FILE_NAME"; then
          logE "An error occurred while trying to copy the license source file:";
          logE "Source: '${license_src}'";
          logE "Copy to target project as: '${PROJECT_INIT_LICENSE_FILE_NAME}'";
          failure "Failed to copy license file to project directory";
        fi
      else
        logW "License file could not be created.";
        # shellcheck disable=SC2154
        logW "Failed to find license legal text file for '$var_project_license'.";
        logW "Please add the legal text to the file '${license_src}'.";
        warning "The initialized project has a missing '${PROJECT_INIT_LICENSE_FILE_NAME}' file";
      fi
    fi

    replace_var "PROJECT_LICENSE"  "$var_project_license";
    if [[ "$var_project_license_dir" == "NONE" ]]; then
      replace_var "LICENSE_README_NOTE" "This project has not been licensed.";
    else
      replace_var "LICENSE_README_NOTE" \
                  "This project is licensed under $var_project_license.";
    fi
  fi

  _process_copyright_headers "${all_file_ext[@]}";
  # Signal license is set up
  _FLAG_PROJECT_LICENSE_PROCESSED=true;
}

# Processes all include directives in copied project source template files.
#
# This function scans all source template files that were previously copied into
# the project target directory. Any found include directive will be replaced by the
# corresponding shared source template file. Addons resources are considered and
# can potentially override any shared template from the base resources.
#
# Returns:
# 0 - If all found include directives could be processed.
# 1 - If at least one error has occurred.
#
# Globals:
# var_project_dir - The path to the project directory, which will be scanned
#                   recursively for files containing include directives.
#
function _process_include_directives() {
  local line="";
  local found_file="";
  local line_num=0;
  local include_directive="";
  local include_target="";
  local include_value="";
  local replaced="";
  local regex_numeric="^[0-9]+$";
  local awk_stat=0;
  local incl_len=0;

  local SHARED_TEMPLATES_BASE="${SCRIPT_LVL_0_BASE}/share";
  local SHARED_TEMPLATES_ADDONS="";
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    SHARED_TEMPLATES_ADDONS="${PROJECT_INIT_ADDONS_DIR}/share";
  fi
  local n_errors=0;

  # Search for files in the project target directory which have include directives
  local all_includes="";
  all_includes=$(grep --recursive                  \
                      --line-number                \
                      --regexp='^${{INCLUDE:.*}}$' \
                      "$var_project_dir");

  # Process found includes
  for line in $all_includes; do
    # Pattern:
    # found_file:line_num:${{INCLUDE:the/file/in/share}}
    # For example:
    # /proj/cmake/Util.cmake:1234:${{INCLUDE:lang/cmake/Util.cmake}}
    #                       ^    ^          ^                       
    #           f1          | f2 |    f3    |          f4           

    found_file=$(echo "$line" |cut -d: -f1);
    line_num=$(echo "$line" |cut -d: -f2);
    include_directive=$(echo "$line" |cut -d: -f4);

    # Check that the processed line number is an actual integer
    if ! [[ "$line_num" =~ $regex_numeric ]]; then
      ((++n_errors));
      continue;
    fi
    # Check field 4, which is the last one. It must end with '}}', otherwise
    # the path of the file to include contains a ':' character, which is
    # not allowed.
    if [[ "$include_directive" != *'}}' ]]; then
      ((++n_errors));
      logW "Include directive in source template contains an invalid ':' character:";
      logW "at: '$found_file' (line $line_num)";
      continue;
    fi
    # Remove the trailing '}}'
    incl_len=$(( ${#include_directive}-2 ));
    include_directive="${include_directive::incl_len}";
    # Absolute path to the included shared file.
    # Shared templates in the addons resource override any base ones
    if [ -n "$SHARED_TEMPLATES_ADDONS" ] \
      && [ -r "${SHARED_TEMPLATES_ADDONS}/${include_directive}" ]; then

      include_target="${SHARED_TEMPLATES_ADDONS}/${include_directive}";
    else
      include_target="${SHARED_TEMPLATES_BASE}/${include_directive}";
    fi
    # Ensure that the file actually exists
    if ! [ -r "$include_target" ]; then
      ((++n_errors));
      logW "Cannot include file '$include_directive'";
      logW "From include directive:";
      logW "at: '$found_file' (line $line_num)";
      continue;
    fi
    # Read the content of the included file
    include_value="$(cat "$include_target")";
    # Literal ampersand chars ('&') must be escaped before passing them
    # to awk because they have a special meaning, i.e. they match the
    # variable key when substituting.
    include_value="${include_value//&/\\&}";
    # Read the source file and replace the include directive with
    # the content of the included file. Read the variable value from
    # the environment to make awk use the string value as is
    # without interpretation of any escape sequences.
    # shellcheck disable=SC2031
    replaced="$(export value="${include_value}" &&                   \
                awk -v key='\\${{INCLUDE:'"${include_directive}"'}}' \
                    '{ gsub(key, ENVIRON["value"]); print; }'        \
                    "$found_file")";

    awk_stat=$?;
    if (( awk_stat != 0 )); then
      logE "Cannot include file '$include_directive'";
      logE "From include directive:";
      logE "at: '$found_file' (line $line_num)";
      failure "Failed to replace include directive. " \
              "Command awk returned non-zero exit status $awk_stat";
    fi
    # Replace file content
    echo "$replaced" > "$found_file";
  done

  # Check for errors
  if (( n_errors > 0 )); then
    local what="include directive";
    if (( n_errors > 1 )); then
      what="include directives"; # plural
    fi
    warning "A total of ${n_errors} ${what} could not be processed";
    return 1;
  fi
  return 0;
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
  if ! _check_no_quickstart; then
    return 1;
  fi
  # Check API call order
  if [[ ${_FLAG_PROJECT_LICENSE_PROCESSED} == false ]]; then
    _make_func_hl "project_init_process";
    local _hl_project_init_process="$HYPERLINK_VALUE";
    _make_func_hl "project_init_license";
    local _hl_project_init_license="$HYPERLINK_VALUE";
    logE "Programming error in init script:";
    logE "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    failure "Missing call to project_init_license() function:"                              \
            ""                                                                              \
            "The script in init level $CURRENT_LVL_NUMBER has called the "                  \
            "${_hl_project_init_process} function without having previously called "        \
            "the ${_hl_project_init_license} function. Please make sure that the 'init.sh'" \
            "script calls all mandatory API functions in the correct order."                \
            "";
  fi

  _process_include_directives;

  # Let form providers handle the init processing
  if [[ $(type -t "_project_init_process_forms") == function ]]; then
    _project_init_process_forms;
  fi

  replace_var "PROJECT_NAME"        "$var_project_name";
  # shellcheck disable=SC2154
  replace_var "PROJECT_NAME_LOWER"  "$var_project_name_lower";
  # shellcheck disable=SC2154
  replace_var "PROJECT_NAME_UPPER"  "$var_project_name_upper";
  # shellcheck disable=SC2154
  replace_var "PROJECT_DESCRIPTION" "$var_project_description";
  replace_var "PROJECT_DIR"         "$var_project_dir";
  # shellcheck disable=SC2154
  replace_var "PROJECT_LANG"        "$var_project_lang";
  _replace_default_subst_vars;

  # Call all functions for processing project files in the level order
  local max_lvl_number=$CURRENT_LVL_NUMBER;
  local max_lvl_path=$CURRENT_LVL_NUMBER;
  local _varname_script_lvl_path="";
  local lvl;
  for (( lvl=1; lvl<=max_lvl_number; ++lvl )); do
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
  _require_arg "${_lang_version_num}" "No version number specified";
  _require_arg "${_lang_version_str}" "No version label specified";
  if ! _array_contains "${_lang_version_num}" "${SUPPORTED_LANG_VERSIONS_IDS[@]}"; then
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
  _require_arg "${_lang_version}" "No arguments specified";
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
# Expands one or more namespace template directories to have the specified
# directory layout.
#
# In many project source tree structures the concept of a namespace where various
# source code is placed in is represented by a directory layout that resembles
# that namespace. One namespace level/component is represented by a separate
# subdirectory within the source tree. This function can be used to automatically
# expand a placeholder directory in a project source template structure to match
# a given namespace layout. All files and subdirectories located within the
# template's namespace placeholder directory are moved to the expanded
# subdirectory of the lowermost namespace component.
#
# The underlying target project directory must already be created before calling
# this function. At least two arguments must be specified. The first argument
# denotes the namespace layout to expand the target directories to. Namespace
# components are separated by slashes ('/'). All subsequent arguments denote the
# directories in the project template source tree that should be expanded to
# represent the given namespace. Multiple such directories can be specified in one
# function call at once for improved efficiency, but at least one must be specified.
# Each specified directory path must be relative to the root of the project source
# template directory. Arguments must never denote absolute paths.
#
# The file cache holding the data about all present files in the project directory
# to be initialized is automatically updated by this function.
# This function may not be used in Quickstart mode.
#
# Since:
# 1.5.0
#
# Args:
# $1 - The namespace to use when expanding the specified template directories.
#      Individual namespace levels are separated by '/' characters, however,
#      a namespace must not start or end with a slash.
#      This is a mandatory argument.
# $@ - The namespace template directories to expand, relative to the project
#      template source root directory. This is a mandatory argument. At least
#      one directory must be provided by the caller. Any namespace template
#      directory which does not exist in the template source is silently ignored.
#
# Examples:
# # The following example expands 'ns_template_dir' in the source tree
# # (as a subdirectory of 'src/main') to represent
# # the 'raven/sample/stuff' namespace.
# 
# expand_namespace_directories "raven/sample/stuff" "src/main/ns_template_dir";
#
# # Now the project template directory structure is:
# # 'src/main/raven/sample/stuff'
#
function expand_namespace_directories() {
  local arg_namespace="$1";
  shift;
  local arg_project_paths=("$@");
  if ! _check_no_quickstart; then
    return 1;
  fi
  _ensure_project_files_copied;
  _require_arg "$arg_namespace" "No namespace argument specified";
  if _is_absolute_path "$arg_namespace"; then
    _fail_illegal_call "Namespace argument must not start with '/'";
  fi
  if (( ${#arg_project_paths[@]} == 0 )); then
    _fail_illegal_call "No project directory paths specified";
  fi

  local path_source="";
  local path_source_parent="";
  local path_target="";
  local project_path="";
  local file="";
  for project_path in "${arg_project_paths[@]}"; do
    if _is_absolute_path "$project_path"; then
      logW "Omitting expansion of invalid namespace template directory.";
      logW "Path must not be absolute: '${project_path}'";
      continue;
    fi
    path_source="${var_project_dir}/${project_path}";
    if ! [ -d "$path_source" ]; then
      continue;
    fi

    path_source_parent="$(dirname "$path_source")";
    path_target="${path_source_parent}/${arg_namespace}";

    # The beginning (i.e. the name of the first directory) of the target
    # namespace layout path must not be the same as the namespace template
    # directory, otherwise we would overwrite the same directory
    if [[ "${path_source##*/}" == "${arg_namespace%%/*}" ]]; then
      logW "Cannot expand namespace template directory:";
      logW "at: '${path_source}'";
      logW "The specified namespace '${arg_namespace}' begins with the end of this path.";
      continue;
    fi

    # Create the target namespace directory layout
    if ! mkdir -p "$path_target"; then
      logE "Failed to create namespace target directory structure:";
      logE "at: '${path_target}'";
      failure "Failed to create target namespace";
    fi

    # Move all files and subdirectories that are direct children of the
    # namespace template source to the created real namespace directory
    for file in "$path_source"/*; do
      if ! mv "$file" "$path_target"; then
        logE "Failed to move file to namespace layout target directory:";
        logE "Source: '${file}'";
        logE "Target: '${path_target}'";
        failure "Failed to move source files to target namespace";
      fi
    done
    # Remove the original now empty placeholder namespace dir
    if ! rm -r "$path_source"; then
      logE "Failed to remove template source namespace placeholder directory:";
      logE "at: '${path_source}'";
      failure "Failed to expand namespace directory";
    fi
  done
  # Update file cache
  find_all_files;
  return 0;
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
  if ! _check_no_quickstart; then
    return 1;
  fi
  local next_dirs=();
  local next_names=();
  local dir="";
  local dir_name="";
  local name="";
  # Take path at current init level
  for dir in "${CURRENT_LVL_PATH}"/*; do
    if [ -d "$dir" ]; then
      dir_name=$(basename "$dir");
      if [ -f "${dir}/init.sh" ]; then
        next_dirs+=("$dir_name");
        if [ -r "${dir}/name.txt" ]; then
          name=$(cat "${dir}/name.txt");
          next_names+=("$name");
        else
          logW "Project init level directory '${dir_name}' has no name file:";
          logW "at: '${dir}'";
          next_names+=("$dir_name");
        fi
        # Check for invalid characters
        if [[ "$dir" == *"?"* ]]; then
          logE "Invalid path encountered:";
          logE "'${dir}'";
          logE "Path contains an invalid character: '?'";
          failure "One or more paths to a component has an invalid character." \
                  "Please make sure that the path to any directory does not"   \
                  "contain '?' characters";

        fi
      fi
    fi
  done
  local n_dirs=${#next_dirs[@]};
  if (( n_dirs == 0 )); then
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
  if (( n_dirs > 1 )); then
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
# 1 - If this function is called while in Quickstart mode.
#
# Globals:
# FORM_PROJECT_TYPE_NAME - The name selected out of the project
#                          type list displayed to the user.
# FORM_PROJECT_TYPE_DIR  - The path to the directory of the
#                          selected project type.
# FORM_QUESTION_ID       - project.type
#
# Examples:
# select_project_type "js" "JavaScript";
# selected_name="$FORM_PROJECT_TYPE_NAME";
# selected_dir="$FORM_PROJECT_TYPE_DIR";
#
function select_project_type() {
  local lang_id="$1";
  local lang_name="$2";
  if ! _check_no_quickstart; then
    return 1;
  fi
  _require_arg "$lang_id" "No language ID argument specified";
  if [ -z "$lang_name" ]; then
    _make_func_hl "select_project_type";
    logW "No language name argument specified in call" \
         "to ${HYPERLINK_VALUE} function:";
    logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
    lang_name="$lang_id";
  fi
  # Check current init level
  if (( CURRENT_LVL_NUMBER != 1 )); then
    _make_func_hl "select_project_type";
    logE "Project types can only be selected at init level 1.";
    logE "The call to the ${HYPERLINK_VALUE} function was made:";
    logE "at init level: ${CURRENT_LVL_NUMBER}";
    logE "at: '${CURRENT_LVL_PATH}'";
    failure "Programming error: Invalid call to ${HYPERLINK_VALUE} function."    \
            "Project types under a given language can only be selected while at" \
            "init level 1";
  fi
  # Array for storing the paths to all project
  # template dirs provided by the language
  local all_ptypes=();
  local dir="";
  if [[ ${_FLAG_PROJECT_LANG_IS_FROM_ADDONS} == false ]]; then
    get_boolean_property "${lang_id}.baseprojects.disable" "false";
    if [[ "$PROPERTY_VALUE" == "false" ]]; then
      local ptype_id="";
      for dir in "${CURRENT_LVL_PATH}"/*; do
        if [ -d "$dir" ]; then
          if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
            ptype_id="$(basename $dir)";
            if [ -f "${PROJECT_INIT_ADDONS_DIR}/${lang_id}/${ptype_id}/DISABLE" ]; then
              continue;
            fi
          fi
          all_ptypes+=("$dir");
        fi
      done
    fi
  fi

  # Add projects templates from addons
  if [ -n "$PROJECT_INIT_ADDONS_DIR" ]; then
    if [ -d "${PROJECT_INIT_ADDONS_DIR}/${lang_id}" ]; then
      all_ptypes+=("${PROJECT_INIT_ADDONS_DIR}/${lang_id}"/*);
      # Check if the separator char used in the sort function
      # is part of one of the path strings
      for fpath in "${all_ptypes[@]}"; do
        if [[ "$fpath" == *"?"* ]]; then
          logE "Invalid path encountered:";
          logE "'${fpath}'";
          logE "Path contains an invalid character: '?'";
          failure "One or more paths to a component of an addon has an invalid character." \
                  "Please make sure that the path to the addons directory does not"        \
                  "contain '?' characters";
        fi
      done
      mapfile -t all_ptypes < <(_sort_file_paths "${all_ptypes[@]}");
    fi
  fi

  # Construct the list of project dirs and names
  local project_type_dirs=();
  local project_type_names=();

  # Loop over all paths and filter viable candidates
  # representing base project types
  local dir_name="";
  local name="";
  for dir in "${all_ptypes[@]}"; do
    if [ -d "$dir" ]; then
      dir_name=$(basename "$dir");
      if [ -f "${dir}/init.sh" ]; then
        project_type_dirs+=("$dir");
        if [ -r "${dir}/name.txt" ]; then
          name=$(cat "${dir}/name.txt");
          project_type_names+=("$name");
        else
          logW "Project init type directory '${dir_name}' has no name file:";
          logW "at: '${dir}'";
          project_type_names+=("$dir_name");
        fi
      fi
    fi
  done

  # Check that at least one project type can be selected
  local n_ptypes=${#project_type_dirs[@]};
  if (( n_ptypes == 0 )); then
    logE "Cannot prompt for project type selection. No options available";
    failure "You have chosen to create a project using ${lang_name},"     \
            "however, no type of ${lang_name} project can be initialized" \
            "because no project template files could be found."           \
            "Please add at least one project type directory under"        \
            "the '${lang_id}' folder.";
  fi

  # Either prompt for a selection or automatically pick the
  # only available project type
  if (( n_ptypes > 1 )); then
    FORM_QUESTION_ID="project.type";
    logI "";
    logI "Select the type of ${lang_name} project to be created:";
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
  if ! _check_no_quickstart; then
    return 1;
  fi
  # Only take the directory name not the full path
  local dir_next="";
  dir_next="$(basename "$1")";
  if [[ "$dir_next" == "" ]]; then
    # Search all subdirs in current level dir
    # and pick the first applicable as the next
    local dir="";
    for dir in "${CURRENT_LVL_PATH}"/*; do
      if [ -d "$dir" ]; then
        if [ -f "${dir}/init.sh" ]; then
          dir_next="$(basename $dir)";
          logW "No next init directory specified in current" \
               "init level $CURRENT_LVL_NUMBER";
          logW "at '${CURRENT_LVL_PATH}'";
          logW "Automatically selected directory '${dir_next}' for" \
               "proceeding to next init level";

          break;
        fi
      fi
    done
    # Check again if any applicable dir was found
    if [[ "$dir_next" == "" ]]; then
      _make_func_hl "proceed_next_level";
      logE "Cannot find directory to source next init script";
      _show_helptext "E" "Introduction#init-levels";
      failure "Failed to proceed to next init level from current level directory:" \
              "at: '${CURRENT_LVL_PATH}'" "  "                                     \
              "Please specify the directory for the next init level in your"       \
              "call to the $HYPERLINK_VALUE function";
    fi
  fi
  # Set global vars to new values
  CURRENT_LVL_PATH="${CURRENT_LVL_PATH}/${dir_next}";
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
    if [ -r "${CURRENT_LVL_PATH}/icon.notif.png" ]; then
      # Set new icon from base resources
      _STR_NOTIF_SUCCESS_ICON="${CURRENT_LVL_PATH}/icon.notif.png";
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
  local next_lvl_script="${CURRENT_LVL_PATH}/init.sh";

  if ! [ -f "$next_lvl_script" ]; then
    logE "Cannot source init script for level $CURRENT_LVL_NUMBER";
    _show_helptext "E" "Introduction#init-scripts";
    failure "Failed to source init script for next init level." \
            "File does not exist: "                             \
            "at: '${next_lvl_script}'";
  fi

  source "$next_lvl_script";
}

# [API function]
# Checks whether a regular file exists within the project target directory.
#
# The file path argument is interpreted as relative to the project target directory.
# When in regular (form-based) application mode, the project target directory must have
# already been created by means of the project_init_copy() function before this check
# can be done. When in Quickstart mode, the project target directory is the underlying
# Quickstart current working directory, i.e. where the Quickstart was initiated.
# This function only checks for regular files and will report nonexistence for a file
# of any other file type.
#
# Since:
# 1.8.0
#
# Args:
# $1 - The relative path of the regular file to check in the project target directory.
#      The path must not be absolute. This is a mandatory argument.
#
# Returns:
# 0 - If the specified regular file exists.
# 1 - If the specified regular file does not exist.
#
# Examples:
# if file_exists "myfolder/my_src_file.txt"; then
#   echo "File does exist";
# fi
#
# if ! file_exists "main.py"; then
#   echo "Main file does not exist";
# fi
#
function file_exists() {
  local arg_file_path="$1";
  _require_arg "$arg_file_path" "No file argument specified";
  if _is_absolute_path "$arg_file_path"; then
    _fail_illegal_call "The file argument must not be absolute";
  fi

  local file_path="";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    file_path="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}/${arg_file_path}";
  else
    _ensure_project_files_copied;
    file_path="${var_project_dir}/${arg_file_path}";
  fi
  if [ -f "$file_path" ]; then
    return 0;
  fi
  return 1;
}

# [API function]
# Checks whether a directory exists within the project target directory.
#
# The file path argument is interpreted as relative to the project target directory.
# When in regular (form-based) application mode, the project target directory must have
# already been created by means of the project_init_copy() function before this check
# can be done. When in Quickstart mode, the project target directory is the underlying
# Quickstart current working directory, i.e. where the Quickstart was initiated.
# This function only checks for directory files and will report nonexistence for a file
# of any other file type.
#
# Since:
# 1.8.0
#
# Args:
# $1 - The relative path of the directory to check under the project target directory.
#      The path must not be absolute. This is a mandatory argument.
#
# Returns:
# 0 - If the specified directory exists.
# 1 - If the specified directory does not exist.
#
# Examples:
# if directory_exists "myfolder/other_subfolder"; then
#   echo "Directory does exist";
# fi
#
# if ! directory_exists "tests"; then
#   echo "Tests directory not found";
# fi
#
function directory_exists() {
  local arg_file_path="$1";
  _require_arg "$arg_file_path" "No file argument specified";
  if _is_absolute_path "$arg_file_path"; then
    _fail_illegal_call "The file argument must not be absolute";
  fi

  local file_path="";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    file_path="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}/${arg_file_path}";
  else
    _ensure_project_files_copied;
    file_path="${var_project_dir}/${arg_file_path}";
  fi
  if [ -d "$file_path" ]; then
    return 0;
  fi
  return 1;
}

# [API function]
# Writes text to a file within the project target directory.
#
# The file to write is specified by the first argument. The path is interpreted as
# relative to the project target directory. The content to write
# is specified by the second argument.
#
# When in regular (form-based) application mode, the project target directory must have
# already been created by means of the project_init_copy() function before a file
# can be written. If the specified file already exists, its content is overwritten.
# If it does not already exist, it is created.
#
# When in Quickstart mode, the project target directory is the underlying Quickstart
# current working directory, i.e. where the Quickstart was initiated. If the specified
# file already exists, it is only overwritten if it was previously created by
# a Quickstart function, otherwise the entire Quickstart operation is cancelled
# by this function. The file is created if it does not already exists.
#
# Since:
# 1.8.0
#
# Args:
# $1 - The relative path of the source file to write to in the project
#      target directory. The path must not be absolute. This is a mandatory argument.
# $2 - The file content to write to the specified file. Can be an empty string
#      or omitted. This is an optional argument.
#
# Returns:
# 0 - If the write operation was successful.
# 1 - If the write operation to the specified file has failed.
#
# Examples:
# write_file "src/project_file.txt" "The file content";
#
function write_file() {
  local arg_file_path="$1";
  local arg_file_data="$2";
  _require_arg "$arg_file_path" "No file argument specified";
  if _is_absolute_path "$arg_file_path"; then
    _fail_illegal_call "The file argument must not be absolute";
  fi

  local file_path="";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    file_path="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}/${arg_file_path}";
    if [ -e "$file_path" ]; then
      if ! _array_contains "$file_path" "${CACHE_ALL_FILES[@]}"; then
        _make_func_hl "write_file";
        logW "Cannot write to file '${arg_file_path}'";
        logW "A file may only be written to by the ${HYPERLINK_VALUE} function if it was";
        logW "previously generated by a Quickstart function";
        _cancel_quickstart $EXIT_FAILURE;
      fi
    fi
  else
    _ensure_project_files_copied;
    file_path="${var_project_dir}/${arg_file_path}";
  fi
  local add_file_to_cache=false;
  if ! [ -e "$file_path" ]; then
    add_file_to_cache=true;
  else
    if ! [ -f "$file_path" ]; then
      logW "Cannot write to file '${arg_file_path}'";
      logW "File already exists but is not a regular file";
      _cancel_quickstart $EXIT_FAILURE;
      return 1;
    fi
  fi
  if ! echo -ne "$arg_file_data" > "$file_path"; then
    logW "Could not write to file '${file_path}'";
    return 1;
  fi
  if [[ $add_file_to_cache == true ]]; then
    _file_cache_add "$file_path";
  fi
  return 0;
}

# [API function]
# Appends text to a file within the project target directory.
#
# The file to append to is specified by the first argument. The path is interpreted as
# relative to the project target directory. The content to append is specified by the
# second argument.
#
# When in regular (form-based) application mode, the project target directory must have
# already been created by means of the project_init_copy() function before a file
# can be appended to. If the specified file already exists, then the specified content
# is appended to the end of it. If it does not already exist, it is created first.
#
# When in Quickstart mode, the project target directory is the underlying Quickstart
# current working directory, i.e. where the Quickstart was initiated. If the specified
# file already exists, it is only modified if it was previously created by
# a Quickstart function, otherwise the entire Quickstart operation is cancelled
# by this function. The file is created first if it does not already exists.
#
# Since:
# 1.8.0
#
# Args:
# $1 - The relative path of the source file to append to in the project
#      target directory. The path must not be absolute. This is a mandatory argument.
# $2 - The file content to append to the specified file. Can be an empty string
#      or omitted. This is an optional argument.
#
# Returns:
# 0 - If the append operation was successful.
# 1 - If the append operation to the specified file has failed.
#
# Examples:
# append_file "src/project_file.txt" "The-file-content-to-append";
#
function append_file() {
  local arg_file_path="$1";
  local arg_file_data="$2";
  _require_arg "$arg_file_path" "No file argument specified";
  if _is_absolute_path "$arg_file_path"; then
    _fail_illegal_call "The file argument must not be absolute";
  fi

  local file_path="";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    file_path="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}/${arg_file_path}";
    if [ -e "$file_path" ]; then
      if ! _array_contains "$file_path" "${CACHE_ALL_FILES[@]}"; then
        _make_func_hl "append_file";
        logW "Cannot append to file '${arg_file_path}'";
        logW "A file may only be appended to by the ${HYPERLINK_VALUE} function if it was";
        logW "previously generated by a Quickstart function";
        _cancel_quickstart $EXIT_FAILURE;
      fi
    fi
  else
    _ensure_project_files_copied;
    file_path="${var_project_dir}/${arg_file_path}";
  fi
  local add_file_to_cache=false;
  if ! [ -e "$file_path" ]; then
    add_file_to_cache=true;
  else
    if ! [ -f "$file_path" ]; then
      logW "Cannot append to file '${arg_file_path}'";
      logW "File already exists but is not a regular file";
      _cancel_quickstart $EXIT_FAILURE;
      return 1;
    fi
  fi
  if ! echo -ne "$arg_file_data" >> "$file_path"; then
    logW "Could not append to file '${file_path}'";
    return 1;
  fi
  if [[ $add_file_to_cache == true ]]; then
    _file_cache_add "$file_path";
  fi
  return 0;
}

# [API function]
# Moves a file within the project target directory.
#
# The file specified by the first argument is moved to the target destination
# specified by the second argument. Both the source path and target path
# arguments are interpreted as relative to the project target directory.
#
# When in regular (form-based) application mode, the project target directory must have
# already been created by means of the project_init_copy() function before a file
# can be moved. If a file at the specified destination already exists, it is overwritten.
#
# When in Quickstart mode, the project target directory is the underlying Quickstart
# current working directory, i.e. where the Quickstart was initiated. If a file at
# the specified destination already exists, it is not overwritten and this function
# will cause the application to cancel the entire Quickstart operation.
#
# Since:
# 1.8.0
#
# Args:
# $1 - The relative path of the source file to move in the project target directory.
#      The source path must not be absolute. This is a mandatory argument.
# $2 - The relative path to the destination where to move the source file to
#      in the project target directory. The target path must not be absolute.
#      This is a mandatory argument.
#
# Examples:
# move_file "a_src_file.txt" "subdirA/subdirB/trgt_file.txt";
#
function move_file() {
  local arg_source="$1";
  local arg_target="$2";
  _require_arg "$arg_source" "No source file argument specified";
  _require_arg "$arg_target" "No target file argument specified";
  if _is_absolute_path "$arg_source"; then
    _fail_illegal_call "The source file argument must not be absolute";
  fi
  if _is_absolute_path "$arg_target"; then
    _fail_illegal_call "The target file argument must not be absolute";
  fi

  # Absolute path arguments passed to mv command
  local source_file="";
  local target_file="";

  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    source_file="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}/${arg_source}";
    target_file="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}/${arg_target}";
    if [ -e "$target_file" ]; then
      logW "Cannot move file '${arg_source}'";
      logW "File or directory already exists at destination and would be overwritten:";
      logW "at: '${arg_target}'";
      _cancel_quickstart $EXIT_FAILURE;
    fi
  else
    _ensure_project_files_copied;
    source_file="${var_project_dir}/${arg_source}";
    target_file="${var_project_dir}/${arg_target}";
  fi

  if ! [ -e "$source_file" ]; then
    logE "Failed to move file inside project directory";
    logE "Source file does not exist: '${arg_source}'";
    _cancel_quickstart $EXIT_FAILURE;
    failure "Failed to move source files";
  fi

  mv "${source_file}" "${target_file}" 2>/dev/null;
  local mv_stat=$?;
  if (( mv_stat != 0 )); then
    logE "Failed to move file inside project directory";
    logE "Command mv returned non-zero exit status ${mv_stat}";
    logE "Source: '${arg_source}'";
    logE "Target: '${arg_target}'";
    _cancel_quickstart $EXIT_FAILURE;
    failure "Failed to move source files";
  fi
  _file_cache_remove "$source_file";
  _file_cache_add "$target_file";
  return 0;
}

# [API function]
# Removes a file or directory within the project target directory.
#
# The specified file path argument is interpreted as relative to the
# project target directory.
#
# When in regular (form-based) application mode, the project target directory must
# have already been created by means of the project_init_copy() function before a file
# can be removed.
# 
# When in Quickstart mode, the project target directory is the underlying Quickstart
# current working directory, i.e. where the Quickstart was initiated. If the specified
# file or directory does not exist, or if it was not previously created by a Quickstart
# function, then this function will cause the application to cancel the
# entire Quickstart operation.
#
# Since:
# 1.8.0
#
# Args:
# $1 - The relative path of the file or directory to remove in the project
#      target directory. The path must not be absolute. This is a mandatory argument.
#
# Examples:
# remove_file "subdirA/the_src_file.txt";
#
function remove_file() {
  local arg_target="$1";
  _require_arg "$arg_target" "No file argument specified";
  if _is_absolute_path "$arg_target"; then
    _fail_illegal_call "The file argument must not be absolute";
  fi

  local target_file="";
  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    target_file="${_PROJECT_INIT_QUICKSTART_OUTPUT_DIR}/${arg_target}";
    if ! [ -e "$target_file" ]; then
      logW "Cannot remove file '${arg_target}'";
      logW "File or directory does not exist:";
      logW "at: '${target_file}'";
      _cancel_quickstart $EXIT_FAILURE;
    fi
    if ! _array_contains "$target_file" "${CACHE_ALL_FILES[@]}"; then
      _make_func_hl "remove_file";
      logW "Cannot remove file '${arg_target}'";
      logW "A file may only be removed by the ${HYPERLINK_VALUE} function if it was";
      logW "previously generated by a Quickstart function";
      _cancel_quickstart $EXIT_FAILURE;
    fi
  else
    _ensure_project_files_copied;
    target_file="${var_project_dir}/${arg_target}";
    if ! [ -e "$target_file" ]; then
      logW "Cannot remove file '${arg_target}'";
      logW "File or directory does not exist:";
      logW "at: '${BASH_SOURCE[1]}' (line ${BASH_LINENO[0]})";
      return 1;
    fi
  fi
  local file_type="file";
  if [ -d "$target_file" ]; then
    file_type="directory";
    rm -r "$target_file" 2>/dev/null;
  else
    rm "$target_file" 2>/dev/null;
  fi

  local cmd_rm_stat=$?;
  if (( cmd_rm_stat != 0 )); then
    logE "Failed to remove ${file_type} inside project directory";
    logE "Command rm returned non-zero exit status ${cmd_rm_stat}";
    logE "File: '${arg_target}'";
    _cancel_quickstart $EXIT_FAILURE;
    failure "Failed to remove source files";
  fi
  _file_cache_remove "$target_file";
  return 0;
}
