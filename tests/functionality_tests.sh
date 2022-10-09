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
  local config_file="$1";
  export PROJECT_INIT_TESTS_RUN_CONFIG="$TESTPATH/resources/$config_file";

  local test_run_time=$(date --utc +%FT%TZ);
  logI "";
  logI "Testing with $config_file";
  logI "";
  logI "***************************************************************";
  logI "*                                                             *";
  logI "*          Test run started at ${test_run_time}           *";
  logI "*                                                             *";
  logI "***************************************************************";
  logI "";

  bash ../initmain.sh
  return $?;
}

function main() {
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
  if ! [ -r "../initmain.sh" ]; then
    logE "Init main not found";
    return 1;
  fi
  export PROJECT_INIT_TESTS_ACTIVE="1";
  # Find all applicable test run configuration files
  for testfile in $(ls "$TESTPATH/resources"); do
    if [[ "$testfile" == test_run_*.properties ]]; then
      execute_test_run "$testfile";
      if (( $? != 0 )); then
        return 1;
      fi
    fi
  done

  return 0;
}

main "$@";
