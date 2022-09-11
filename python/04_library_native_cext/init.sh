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
# *            ***   Init Script for Python Library Projects   ***            *
# *                    Using Native Code with C Extensions                    *
# *                               INIT LEVEL 2                                *
# *                                                                           *
# #***************************************************************************#


function process_files_lvl_2() {
  # Move C source files to "c" directory within the Python package
  local path_source="$var_project_dir/$var_namespace_path/";
  local path_source_c="$path_source/c/";
  # Ensure that C source dir exists
  if ! [ -d "$path_source_c" ]; then
    mkdir -p "$path_source_c";
    if (( $? != 0 )); then
      failure "Failed to create directory for C source files";
    fi
  fi
  # Move C source files
  for f in $(find "$path_source" -type f -name '*.c'); do
    mv "$f" "$path_source_c";
    if (( $? != 0 )); then
      failure "Failed to move C source file into corresponding directory";
    fi
  done
  # Update file cache
  find_all_files;
}


# Form questions

form_python_version;

form_python_virtenv_name;

form_python_package_name;

form_python_use_linter;

form_python_pypi_deployment;

# Project setup

project_init_copy;

project_init_license "py" "c";

project_init_process;
