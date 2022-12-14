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
# *               ***   Functionality Test Driver Script   ***                *
# *                                                                           *
# #***************************************************************************#
#
# This is the entry point for a functionality test.
#


# The properties config file to be loaded for the test runs.
readonly _TESTS_PROPERTIES="tests/resources/project.properties";


# Loads the configuration files used in test mode and stores the
# data in the corresponding global variables.
#
# The caller should check the relevant PROJECT_INIT_TESTS_ACTIVE
# and PROJECT_INIT_TESTS_RUN_CONFIG environment variables before
# calling this function.
#
# Globals:
# _FORM_ANSWERS - The configured form answers from the test run file.
#                 Is declared and initialized by this function.
#
function _load_test_configuration() {
  declare -g -A _FORM_ANSWERS;
  if ! _read_properties "$PROJECT_INIT_TESTS_RUN_CONFIG" _FORM_ANSWERS; then
    logE "The configuration file for the test run has errors:";
    logE "at: '$PROJECT_INIT_TESTS_RUN_CONFIG'";
    failure "Failed to execute test run";
  fi
  # Adjust path if in test mode
  FORM_QUESTION_ID="project.dir";
  if _get_form_answer; then
    if [[ "$FORM_QUESTION_ANSWER" != "${TESTS_OUTPUT_DIR}"/* ]]; then
      local test_path="${TESTS_OUTPUT_DIR}/${FORM_QUESTION_ANSWER}";
      _FORM_ANSWERS["project.dir"]="$test_path";
    fi
  else
    logE "No project directory specified for test run.";
    logE "Add a 'project.dir' entry in the test run properties file:";
    logE "at: '$PROJECT_INIT_TESTS_RUN_CONFIG'";
    failure "Failed to execute test run";
  fi
  _read_properties "${_TESTS_PROPERTIES}";
}

function main() {
  local testpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)";
  local rootpath=$(dirname "$testpath");
  # Load core libraries
  source "$rootpath/libinit.sh";
  source "$rootpath/libform.sh";

  # Make sure this script is not executed by the root user
  if (( $(id -u) == 0 )); then
    logW "Cannot run tests as root user";
    exit $EXIT_FAILURE;
  fi

  start_project_init "$@";

  show_project_init_main_form;

  proceed_next_level "$FORM_MAIN_NEXT_DIR";

  finish_project_init;

  if (( ${_N_ERRORS} > 0 )); then
    logE "";
    local errtitle=" ${COLOR_RED}E R R O R${COLOR_NC} ";
    logE " o-------------------${errtitle}-------------------o";
    logE " |           Test run exited with errors           |";
    logE " o-------------------------------------------------o";
    logE "";
    exit $EXIT_FAILURE;
  fi

  local n_warnings=${#_WARNING_LOG[@]};
  if (( ${n_warnings} > 0 || ${_N_WARNINGS} > 0 )); then
    logW "";
    local warningtitle=" ${COLOR_ORANGE}W A R N I N G${COLOR_NC} ";
    logW " o-----------------${warningtitle}-----------------o";
    logW " |          Test run exited with warnings          |";
    logW " o-------------------------------------------------o";
    logW "";
    exit $EXIT_FAILURE;
  fi
  exit $EXIT_SUCCESS;

}

main "$@";
