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
# *           ***   Init Script for Java JNI Library Projects   ***           *
# *                               INIT LEVEL 2                                *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_NAMESPACE_PATH: The namespace of the project, in directory path notation,
#                     i.e. with slashes instead of dots
# VAR_NAMESPACE_COLON: The namespace of the project, in colon notation,
#                     i.e. with colons instead of dots
# VAR_NAMESPACE_UNDERSCORE: The namespace of the project, in underscore
#                           notation, i.e. with underscores instead of dots
# VAR_NAMESPACE_INCLUDE_GUARD: The namespace as used in C++ include guards
# VAR_NAMESPACE_DECL_BEGIN: The C++ namespace declaration start part
# VAR_NAMESPACE_DECL_END: The C++ namespace declaration end part
# VAR_CMAKE_LANG_SPEC: The language standard version specifications used
#                      in CMakeLists.txt file.
# VAR_NATIVE_LANG_VERSION: The language standard version identifier number.
# VAR_NATIVE_LANG_VERSION_LABEL: The language standard version label.
# VAR_CMAKE_PROJECT_LANG_SPEC: The additional specification for C-based
#                              projects used in CMake project declarations.
#                              Is empty for C++-based projects.
# VAR_CMAKE_DEPENDENCIES: The project dependencies as used in
#                         the Dependencies.cmake file.
# VAR_CMAKE_LANG_IDENTIFIER: The identifier for the language used for the
#                            native library, also used as the file extension.
#                            Is either "c" or "cpp".
# VAR_CMAKE_ADD_LIBRARY_FILE: The source file to use for the native
#                             library compilation unit.
# VAR_CMAKE_TEST_SOURCE_FILE: The source file to use for the native
#                             library test compilation unit.


function process_files_lvl_2() {
  # Remove unused files based on whether C or C++ was chosen
  local c_or_cpp="";  # Source file extension
  if [[ "$var_java_lib_jni_native_lang" == "C" ]]; then
    c_or_cpp="c";
    rm "$var_project_dir/cmake/ConfigGtest.cmake"        &&
    rm "$var_project_dir/cmake/cpp_DependencyUtil.cmake" &&
    rm "$var_project_dir/cmake/cpp_TestUtil.cmake";
    if (( $? != 0 )); then
      failure "Failed to remove unselected template sources in $var_project_dir/cmake";
    fi
    mv "$var_project_dir/cmake/c_DependencyUtil.cmake" \
       "$var_project_dir/cmake/DependencyUtil.cmake"  &&
    mv "$var_project_dir/cmake/c_TestUtil.cmake" \
       "$var_project_dir/cmake/TestUtil.cmake";
    if (( $? != 0 )); then
      failure "Failed to rename selected template sources in $var_project_dir/cmake";
    fi
    rm -r "$var_project_dir/src/main/cpp" &&
    rm -r "$var_project_dir/src/test/cpp" &&
    rm "$var_project_dir/src/main/include/namespace/StringComparator.h";
    if (( $? != 0 )); then
      failure "Failed to remove unselected template sources in $var_project_dir/src";
    fi
    find_all_files;
    replace_var "CMAKE_LANG_SPEC"           "$(load_var CMAKE_LANG_SPEC_C)";
    replace_var "NATIVE_LANG_VERSION"       "$var_native_lang_version";
    replace_var "NATIVE_LANG_VERSION_LABEL" "$var_native_lang_version_label";
    replace_var "CMAKE_PROJECT_LANG_SPEC"   "$(load_var CMAKE_PROJECT_LANG_SPEC_C)";
    replace_var "CMAKE_DEPENDENCIES"        "$(load_var CMAKE_DEPENDENCIES_C)";
    replace_var "CMAKE_LANG_IDENTIFIER"     "c";
    replace_var "CMAKE_ADD_LIBRARY_FILE"    "string_comparator.c";
    replace_var "CMAKE_TEST_SOURCE_FILE"    "test_string_comparator.c";
  else
    c_or_cpp="cpp";
    rm "$var_project_dir/cmake/ConfigUnity.cmake"      &&
    rm "$var_project_dir/cmake/c_DependencyUtil.cmake" &&
    rm "$var_project_dir/cmake/c_TestUtil.cmake";
    if (( $? != 0 )); then
      failure "Failed to remove unselected template sources in $var_project_dir/cmake";
    fi
    mv "$var_project_dir/cmake/cpp_DependencyUtil.cmake" \
       "$var_project_dir/cmake/DependencyUtil.cmake"  &&
    mv "$var_project_dir/cmake/cpp_TestUtil.cmake" \
       "$var_project_dir/cmake/TestUtil.cmake";
    if (( $? != 0 )); then
      failure "Failed to rename selected template sources in $var_project_dir/cmake";
    fi
    rm -r "$var_project_dir/src/main/c" &&
    rm -r "$var_project_dir/src/test/c" &&
    rm "$var_project_dir/src/main/include/namespace/string_comparator.h";
    if (( $? != 0 )); then
      failure "Failed to remove unselected template sources in $var_project_dir/src";
    fi
    find_all_files;
    replace_var "CMAKE_LANG_SPEC"           "$(load_var CMAKE_LANG_SPEC_CPP)";
    replace_var "NATIVE_LANG_VERSION"       "$var_native_lang_version";
    replace_var "NATIVE_LANG_VERSION_LABEL" "$var_native_lang_version_label";
    replace_var "CMAKE_PROJECT_LANG_SPEC"   "";
    replace_var "CMAKE_DEPENDENCIES"        "$(load_var CMAKE_DEPENDENCIES_CPP)";
    replace_var "CMAKE_LANG_IDENTIFIER"     "cpp";
    replace_var "CMAKE_ADD_LIBRARY_FILE"    "StringComparator.cpp";
    replace_var "CMAKE_TEST_SOURCE_FILE"    "StringComparatorTest.cpp";
  fi

  if [ -n "$var_namespace" ]; then
    # Set the namespace variables for the C++ part of the project
    var_namespace_path=$(echo "$var_namespace" |tr "." "/");
    var_namespace_colon="${var_namespace//./::}";
    var_namespace_underscore="${var_namespace//./_}";
    var_namespace_include_guard=$(echo "$var_namespace"         \
                                  |tr "." "_"                   \
                                  |tr '[:lower:]' '[:upper:]');

    var_namespace_decl_begin="";
    var_namespace_decl_end="";
    # Put namespace items in an array
    local _ns_items=($(echo "$var_namespace" |tr '.' ' '));
    # Concatenate namespace items in proper order
    for (( i=0; i<${#_ns_items[@]}; i++ )); do
      var_namespace_decl_begin="${var_namespace_decl_begin}namespace ${_ns_items[$i]} {\n";
    done
    # Concatenate namespace items in reverse order for the closing braces
    for (( i=${#_ns_items[@]}-1; i>=0; i-- )); do
      var_namespace_decl_end="${var_namespace_decl_end}} // END NAMESPACE ${_ns_items[$i]}\n";
    done

    replace_var "NAMESPACE_PATH"          "$var_namespace_path";
    replace_var "NAMESPACE_COLON"         "$var_namespace_colon";
    replace_var "NAMESPACE_UNDERSCORE"    "$var_namespace_underscore";
    replace_var "NAMESPACE_INCLUDE_GUARD" "$var_namespace_include_guard";
    replace_var "NAMESPACE_DECL_BEGIN"    "$var_namespace_decl_begin";
    replace_var "NAMESPACE_DECL_END"      "$var_namespace_decl_end";

    # Create namespace directory layout and move source files
    local dir_layout=$(echo "$var_namespace" |tr "." "/");
    local path_ns_include="$var_project_dir/src/main/include/$dir_layout/";
    local path_ns_native="$var_project_dir/src/main/${c_or_cpp}/${dir_layout}/";
    local path_ns_test="$var_project_dir/src/test/${c_or_cpp}/${dir_layout}/";
    mkdir -p "$path_ns_include";
    mkdir -p "$path_ns_native";
    mkdir -p "$path_ns_test";
    # Create directory layout for include header files
    if [ -d "$var_project_dir/src/main/include/namespace" ]; then
      for f in $(find "$var_project_dir/src/main/include/namespace" -type f); do
        local f_name="$(basename "$f")";
        mv "$f" "$path_ns_include";
        if (( $? != 0 )); then
          failure "Failed to move source file into namespace layout directory";
        fi
      done
      # Remove the original now empty placeholder namespace dir
      rm -r "$var_project_dir/src/main/include/namespace/";
      if (( $? != 0 )); then
          failure "Failed to remove template source namespace directory";
      fi
    fi
    # Create directory layout for cpp files
    if [ -d "$var_project_dir/src/main/${c_or_cpp}/namespace" ]; then
      for f in $(find "$var_project_dir/src/main/${c_or_cpp}/namespace" -type f); do
        local f_name="$(basename "$f")";
        mv "$f" "$path_ns_native";
        if (( $? != 0 )); then
          failure "Failed to move source file into namespace layout directory";
        fi
      done
      # Remove the original now empty placeholder namespace dir
      rm -r "$var_project_dir/src/main/${c_or_cpp}/namespace/";
      if (( $? != 0 )); then
          failure "Failed to remove template source namespace directory";
      fi
    fi
    # Create directory layout for test cpp files
    if [ -d "$var_project_dir/src/test/${c_or_cpp}/namespace" ]; then
      for f in $(find "$var_project_dir/src/test/${c_or_cpp}/namespace" -type f); do
        local f_name="$(basename "$f")";
        mv "$f" "$path_ns_test";
        if (( $? != 0 )); then
          failure "Failed to move source file into namespace layout directory";
        fi
      done
      # Remove the original now empty placeholder namespace dir
      rm -r "$var_project_dir/src/test/${c_or_cpp}/namespace/";
      if (( $? != 0 )); then
          failure "Failed to remove template source namespace directory";
      fi
    fi

    # Rename JNI-related files
    if [ -d "$var_project_dir/src/main/include/jni" ]; then
      for f in $(find "$var_project_dir/src/main/include/jni" -type f); do
        local f_name="$(basename "$f")";
        if [[ "$f_name" == namespace_* ]]; then
          mv "$f" "$var_project_dir/src/main/include/jni/${var_namespace_underscore}${f_name:9}";
          if (( $? != 0 )); then
            failure "Failed to rename include header source file in jni directory";
          fi
        fi
      done
    fi
    if [ -d "$var_project_dir/src/main/${c_or_cpp}/jni" ]; then
      for f in $(find "$var_project_dir/src/main/${c_or_cpp}/jni" -type f); do
        local f_name="$(basename "$f")";
        if [[ "$f_name" == namespace_* ]]; then
          mv "$f" \
             "$var_project_dir/src/main/${c_or_cpp}/jni/${var_namespace_underscore}${f_name:9}";
          if (( $? != 0 )); then
            failure "Failed to rename ${c_or_cpp} source file in jni directory";
          fi
        fi
      done
    fi

    # Update file cache
    find_all_files;
  fi
}

# Prompts the user to select the language to use for the JNI-based library.
#
# Globals:
# var_java_lib_jni_native_lang  - The selected language, either "C" or "C++".
# var_native_lang_version       - The language standard version.
# var_native_lang_version_label - The language standard version label.
#
function form_java_native_lib_jni_lang() {
  local selection=("C" "C++");
  FORM_QUESTION_ID="java.library.jni.native.lang";
  logI "";
  logI "Select which language to use for the native part of the library:";
  read_user_input_selection "${selection[@]}";
  var_java_lib_jni_native_lang="${selection[USER_INPUT_ENTERED_INDEX]}";
  # Specify supported language standard versions
  if [[ "$var_java_lib_jni_native_lang" == "C" ]]; then
    var_native_lang_version="11";
    var_native_lang_version_label="C11";
  else
    var_native_lang_version="17";
    var_native_lang_version_label="C++17";
  fi
}

# Form questions

form_java_version;

form_java_namespace;

form_java_native_lib_jni_lang;

form_docker_integration;

# Project setup

project_init_copy;

project_init_license "java" "h" "cpp" "c";

project_init_process;
