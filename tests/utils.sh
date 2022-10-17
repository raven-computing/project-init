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
# *                        ***   Test Utilities   ***                         *
# *                                                                           *
# #***************************************************************************#


# Used term width
readonly TWIDTH=90;
label_passed="[${COLOR_GREEN}PASSED${COLOR_NC}]";
label_failed="[${COLOR_RED}FAILED${COLOR_NC}]";
label_run="";
if [ -z "$TERMINAL_NO_USE_CNTRL_CHARS" ]; then
  label_run="[RUNNING]";
fi


function printt() {
  local i;
  if [[ "$1" == "fail" ]]; then
    local padd=$(( ${TWIDTH}-15 ));
    local s="";
    for (( i=0; i<${padd}; ++i )); do
        s="${s}-";
    done
    logE "$s [${COLOR_RED}TEST FAILURE${COLOR_NC}]";
  elif [[ "$1" == "sep" ]]; then
    local padd=${TWIDTH};
    local s="";
    for (( i=0; i<${padd}; ++i )); do
        s="${s}-";
    done
    logE "$s";
  elif [[ "$1" == "ok_compat" ]]; then
    local padd=$(( ${TWIDTH}-42 ));
    local s="All compatibility tests have passed:";
    for (( i=0; i<${padd}; ++i )); do
        s="${s} ";
    done
    logI "$s [${COLOR_GREEN}OK${COLOR_NC}]";
  elif [[ "$1" == "ok_funct" ]]; then
    local padd=$(( ${TWIDTH}-42 ));
    local s="All functionality tests have passed:";
    for (( i=0; i<${padd}; ++i )); do
        s="${s} ";
    done
    logI "$s [${COLOR_GREEN}OK${COLOR_NC}]";
  else
    local out=$($1 "$2");
    local padd=$(( ${TWIDTH}-${#out} ));
    echo -ne "$out";
    if (( $padd > 0 )); then
      for (( i=0; i<${padd}; ++i )); do
        echo -n " ";
      done
    else
      echo -n " ";
    fi
    echo -ne "$3";
  fi
}

function _erasechars() {
  local chars="$1";
  local len=${#chars};
  local i;
  for (( i=0; i<${len}; ++i )); do
    echo -ne "\b";
  done
  for (( i=0; i<${len}; ++i )); do
    echo -ne " ";
  done
  for (( i=0; i<${len}; ++i )); do
    echo -ne "\b";
  done
}

function assert_equal() {
  local expected="$1";
  local actual="$2";
  local cmd_exit_status="$3";  # Optional arg
  if [[ "$expected" == "$actual" ]]; then
    return 0;
  else
    echo "";
    echo "----- Expected: -----";
    echo "$expected";
    echo "-----  Actual:  -----";
    echo "$actual";
    if [ -n "$cmd_exit_status" ] && (( $cmd_exit_status != 0 )); then
      return $cmd_exit_status;
    else
      return 1;
    fi
  fi
}
