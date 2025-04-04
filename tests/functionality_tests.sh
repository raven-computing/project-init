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
# *                ***   Project Init Functionality Tests  ***                *
# *                                                                           *
# #***************************************************************************#


# The path to the tests directory
TESTPATH="";
# The path to the directory where the test output files are placed in
TESTS_OUTPUT_DIR="";
# Boolean flag which is true only when doing functionality tests for
# external addons. Please note that this does not include the addons tests
# under BASEPATH/addons, for which this is still false
IS_ADDON_TESTS=false;
# Boolean flag indicating whether to print the captured standard output
# after a single successful test run
PRINT_CAPTURED_STDOUT=false;
# The associative array for the form answer data.
declare -A _FORM_ANSWERS;


# The testing facility entrypoint to initiate functionality test runs.
#
# The specified file must contain the test case by defining
# the test_functionality() function. If that function is not defined in
# the specified file, then this function will fail with an error statement.
#
# Args:
# $1 - A file containing the functionality test case.
#      This is a mandatory argument.
#
# Returns:
# 0  - If the functionality test run has finished successfully, without
#      any errors or warnings.
# nz - In the case of a test failure due to any reason.
#
function execute_test_run() {
  local testfile="$1";
  local test_run_status=0;
  source "$testfile";
  local is_base_addon_test_run=false;
  if [[ $IS_ADDON_TESTS == false && "$testfile" == test_func_addon_* ]]; then
    is_base_addon_test_run=true;
  fi
  if [[ $is_base_addon_test_run == true ]]; then
    export PROJECT_INIT_ADDONS_RES="${BASEPATH}/addons";
  fi
  if [[ $(type -t "test_functionality") == function ]]; then
    test_functionality;
    test_run_status=$?;
  else
    logE "Test file '${testfile}' does not define function 'test_functionality()'";
    test_run_status=3;
  fi
  unset -f test_functionality;
  unset -f test_functionality_result;
  if [[ $is_base_addon_test_run == true ]]; then
    export -n PROJECT_INIT_ADDONS_RES;
  fi
  return $test_run_status;
}

function _test_functionality_driver() {
  local title="$1";
  local config_file="$2";
  shift 2;
  local test_driver_args=("$@");

  if [ -n "$config_file" ]; then
    config_file="${TESTPATH}/resources/${config_file}";
    if [ -r "$config_file" ]; then
      export PROJECT_INIT_TESTS_RUN_CONFIG="$config_file";
    else
      logE "Test run configuration file is not readable:";
      logE "at: '${config_file}'";
      return 91;
    fi
  fi

  printt "echo" "       Testing $title " "$LABEL_RUN";
  local output_stdout="";
  local output_stderr="";
  local test_status=0;
  local exit_status=0;
  local f_out_stderr="${TESTS_OUTPUT_DIR}/run_stderr";
  output_stdout=$(bash "${BASETESTPATH}/functionality_test_driver.sh" \
                        "${test_driver_args[@]}" 2>"$f_out_stderr");

  exit_status=$?;

  if [ -r "$f_out_stderr" ]; then
    output_stderr=$(cat "$f_out_stderr");
  fi

  if (( exit_status != 0 )); then
    test_status=1;
  fi

  if [[ "$output_stderr" != "" ]]; then
    test_status=2;
  fi

  if [ -z "$TERMINAL_NO_USE_CNTRL_CHARS" ]; then
    _erasechars "$LABEL_RUN";
  fi

  if (( test_status == 0 )); then
    if [[ $(type -t "test_functionality_result") == function ]]; then
      # Ensure CWD is in concrete test output directory while
      # the test result is evaluated. Change back to test path afterwards.
      _cd_or_die "${TESTS_OUTPUT_DIR}/${ASSERT_FILE_PATH_PREFIX}";
      test_functionality_result;
      if (( $? != 0 )); then
        test_status=3;
      fi
    fi
  fi
  _cd_or_die "$TESTPATH";

  if (( test_status != 0 )); then
    echo -e "${LABEL_FAILED}\n";
    logE "Functionality test run finished with exit status $exit_status";
    if [[ "$output_stderr" != "" ]]; then
      logE "There was output captured from stderr (see below)";
    fi
    if (( test_status == 3 )); then
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
    if [[  $PRINT_CAPTURED_STDOUT == true ]]; then
      logI "Captured output (stdout):";
      logI "";
      echo "$output_stdout";
      logI "";
    fi
  fi
  return $test_status;
}

# [API function]
# Executes a functionality test run with the specified test parameters.
#
# This function is supposed to be used in test suites. It is only defined while
# in test mode. The specified file must contain the test run parameters.
# The file must be properties-formatted and each test parameter corresponds to
# one property line.
#
# Since:
# 1.2.0
#
# Args:
# $1 - A file containing the test run parameters. It is presumed that the
#      file is located relative to the 'tests/resources' directory.
#      This is a mandatory argument.
#
# Returns:
# 0  - If the test run has finished successfully, without any errors or warnings.
# nz - In the case of a test failure due to any reason.
#
# Examples:
# # Inside the test case file 'tests/test_func_example.sh'
# function test_functionality() {
#   # Execute a test run with the parameters specified
#   # in the 'tests/resources/test_example.properties' file
#   test_functionality_with "test_example.properties";
#   return $?;
# }
#
function test_functionality_with() {
  local config_file="$1";
  local title="";
  if [ -z "$config_file" ]; then
    logE "No configuration file specified in call to test_functionality_with() function";
    return 20;
  fi
  if [ -r "resources/${config_file}" ]; then
    title=$(head -n 1 "resources/${config_file}");
    if [[ "$title" == "# @NAME: "* ]]; then
      title="${title:9:60}";
    else
      title="with $config_file";
    fi
  fi
  if ! _read_properties "resources/${config_file}" _FORM_ANSWERS; then
    logE "Test run configuration file is invalid";
    return 90;
  fi

  ASSERT_FILE_PATH_PREFIX="";
  if [[ "${_FORM_ANSWERS[project.dir]+1}" == "1" ]]; then
    ASSERT_FILE_PATH_PREFIX="${_FORM_ANSWERS[project.dir]}";
  fi

  _cd_or_die "${TESTS_OUTPUT_DIR}";
  _test_functionality_driver "$title" "$config_file";
  return $?;
}

# [API function]
# Executes a functionality test run for the specified Quickstart function.
#
# The first mandatory argument to this function is the argument which would be
# passed to the main program if the specified Quickstart function should be used.
# This also includes the Quickstart-specific '@'-prefix.
# The second argument is optional and denotes the file for the test parameters
# to use during the test run. Since Quickstart functions do not necessarily prompt
# for user input, this is optional. However, if the underlying Quickstart function
# makes use of any of the read_user_input_*() API functions, then test parameters
# must be specified to provide the corresponding inputs during the test run.
# If the test parameter file is specified, it must contain valid test run parameters.
# The file must be properties-formatted and each test parameter corresponds to
# one property line.
#
# This function is supposed to be used in test suites. It is only defined while
# in test mode.
#
# Since:
# 1.4.0
#
# Args:
# $1 - The Quickstart name to test. This has to be specified like the argument
#      given to the main program when using the Quickstart function.
#      This is a mandatory argument.
# $2 - A file containing the test run parameters. It is presumed that the
#      file is located relative to the 'tests/resources' directory.
#      This is an optional argument.
#
# Returns:
# 0  - If the test run has finished successfully, without any errors or warnings.
# nz - In the case of a test failure due to any reason.
#
# Examples:
# # Inside the test case file 'tests/test_func_quickstart_example.sh'
# function test_functionality() {
#   # Run and test the Quickstart function 'quickstart_example_fn()'
#   test_functionality_quickstart @example_fn;
#   return $?;
# 
#   # Or:
#   # Run and test the Quickstart function with the given parameters
#   # in the 'tests/resources/test_quickstart.properties' file
#   test_functionality_quickstart @example_fn "test_quickstart.properties";
#   return $?;
# }
#
function test_functionality_quickstart() {
  local quickstart_arg="$1";
  local quickstart_properties="$2";

  if [[ "$quickstart_arg" != "@"* ]]; then
    logE "Test run configuration invalid.";
    logE "Must specify quickstart name in call to test_functionality_quickstart() function";
    return 5;
  fi

  local quickstart_name="${quickstart_arg:1}";
  if [ -z "$quickstart_name" ]; then
    logE "Test run configuration invalid.";
    logE "Invalid quickstart name in call to test_functionality_quickstart() function";
    return 6;
  fi

  local quickstart_name_norm="";
  quickstart_name_norm=$(_normalise_quickstart_name "$quickstart_name");

  ASSERT_FILE_PATH_PREFIX="quickstart/${quickstart_name_norm}";

  local quickstart_output_dir="${TESTS_OUTPUT_DIR_QUICKSTART}/${quickstart_name_norm}";

  # Ensure output directory exists
  if ! mkdir -p "$quickstart_output_dir"; then
    logE "Failed to create Quickstart test output directory:";
    logE "at: '${quickstart_output_dir}'";
    return 7;
  fi
  _cd_or_die "$quickstart_output_dir";

  # Test run title
  quickstart_name="Quickstart function for $quickstart_name";

  _test_functionality_driver "$quickstart_name" "$quickstart_properties" "$quickstart_arg";
  return $?;
}

function main() {
  local arg_keep_output=false;
  local arg_show_stdout=false;
  local arg_filter_runs="";
  local filter_runs=();
  local arg_test_path="";
  for arg in "$@"; do
    case $arg in
      --keep-output)
      arg_keep_output=true;
      shift
      ;;
      --show-stdout)
      arg_show_stdout=true;
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
      for (( i=1; i<=ncommas; ++i )); do
        test_run_name="$(echo "$arg_filter_runs" |cut -d, -f${i})";
        filter_runs+=( "$test_run_name" );
      done
      shift
      ;;
      --test-path=*)
      arg_test_path="${arg:12}";
      shift
      ;;
      *)
      # Unknown arg
      echo "Internal error";
      echo "Unknown argument for functionality_tests.sh script: '${arg}'";
      exit 1;
      ;;
    esac
  done
  BASETESTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)";
  export BASETESTPATH;
  TESTPATH="$BASETESTPATH";
  BASEPATH="$(dirname "$BASETESTPATH")";

  if ! source "${BASEPATH}/libinit.sh"; then
    echo "ERROR: Could not source libinit.sh library"
    return 1;
  fi

  if [ -n "$arg_test_path" ]; then
    IS_ADDON_TESTS=true;
    TESTPATH="$arg_test_path";
    export PROJECT_INIT_ADDONS_RES="$TESTPATH";
    if ! [ -f "${TESTPATH}/INIT_ADDONS" ]; then
      logE "Cannot run Project Init tests for addon. Directory is not an addons resource:";
      logE "at: '${TESTPATH}'";
      logE "Missing file 'INIT_ADDONS' in source root";
      _show_helptext "E" "Addons#setup";
      return 1;
    fi
    if ! [ -d "${TESTPATH}/tests" ]; then
      logE "Cannot run Project Init tests for addon. Addons resource has no 'tests' directory:";
      logE "at: '${TESTPATH}'";
      logE "Place all your tests inside the '${TESTPATH}/tests' directory and try again";
      _show_helptext "E" "Addons#tests-setup";
      return 1;
    fi
    TESTPATH="${TESTPATH}/tests";
  fi

  _cd_or_die "$TESTPATH";

  if ! [ -d "${TESTPATH}/resources" ]; then
    logE "Test resource directory not found.";
    logE "Place test resources inside the '${TESTPATH}/resources' directory and try again";
    return 1;
  fi
  if ! [ -r "${BASETESTPATH}/functionality_test_driver.sh" ]; then
    logE "Functionality test driver script not found";
    return 1;
  fi
  if ! source "${BASETESTPATH}/utils.sh"; then
    logE "Test utilities could not be loaded";
    return 1;
  fi

  export TESTPATH;
  export TESTS_OUTPUT_DIR="${RES_CACHE_LOCATION}/pi_tests_generated";
  export TESTS_OUTPUT_DIR_QUICKSTART="${TESTS_OUTPUT_DIR}/quickstart";
  export IS_ADDON_TESTS;

  if [ -d "${TESTS_OUTPUT_DIR}" ]; then
    logI "Clearing previously created test output directory";
    if ! rm -rf "${TESTS_OUTPUT_DIR}"; then
      logW "Failed to clear test output directory: '${TESTS_OUTPUT_DIR}'";
      return 1;
    fi
  fi

  if ! [ -d "${TESTS_OUTPUT_DIR}" ]; then
    mkdir -p "${TESTS_OUTPUT_DIR}" && mkdir -p "${TESTS_OUTPUT_DIR_QUICKSTART}";
    if (( $? != 0 )); then
      logE "Failed to create test output directory '${TESTS_OUTPUT_DIR}'";
      return 1;
    fi
  fi

  addon_mention="";
  if [[ $IS_ADDON_TESTS == true ]]; then
    addon_mention="addon ";
  fi
  local shell_version="${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}";

  export PROJECT_INIT_TESTS_ACTIVE="1";

  local exit_status=0;
  local n_filter_runs=${#filter_runs[@]};
  if [[ $arg_show_stdout == true ]]; then
    if (( n_filter_runs == 1 )); then
      PRINT_CAPTURED_STDOUT=true;
    else
      logW "Ignoring option '--show-stdout'";
      logW "It can only be used with a single functionality test case";
      arg_show_stdout=false;
    fi
  fi

  logI "Testing functionality of Project Init ${addon_mention}with Bash ${shell_version}";
  echo "";
  if (( n_filter_runs > 0 )); then
    # Only run specified test runs
    local testname="";
    for testname in "${filter_runs[@]}"; do
      if [ -r "test_func_${testname}.sh" ]; then
        execute_test_run "test_func_${testname}.sh";
        exit_status=$?;
      else
        logE "Invalid name for functionality test run: '${testname}'";
        logE "No such file: '${PWD}/test_func_${testname}.sh'";
        exit_status=1;
      fi
      if (( exit_status != 0 )); then
        break;
      fi
    done
  else
    local testcmd;
    local path_base_len;
    # Find all applicable test run script files
    for testfile in "$TESTPATH"/*; do
      path_base_len=$(( ${#TESTPATH}+1 ));
      testcmd="${testfile:path_base_len}";
      if [[ "$testcmd" == test_func_*.sh && "$testcmd" != test_func_addon_*.sh ]]; then
        execute_test_run "$testcmd";
        exit_status=$?;
        if (( exit_status != 0 )); then
          break;
        fi
      fi
    done
    if (( exit_status == 0 )); then
      # Find all applicable test run script files for addon tests
      for testfile in "$TESTPATH"/*; do
        path_base_len=$(( ${#TESTPATH}+1 ));
        testcmd="${testfile:path_base_len}";
        if [[ "$testcmd" == test_func_addon_*.sh ]]; then
          execute_test_run "$testcmd";
          exit_status=$?;
          if (( exit_status != 0 )); then
            break;
          fi
        fi
      done
    fi
  fi

  if (( exit_status != 0 )); then
    logE "Testing of ${addon_mention}functionality has not completed";
    logE "An error has occurred during a functionality test";
  else
    logI "Testing of ${addon_mention}functionality has completed";
    printt_ok "All functionality tests have passed:";
  fi

  if [[ $arg_keep_output == false ]]; then
    if [ -d "${TESTS_OUTPUT_DIR}" ]; then
      if ! rm -rf "${TESTS_OUTPUT_DIR}"; then
        logW "Failed to clear test output directory: '${TESTS_OUTPUT_DIR}'";
      fi
    fi
  else
    logI "Generated output can be found at: '${TESTS_OUTPUT_DIR}'";
  fi

  return $exit_status;
}

main "$@";
