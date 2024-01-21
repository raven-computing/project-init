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
# *                   ***   Project Init Main Script   ***                    *
# *                                                                           *
# #***************************************************************************#
#
# This is the entry point for the Project Init system. It implements the
# main function, which will be called when executing this script.
# This script file depends on the global functions and variables defined
# in the 'libinit.sh' and 'libform.sh' files.
#
# The developer documentation is available on GitHub:
# https://github.com/raven-computing/project-init/wiki
#
# Please consult the docs for further information on the Init System and
# the provided APIs. The system and its behaviour is customizable by
# an add-on mechanism without having to change the core code of the system.


function main() {
  # Get the path to the directory of this script to make it call site independent
  local libpath="";
  libpath="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)";
  # Load core libraries
  source "${libpath}/libinit.sh";
  source "${libpath}/libform.sh";

  # Make sure this script is not executed by the root user
  if (( $(id -u) == 0 )); then
    logW "There is no need for this program to be executed by the root user.";
    logW "Please use a regular user instead";
    return $EXIT_FAILURE;
  fi

  start_project_init "$@";

  if [[ $PROJECT_INIT_QUICKSTART_REQUESTED == true ]]; then
    process_project_init_quickstart;
  else
    show_project_init_main_form;
    proceed_next_level "$FORM_MAIN_NEXT_DIR";
  fi

  finish_project_init;

  return $?;
}

main "$@";
