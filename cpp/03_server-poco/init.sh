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
# *         ***   Init Script for C++ Server Projects Using Poco   ***        *
# *                               INIT LEVEL 2                                *
# *                                                                           *
# #***************************************************************************#


# Form questions

# Currently we do not support C++14
# anymore for this project type.
remove_lang_version "14";

form_cpp_version;

form_cpp_binary_name;

form_cpp_namespace;

form_docs_integration;

form_docker_integration;

# Project setup

project_init_copy;

project_init_license "h" "cpp";

project_init_process;
