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
# *              ***   Init Script for Python Library Projects   ***          *
# *                         Using Native Code with ctypes                     *
# *                                 INIT LEVEL 2                              *
# *                                                                           *
# #***************************************************************************#


function process_files_lvl_2() {
  replace_var "DOCUMENTED_MODULE" "comparator";
}

# Form questions

form_python_version;

form_python_virtenv_name;

form_python_package_name;

form_python_use_linter;

form_python_use_type_checker;

form_python_pypi_deployment;

form_docs_integration;

form_docker_integration;

# Project setup

project_init_copy;

project_init_license "py";

project_init_process;
