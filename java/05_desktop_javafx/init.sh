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
# *          ***   Init Script for Desktop GUI JavaFX Projects   ***          *
# *                               INIT LEVEL 2                                *
# *                                                                           *
# #***************************************************************************#


# Form questions

# We don't support Java 8 for JavaFX projects anymore
remove_lang_version "1.8";

form_java_version;

form_java_namespace;

if [ -z "$var_namespace" ]; then
  logW "No namespace has been specified.";
  logW "JavaFX applications should use modules which" \
       "require the use of namespaces.";
  logW "Your project might not compile.";
  logW "You will have to adjust the 'module-info.java' file for your project.";
  warning "The initialized JavaFX application does not use a namespace";
fi

form_docs_integration;

# Project setup

project_init_copy;

project_init_license "java" "fxml" "css";

project_init_process;
