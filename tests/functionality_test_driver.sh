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

  local n_warnings=${#_WARNING_LOG[@]};
  if (( ${n_warnings} > 0 || ${_N_WARNINGS} > 0 )); then
    logW "Test run exited with warnings";
    exit $EXIT_FAILURE;
  fi
  exit $EXIT_SUCCESS;

}

main "$@";
