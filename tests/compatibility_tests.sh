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
# *                      ***   Compatibility Tests   ***                      *
# *                                                                           *
# #***************************************************************************#


# The path to the tests directory
TESTPATH="";

# The name of commands for which at least one test has failed
failed_cmds=();
# The total number of commands which have failed tests
n_failed_cmds=0;
# The total number of commands tested
n_cmds=0;


function run_failed_test_file() {
  local testfile="$1";
  local testfile_funcs=();
  local testfile_funcs_cmddecl=();
  local testfile_funcs_linenums=();
  local prev_line="";
  local line_len=0;
  # Read and parse the test file source code
  local line_num=0;
  while read -r line; do
    (( line_num+=1 ));
    # Find test functions.
    # Ignore the main test_command() function
    if [[ "$line" == "function test_"* && "$line" != "function test_command()"* ]]; then
      line_len=$(( ${#line}-13 ));
      testfile_funcs+=("${line:9:line_len}");
      testfile_funcs_linenums+=("$line_num");
      # Check for command declaration.
      # It must be a comment located right above the function declaration
      if [[ "$prev_line" == "# @CMD: "* ]]; then
        testfile_funcs_cmddecl+=("${prev_line:8}");
      else
        testfile_funcs_cmddecl+=("-");
      fi
    fi
    prev_line="$line";
  done < "$TESTPATH/$testfile";

  local tested_func_name="";
  local tested_func_cmd="";
  local tested_func_exitstatus="";
  local tested_func_output="";
  local nfuncs=${#testfile_funcs[@]};
  local i;
  # Test all found test_*() functions individually
  for (( i=0; i<${nfuncs}; ++i )); do
    tested_func_name="${testfile_funcs[i]}";
    tested_func_line="${testfile_funcs_linenums[i]}";
    tested_func_cmd="${testfile_funcs_cmddecl[i]}";
    # Source and call test function in subshell to keep the environment of
    # our own process clean. Capture both stdout and stderr
    tested_func_output="$(cd "$TESTPATH"               && \
                          source "$TESTPATH/$testfile" && \
                          $tested_func_name 2>&1)";

    tested_func_exitstatus=$?;
    # Only show details for test functions that have failed
    if (( $tested_func_exitstatus != 0 )); then
      printt_fail;
      logE "in file:      $testfile";
      logE "in function:  $tested_func_name()  (line $tested_func_line)";
      logE "";
      if [[ "$tested_func_cmd" == "-" ]]; then
        logE "Function has failed with exit status $tested_func_exitstatus";
      else
        logE "The following command failed with exit status $tested_func_exitstatus";
        logE "    $tested_func_cmd";
      fi
      if [ -n "$tested_func_output" ]; then
        logE "";
        logE "The captured output is:";
        while read -r line; do
          echo "        $line";
        done <<< "$tested_func_output";
      fi
      echo "";
    fi
  done
  printt_sep;
  echo "";
}

function run_test_file() {
  local testfile="$1";
  local cmd_len=$(( ${#testfile}-15 ));
  local tested_cmd="${testfile:12:cmd_len}";
  local cmd_is_available=false;
  local test_status=1;
  printt "echo -n" "       Testing compatibility of command:  $tested_cmd" "$LABEL_RUN";
  if _command_dependency "$tested_cmd"; then
    cmd_is_available=true;
    # Run tests
    bash "$TESTPATH/$testfile" &> /dev/null;
    test_status=$?;
  fi

  if [ -z "$TERMINAL_NO_USE_CNTRL_CHARS" ]; then
    _erasechars "$LABEL_RUN";
  fi

  if (( $test_status == 0 )); then
    # Tests passed
    echo -e "${LABEL_PASSED}\n";
  else
    # Tests failed
    failed_cmds+=("$tested_cmd");
    (( n_failed_cmds+=1 ));
    echo -e "${LABEL_FAILED}\n";
    if [[ $cmd_is_available == true ]]; then
      run_failed_test_file "$testfile";
    else
      printt "echo" "       Command not found:  '$tested_cmd'" "${LABEL_FAILED}\n\n";
    fi
  fi
}

function show_test_results() {
  if (( $n_failed_cmds > 0 )); then
    if (( $n_failed_cmds == 1 )); then
      logE "One command has failed compatibility tests:";
      logE "Command '${failed_cmds[0]}' has failed";
    else
      logE "Some commands have failed compatibility tests:";
      logE "All failed commands:";
      for failed_cmd in ${failed_cmds[@]}; do
        logE "                      $failed_cmd";
      done
    fi
    local n_passed=$(( ${n_cmds}-${n_failed_cmds} ));
    logE "";
    logE "Total failed compatibility tests: $n_failed_cmds   ($n_passed/$n_cmds passed)";
    logE "";
  else
    # No errors. Everything has passed
    printt_ok "All compatibility tests have passed:";
  fi
}

function main() {
  TESTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)";
  cd "$TESTPATH";
  if ! source "../libinit.sh"; then
    echo "ERROR: Could not source libinit.sh library"
    return 1;
  fi
  if ! source "utils.sh"; then
    logE "Test utilities could not be loaded";
    return 1;
  fi
  # Make assert function available to test code
  export -f assert_equal;
  local testfile;
  logI "Testing compatibility of system commands\n";
  # Find and run all applicable test files
  for testfile in $(ls "$TESTPATH"); do
    if [[ "$testfile" == test_compat_*.sh ]]; then
      (( n_cmds+=1 ));
      run_test_file "$testfile";
    fi
  done
  logI "Testing of command compatibility has completed";
  show_test_results;
  if (( $n_failed_cmds > 0 )); then
    return 1;
  else
    return 0;
  fi
}

main "$@";

