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
# *                ***   Project Init Functionality Tests  ***                *
# *                                                                           *
# #***************************************************************************#


# The path to the tests directory
TESTPATH="";


function execute_test_run() {
  local testfile="$1";
  local test_run_status=0;
  source "$testfile";
  if [[ $(type -t "test_functionality") == function ]]; then
    test_functionality;
    test_run_status=$?;
  else
    logE "Test file '$testfile' does not define function 'test_functionality()'";
    test_run_status=3;
  fi
  unset -f test_functionality;
  unset -f test_functionality_result;
  return $test_run_status;
}

function test_functionality_with() {
  local config_file="$1";
  local title="";
  if [ -r "resources/$config_file" ]; then
    title=$(head -n 1 "resources/$config_file");
    if [[ "$title" == "# @NAME: "* ]]; then
      title="${title:9:60}";
    else
      title="with $config_file";
    fi
  fi
  declare -g -A TEST_FORM_ANSWERS;
  if ! _read_properties "resources/$config_file" TEST_FORM_ANSWERS; then
    logE "Test run configuration file is invalid";
    return 90;
  fi

  ASSERT_FILE_PATH_PREFIX="";
  if [[ "${TEST_FORM_ANSWERS[project.dir]+1}" == "1" ]]; then
    ASSERT_FILE_PATH_PREFIX="${TEST_FORM_ANSWERS[project.dir]}";
  fi

  export PROJECT_INIT_TESTS_RUN_CONFIG="$TESTPATH/resources/$config_file";
  printt "echo" "       Testing $title " "$LABEL_RUN";
  local output_stdout="";
  local output_stderr="";
  local test_status=0;
  local exit_status=0;
  local f_out_stderr="${_TESTS_OUTPUT_DIR}/run_stderr";
  output_stdout=$(bash "functionality_test_driver.sh" 2>"$f_out_stderr");
  exit_status=$?;

  if [ -r "$f_out_stderr" ]; then
    output_stderr=$(cat "$f_out_stderr");
  fi

  if (( $exit_status != 0 )); then
    test_status=1;
  fi

  if [[ "$output_stderr" != "" ]]; then
    test_status=2;
  fi

  if [ -z "$TERMINAL_NO_USE_CNTRL_CHARS" ]; then
    _erasechars "$LABEL_RUN";
  fi

  if (( $test_status == 0 )); then
    if [[ $(type -t "test_functionality_result") == function ]]; then
      test_functionality_result;
      if (( $? != 0 )); then
        test_status=3;
      fi
    fi
  fi

  if (( $test_status != 0 )); then
    echo -e "${LABEL_FAILED}\n";
    logE "Functionality test run exited with exit status $exit_status";
    if [[ "$output_stderr" != "" ]]; then
      logE "There was output captured from stderr (see below)";
    fi
    if (( $test_status == 3 )); then
      logE "The test run itself seems to have finished without critical failures, but";
      logE "there are missing or adverse project files in the generated output (see below)";
    fi
    logE "";
    logE "Captured output (stdout):";
    printt_sep;
    echo "$output_stdout";
    printt_sep;
    if [[ "$output_stderr" != "" ]]; then
      logE "";
      logE "Captured output (stderr):";
      printt_sep;
      local line="";
      while read -r line; do
        echo "        $line";
      done <<< "$output_stderr";
      printt_sep;
    fi
    local has_assert_fails=false;
    local _f="";
    if (( ${#ASSERT_FAIL_MISSING_FILES[@]} > 0 )); then
      has_assert_fails=true;
      logE "The generated project has missing files";
      logE "";
      for _f in "${ASSERT_FAIL_MISSING_FILES[@]}"; do
        logE "Missing file: '${_f}'";
      done
    fi
    if (( ${#ASSERT_FAIL_MISSING_DIRS[@]} > 0 )); then
      has_assert_fails=true;
      logE "The generated project has missing directories";
      logE "";
      for _f in "${ASSERT_FAIL_MISSING_DIRS[@]}"; do
        logE "Missing directory: '${_f}'";
      done
    fi
    if (( ${#ASSERT_FAIL_ADVERSE_FILES[@]} > 0 )); then
      has_assert_fails=true;
      logE "The generated project has adverse files";
      logE "";
      for _f in "${ASSERT_FAIL_ADVERSE_FILES[@]}"; do
        logE "Adverse file: '${_f}'";
      done
    fi
    if (( ${#ASSERT_FAIL_ADVERSE_DIRS[@]} > 0 )); then
      has_assert_fails=true;
      logE "The generated project has adverse directories";
      logE "";
      for _f in "${ASSERT_FAIL_ADVERSE_DIRS[@]}"; do
        logE "Adverse directory: '${_f}'";
      done
    fi
    if [[ $has_assert_fails == true ]]; then
      printt_sep;
    fi
    logE "";
  else
    echo -e "${LABEL_PASSED}\n";
  fi
  return $test_status;
}

function main() {
  local arg_keep_output=false;
  local arg_filter_runs="";
  local filter_runs=();
  for arg in "$@"; do
    case $arg in
      --keep-output)
      arg_keep_output=true;
      shift
      ;;
      --filter=*)
      arg_filter_runs="${arg:9}";
      # Count the number of delimiters
      ncommas="${arg_filter_runs//[^,]}";
      ncommas=${#ncommas};
      ((++ncommas));
      local i;
      local test_run_name="";
      for (( i=1; i<=${ncommas}; ++i )); do
        test_run_name="$(echo "$arg_filter_runs" |cut -d, -f${i})";
        filter_runs+=( "$test_run_name" );
      done
      shift
      ;;
      *)
      # Unknown arg
      echo "Internal error";
      echo "Unknown argument for functionality_tests.sh script: '$arg'";
      exit 1;
      ;;
    esac
  done
  TESTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)";
  cd "$TESTPATH";
  if ! source "../libinit.sh"; then
    echo "ERROR: Could not source libinit.sh library"
    return 1;
  fi
  if ! [ -d "$TESTPATH/resources" ]; then
    logE "Test resource directory not found";
    return 1;
  fi
  if ! [ -r "functionality_test_driver.sh" ]; then
    logE "Functionality test driver script not found";
    return 1;
  fi
  if ! source "utils.sh"; then
    logE "Test utilities could not be loaded";
    return 1;
  fi

  if [ -d "${_TESTS_OUTPUT_DIR}" ]; then
    logI "Clearing previously created test output directory";
    if ! rm -rf "${_TESTS_OUTPUT_DIR}"; then
      logW "Failed to clear test output directory: '${_TESTS_OUTPUT_DIR}'";
      return 1;
    fi
  fi

  if ! [ -d "${_TESTS_OUTPUT_DIR}" ]; then
    mkdir -p "${_TESTS_OUTPUT_DIR}";
    if (( $? != 0 )); then
      logE "Failed to create test output directory '${_TESTS_OUTPUT_DIR}'";
      return 1;
    fi
  fi

  logI "Testing functionality of Project Init";
  echo "";

  export PROJECT_INIT_TESTS_ACTIVE="1";
  local exit_status=0;
  local n_filter_runs=${#filter_runs[@]};
  if (( $n_filter_runs > 0 )); then
    # Only run specified test runs
    local testname="";
    for testname in ${filter_runs[@]}; do
      if [ -r "test_func_${testname}.sh" ]; then
        execute_test_run "test_func_${testname}.sh";
        exit_status=$?;
      else
        logE "Invalid name for functionality test run: '$testname'";
        logE "No such file: '${PWD}/test_func_${testname}.sh'";
        exit_status=1;
      fi
      if (( $exit_status != 0 )); then
        break;
      fi
    done
  else
    # Find all applicable test run script files
    for testfile in $(ls "$TESTPATH"); do
      if [[ "$testfile" == test_func_*.sh ]]; then
        execute_test_run "$testfile";
        exit_status=$?;
        if (( $exit_status != 0 )); then
          break;
        fi
      fi
    done
  fi

  if (( $exit_status != 0 )); then
    logE "Testing of functionality has not completed";
    logE "An error has occurred during a functionality test";
  else
    logI "Testing of functionality has completed";
    printt_ok "All functionality tests have passed:";
  fi

  if [[ $arg_keep_output == false ]]; then
    if [ -d "${_TESTS_OUTPUT_DIR}" ]; then
      if ! rm -rf "${_TESTS_OUTPUT_DIR}"; then
        logW "Failed to clear test output directory: '${_TESTS_OUTPUT_DIR}'";
      fi
    fi
  else
    logI "Generated output can be found at: '${_TESTS_OUTPUT_DIR}'";
  fi

  return $exit_status;
}

main "$@";
