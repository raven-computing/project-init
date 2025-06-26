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
# *                  ***   Init Script for C++ Projects   ***                 *
# *                                 INIT LEVEL 1                              *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_CPP_VERSION: The version number of C++ to be used, e.g. '20'
# VAR_CPP_VERSION_LABEL: The version label of C++ to be used, e.g. 'C++20'
# VAR_ARTIFACT_BINARY_NAME: The name of the binary file to
#                           be produced by the project
# VAR_ARTIFACT_BINARY_NAME_UPPER: The name of the binary file to be produced
#                                 by the project, in all upper-case.
# VAR_NAMESPACE: The namespace of the project, in dot notation
# VAR_NAMESPACE_0: The first package name in the namespace hierarchy
# VAR_NAMESPACE_PATH: The namespace of the project, in directory path notation,
#                     i.e. with slashes instead of dots
# VAR_NAMESPACE_COLON: The namespace of the project, in colon notation,
#                     i.e. with colons instead of dots
# VAR_NAMESPACE_INCLUDE_GUARD: The namespace as used in include guards
# VAR_NAMESPACE_DECL_BEGIN: The namespace declaration start part
# VAR_NAMESPACE_DECL_END: The namespace declaration end part
# VAR_CPP_HEADER_BEGIN: The code at the beginning of a C++ header file
# VAR_CPP_HEADER_END: The code at the end of a C++ header file

function process_files_lvl_1() {
  replace_var "CPP_VERSION"                "$var_cpp_version";
  replace_var "CPP_VERSION_LABEL"          "$var_cpp_version_label";
  replace_var "ARTIFACT_BINARY_NAME"       "$var_artifact_binary_name";
  replace_var "ARTIFACT_BINARY_NAME_UPPER" "$var_artifact_binary_name_upper";
  replace_var "NAMESPACE"                  "$var_namespace";
  replace_var "NAMESPACE_0"                "$var_namespace_0";
  replace_var "NAMESPACE_PATH"             "$var_namespace_path";
  replace_var "NAMESPACE_COLON"            "$var_namespace_colon";
  replace_var "NAMESPACE_DECL_BEGIN"       "$var_namespace_decl_begin";
  replace_var "NAMESPACE_DECL_END"         "$var_namespace_decl_end";

  local var_cpp_header_begin="#pragma once";
  local var_cpp_header_end="";
  get_boolean_property "cpp.headers.include.guards.enable" "false";
  local use_header_include_guards="$PROPERTY_VALUE";
  if [[ "$use_header_include_guards" == "true" ]]; then
    var_cpp_header_begin='#ifndef ${{VAR_NAMESPACE_INCLUDE_GUARD}}_${{VAR_IG_FILENAME}}';
    var_cpp_header_begin+="${_NL}";
    var_cpp_header_begin+='#define ${{VAR_NAMESPACE_INCLUDE_GUARD}}_${{VAR_IG_FILENAME}}';
    var_cpp_header_end='#endif // ${{VAR_NAMESPACE_INCLUDE_GUARD}}_${{VAR_IG_FILENAME}}';
  fi
  replace_var "CPP_HEADER_BEGIN" "$var_cpp_header_begin" "h";
  replace_var "CPP_HEADER_END" "$var_cpp_header_end" "h";
  # Always replace include guard namespace for backwards compatibility
  replace_var "NAMESPACE_INCLUDE_GUARD" "$var_namespace_include_guard" "h";
  if [[ "$use_header_include_guards" == "true" ]]; then
    _cpp_adjust_header_include_guard_names;
  fi

  if [ -n "$var_namespace_path" ]; then
    expand_namespace_directories "$var_namespace_path"        \
                                 "src/main/cpp/namespace"     \
                                 "src/main/include/namespace" \
                                 "src/main/tests/cpp/namespace";
  fi
}

# Replaces the VAR_IG_FILENAME substitution variable in all C++ headers files.
#
# Globals:
# CACHE_ALL_FILES - Read access.
#
function _cpp_adjust_header_include_guard_names() {
  local ig_filename;
  local file;
  for file in "${CACHE_ALL_FILES[@]}"; do
    if [[ "$file" == *".h" ]]; then
      file="$(basename "$file")";
      ig_filename="$(echo "$file" |tr "." "_" |tr '[:lower:]' '[:upper:]')";
      replace_var "IG_FILENAME" "$ig_filename" "$file";
    fi
  done
}

# [API function]
# Prompts the user to enter the C++ version to use for the project.
#
# The provided answer can be queried in source template files via the
# VAR_CPP_VERSION_LABEL and VAR_CPP_VERSION substitution variables.
# The associated shell global variables are set by this function.
#
# Globals:
# FORM_QUESTION_ID      - cpp.version
# var_cpp_version       - The C++ version string. Is set by this function.
# var_cpp_version_label - The C++ version label string.
#                         Is set by this function.
#
function form_cpp_version() {
  FORM_QUESTION_ID="cpp.version";
  logI "";
  logI "Specify the C++ language standard to be used by the project:";
  read_user_input_selection "${SUPPORTED_LANG_VERSIONS_LABELS[@]}";
  var_cpp_version=${SUPPORTED_LANG_VERSIONS_IDS[USER_INPUT_ENTERED_INDEX]};
  var_cpp_version_label=${SUPPORTED_LANG_VERSIONS_LABELS[USER_INPUT_ENTERED_INDEX]};
}

# [API function]
# Prompts the user to enter the name of the produced binary file name
# (without possible platform-dependent file extension).
#
# The provided answer can be queried in source template files via the
# VAR_ARTIFACT_BINARY_NAME substitution variable.
# The associated shell global variable is set by this function.
#
# Globals:
# FORM_QUESTION_ID               - cpp.binary.name
# var_artifact_binary_name       - The name of the binary artifact.
#                                  Is set by this function.
# var_artifact_binary_name_upper - The name of the binary artifact in
#                                  all upper-case. Is set by this function.
#
function form_cpp_binary_name() {
  FORM_QUESTION_ID="cpp.binary.name";
  logI "";
  logI "Enter the name of the binary file that this project produces:";
  # shellcheck disable=SC2154
  USER_INPUT_DEFAULT_TEXT="$var_project_name_lower";
  logI "(Defaults to '${USER_INPUT_DEFAULT_TEXT}')";
  read_user_input_text;
  var_artifact_binary_name="$USER_INPUT_ENTERED_TEXT";
  var_artifact_binary_name_upper=$(echo "$var_artifact_binary_name" \
                                    |tr '[:lower:]' '[:upper:]');
}

# Validation function for the namespace form question.
function _validate_cpp_namespace() {
  local input="$1";
  if [ -z "$input" ]; then
    return 0;
  fi
  # Check for expected pattern
  local re="^[a-zA-Z.]*$";
  if ! [[ ${input} =~ $re ]]; then
    logI "Only the letters a-z (case insensitive) and '.' characters are allowed";
    return 1;
  fi
  if (( ${#input} == 1 )); then
    logI "A top-level namespace must be longer than one character";
    return 1;
  fi
  if [[ ${input} == *..* ]]; then
    logI "A namespace must not contain consecutive dots ('..')";
    return 1;
  fi
  if [[ ${input} == .* ]]; then
    logI "A namespace must not start with a '.'";
    return 1;
  fi
  if [[ ${input} == *. ]]; then
    logI "A namespace must not end with a '.'";
    return 1;
  fi
  local _namespace_0="$input";
  if [[ $input == *"."* ]]; then
    _namespace_0="${input%%.*}";
  fi
  # Check for disallowed names of the first package
  local _disallowed_package_names="namespace";
  if [[ " ${_disallowed_package_names} " =~ .*\ ${_namespace_0}\ .* ]]; then
    logI "Invalid namespace.";
    logI "The name '${_namespace_0}' is disallowed as a namespace";
    return 1;
  fi
  return 0;
}

# [API function]
# Prompts the user to enter the namespace that is used by the project code.
#
# The provided answer can be queried in source template files via the
# VAR_NAMESPACE substitution variable. The namespace value will be in
# dot notation. Additionally, there are more substitution variables defined
# as a result of using a namespace. For example, header include guards and
# the C++ source code namespace declaration have their own substitution
# variable. Those can be used to further involve an application namespace into
# the project's source files. The associated shell global variables are
# set by this function.
#
# Globals:
# FORM_QUESTION_ID           - cpp.namespace
# var_namespace              - The entire namespace in dot notation.
#                              Is set by this function.
# var_namespace_0            - The first package name of the namespace.
#                              Is set by this function.
# var_namespace_path         - The entire namespace in path notation (with slashes).
#                              Is set by this function.
# var_namespace_colon        - The entire namespace in colon notation (with colons).
#                              Is set by this function.
# var_namespace_header_guard - The namespace embedded in a header guard string.
#                              Is set by this function.
# var_namespace_decl_begin   - The namespace declaration start part as used in code.
#                              Is set by this function.
# var_namespace_decl_end     - The namespace declaration end part as used in code.
#                              Is set by this function.
#
function form_cpp_namespace() {
  get_property "cpp.namespace.example" "raven.myproject.mynamespace";
  local cpp_namespace_example="$PROPERTY_VALUE";

  get_property "cpp.namespace.default" "raven";
  local cpp_namespace_default="$PROPERTY_VALUE";

  FORM_QUESTION_ID="cpp.namespace";
  USER_INPUT_DEFAULT_TEXT="$cpp_namespace_default";
  logI "";
  logI "Enter the namespace for the project source code in dot notation.";
  logI "For example: '${cpp_namespace_example}'";
  logI "(Defaults to '${cpp_namespace_default}')";

  read_user_input_text _validate_cpp_namespace;

  # Set global vars
  var_namespace="$USER_INPUT_ENTERED_TEXT";
  if [[ $var_namespace == *"."* ]]; then
    var_namespace_0="${var_namespace%%.*}";
  else
    var_namespace_0="$var_namespace";
  fi
  var_namespace_path=$(echo "$var_namespace" |tr "." "/");
  var_namespace_colon="${var_namespace//./::}";
  var_namespace_include_guard=$(echo "$var_namespace"         \
                                |tr "." "_"                   \
                                |tr '[:lower:]' '[:upper:]');

  var_namespace_decl_begin="";
  var_namespace_decl_end="";
  # Put namespace items in an array.
  # Convert separators to spaces to have word split.
  # shellcheck disable=SC2207
  local _ns_items=($(echo "$var_namespace" |tr '.' ' '));
  # Concatenate namespace items in proper order
  for (( i=0; i<${#_ns_items[@]}; i++ )); do
    var_namespace_decl_begin="${var_namespace_decl_begin}namespace ${_ns_items[$i]} {${_NL}";
  done
  # Concatenate namespace items in reverse order for the closing braces
  for (( i=${#_ns_items[@]}-1; i>=0; i-- )); do
    var_namespace_decl_end="${var_namespace_decl_end}} // END NAMESPACE ${_ns_items[$i]}${_NL}";
  done
}

# Specify supported C++ versions
add_lang_version "17" "C++17";
add_lang_version "20" "C++20";
add_lang_version "23" "C++23";

# Let the user choose a C++ project type
select_project_type "cpp" "C++";
selected_name="$FORM_PROJECT_TYPE_NAME";
selected_dir="$FORM_PROJECT_TYPE_DIR";

proceed_next_level "$selected_dir";
