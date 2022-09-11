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


function process_files_lvl_2() {
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
    local path_ns_cpp="$var_project_dir/src/main/cpp/$dir_layout/";
    local path_ns_test="$var_project_dir/src/test/cpp/$dir_layout/";
    mkdir -p "$path_ns_include";
    mkdir -p "$path_ns_cpp";
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
    if [ -d "$var_project_dir/src/main/cpp/namespace" ]; then
      for f in $(find "$var_project_dir/src/main/cpp/namespace" -type f); do
        local f_name="$(basename "$f")";
        mv "$f" "$path_ns_cpp";
        if (( $? != 0 )); then
          failure "Failed to move source file into namespace layout directory";
        fi
      done
      # Remove the original now empty placeholder namespace dir
      rm -r "$var_project_dir/src/main/cpp/namespace/";
      if (( $? != 0 )); then
          failure "Failed to remove template source namespace directory";
      fi
    fi
    # Create directory layout for test cpp files
    if [ -d "$var_project_dir/src/test/cpp/namespace" ]; then
      for f in $(find "$var_project_dir/src/test/cpp/namespace" -type f); do
        local f_name="$(basename "$f")";
        mv "$f" "$path_ns_test";
        if (( $? != 0 )); then
          failure "Failed to move source file into namespace layout directory";
        fi
      done
      # Remove the original now empty placeholder namespace dir
      rm -r "$var_project_dir/src/test/cpp/namespace/";
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
    if [ -d "$var_project_dir/src/main/cpp/jni" ]; then
      for f in $(find "$var_project_dir/src/main/cpp/jni" -type f); do
        local f_name="$(basename "$f")";
        if [[ "$f_name" == namespace_* ]]; then
          mv "$f" "$var_project_dir/src/main/cpp/jni/${var_namespace_underscore}${f_name:9}";
          if (( $? != 0 )); then
            failure "Failed to rename cpp source file in jni directory";
          fi
        fi
      done
    fi

    # Update file cache
    find_all_files;
  fi
}

# Form questions

form_java_version;

form_java_namespace;

# Project setup

project_init_copy;

project_init_license "java" "h" "cpp";

project_init_process;
