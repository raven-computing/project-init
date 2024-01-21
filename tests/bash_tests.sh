#!/bin/bash
# Copyright (C) 2024 Raven Computing
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
# *                    ***   Bash Compatibility Tests  ***                    *
# *                                                                           *
# #***************************************************************************#


COMPUTED_BASH_VERSION="";


function is_bash_version_compatible() {
  local bash_version_major="${BASH_VERSINFO:-0}";
  local bash_version_full="${BASH_VERSION}";
  if (( bash_version_major == 0 )); then
    COMPUTED_BASH_VERSION="Unsupported Bash version";
  else
    local _bash_version_msg="$bash_version_major";
    if [ -n "$bash_version_full" ]; then
      _bash_version_msg="$bash_version_full";
    fi
    COMPUTED_BASH_VERSION="${_bash_version_msg}";
  fi
  if (( bash_version_major < REQUIREMENT_BASH_VERSION )); then
    return 1;
  fi
  return 0;
}

function main() {
  TESTPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)";
  cd "$TESTPATH" || return 1;
  if ! source "../libinit.sh"; then
    echo "ERROR: Could not source libinit.sh library"
    return 1;
  fi
  if ! source "utils.sh"; then
    logE "Test utilities could not be loaded";
    return 1;
  fi
  local name_os="Unknown operating system";
  local name_hw="Unknown hardware";
  if _command_dependency "uname"; then
    name_os=$(uname -o);
    name_hw=$(uname -m);
  fi
  if _command_dependency "lsb_release"; then
    local name_os2="";
    name_os2=$(lsb_release -d -s);
    name_os="${name_os} ${name_os2}";
  fi
  logI "Running tests on ${name_os} (${name_hw})";
  logI "Testing compatibility of Bash interpreter";
  if ! is_bash_version_compatible; then
    logE "Unsatisfied compatibility requirement.";
    logE "Unsupported Bash version detected.";
    logE "Required Bash version:  $REQUIREMENT_BASH_VERSION";
    logE "Detected Bash version:  $COMPUTED_BASH_VERSION";
    return 1;
  else
    logI "Found Bash version $COMPUTED_BASH_VERSION";
    printt_ok "Bash interpreter is compatible:";
    return 0;
  fi
}

main "$@";
