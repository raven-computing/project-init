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
# Printed labels
readonly LABEL_PASSED="[${COLOR_GREEN}PASSED${COLOR_NC}]";
readonly LABEL_FAILED="[${COLOR_RED}FAILED${COLOR_NC}]";
if [ -z "$TERMINAL_NO_USE_CNTRL_CHARS" ]; then
  readonly LABEL_RUN="[RUNNING]";
else
  readonly LABEL_RUN="";
fi

ASSERT_FAIL_MISSING_FILES=();
ASSERT_FAIL_ADVERSE_FILES=();

ASSERT_FAIL_MISSING_DIRS=();
ASSERT_FAIL_ADVERSE_DIRS=();


function printt() {
  local i;
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
}

function printt_sep() {
  local padd=${TWIDTH};
  local s="";
  for (( i=0; i<${padd}; ++i )); do
      s="${s}-";
  done
  logE "$s";
}

function printt_fail() {
  local padd=$(( ${TWIDTH}-15 ));
  local s="";
  for (( i=0; i<${padd}; ++i )); do
      s="${s}-";
  done
  logE "$s [${COLOR_RED}TEST FAILURE${COLOR_NC}]";
}

function printt_ok() {
  local s="$1";
  local padd=$(( ${TWIDTH}-6-${#s} ));
  local i;
  for (( i=0; i<${padd}; ++i )); do
      s="${s} ";
  done
  logI "$s [${COLOR_GREEN}OK${COLOR_NC}]";
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

function assert_files_exist() {
  local check_files=("$@");
  local assertion_status=0;
  local f_path_prefix="";
  if [ -n "$ASSERT_FILE_PATH_PREFIX" ]; then
    f_path_prefix="/$ASSERT_FILE_PATH_PREFIX";
  fi
  local file="";
  for file in "${check_files[@]}"; do
    if ! [ -f "${_TESTS_OUTPUT_DIR}${f_path_prefix}/$file" ]; then
      ASSERT_FAIL_MISSING_FILES+=("$file");
      assertion_status=1;
    fi
  done
  return $assertion_status;
}

function assert_files_not_exist() {
  local check_files=("$@");
  local assertion_status=0;
  local f_path_prefix="";
  if [ -n "$ASSERT_FILE_PATH_PREFIX" ]; then
    f_path_prefix="/$ASSERT_FILE_PATH_PREFIX";
  fi
  local file="";
  for file in "${check_files[@]}"; do
    if [ -f "${_TESTS_OUTPUT_DIR}${f_path_prefix}/$file" ]; then
      ASSERT_FAIL_ADVERSE_FILES+=("$file");
      assertion_status=1;
    fi
  done
  return $assertion_status;
}

function assert_dirs_exist() {
  local check_dirs=("$@");
  local assertion_status=0;
  local f_path_prefix="";
  if [ -n "$ASSERT_FILE_PATH_PREFIX" ]; then
    f_path_prefix="/$ASSERT_FILE_PATH_PREFIX";
  fi
  local dir="";
  for dir in "${check_dirs[@]}"; do
    if ! [ -d "${_TESTS_OUTPUT_DIR}${f_path_prefix}/$dir" ]; then
      ASSERT_FAIL_MISSING_DIRS+=("$dir");
      assertion_status=1;
    fi
  done
  return $assertion_status;
}

function assert_dirs_not_exist() {
  local check_dirs=("$@");
  local assertion_status=0;
  local f_path_prefix="";
  if [ -n "$ASSERT_FILE_PATH_PREFIX" ]; then
    f_path_prefix="/$ASSERT_FILE_PATH_PREFIX";
  fi
  local dir="";
  for dir in "${check_dirs[@]}"; do
    if [ -d "${_TESTS_OUTPUT_DIR}${f_path_prefix}/$dir" ]; then
      ASSERT_FAIL_ADVERSE_DIRS+=("$dir");
      assertion_status=1;
    fi
  done
  return $assertion_status;
}

