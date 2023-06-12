#!/bin/bash
# Copyright (C) 2023 Raven Computing
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
# *          ***   Project Init Quickstart Function Definitions  ***          *
# *                                                                           *
# #***************************************************************************#


function quickstart_c_main() {
  logI "Creating C source file with a main function";
  copy_shared "c/standalone_main.c" "main.c";
  return $?;
}

# Alias for quickstart_c_main()
function quickstart_main_c() {
  quickstart_c_main;
  return $?;
}

function quickstart_cpp_main() {
  logI "Creating C++ source file with a main function";
  copy_shared "cpp/Standalone_main.cpp" "Main.cpp";
  return $?;
}

# Alias for quickstart_cpp_main()
function quickstart_main_cpp() {
  quickstart_cpp_main;
  return $?;
}

function quickstart_java_main() {
  logI "Creating Java source file with a main function";
  copy_shared "java/Standalone_Main.java" "Main.java";
  return $?;
}

# Alias for quickstart_java_main()
function quickstart_main_java() {
  quickstart_java_main;
  return $?;
}

function quickstart_python_main() {
  logI "Creating Python source file with a main function";
  copy_shared "python/standalone_main.py" "main.py";
  return $?;
}

# Alias for quickstart_python_main()
function quickstart_main_py() {
  quickstart_python_main;
  return $?;
}
