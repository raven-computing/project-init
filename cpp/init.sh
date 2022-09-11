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
# VAR_NAMESPACE: The namespace of the project, in dot notation
# VAR_NAMESPACE_0: The first package name in the namespace hierarchy
# VAR_NAMESPACE_PATH: The namespace of the project, in directory path notation,
#                     i.e. with slashes instead of dots
# VAR_NAMESPACE_COLON: The namespace of the project, in colon notation,
#                     i.e. with colons instead of dots
# VAR_NAMESPACE_INCLUDE_GUARD: The namespace as used in include guards
# VAR_NAMESPACE_DECL_BEGIN: The namespace declaration start part
# VAR_NAMESPACE_DECL_END: The namespace declaration end part

function process_files_lvl_1() {
  replace_var "CPP_VERSION"             "$var_cpp_version";
  replace_var "CPP_VERSION_LABEL"       "$var_cpp_version_label";
  replace_var "ARTIFACT_BINARY_NAME"    "$var_artifact_binary_name";
  replace_var "NAMESPACE"               "$var_namespace";
  replace_var "NAMESPACE_0"             "$var_namespace_0";
  replace_var "NAMESPACE_PATH"          "$var_namespace_path";
  replace_var "NAMESPACE_COLON"         "$var_namespace_colon";
  replace_var "NAMESPACE_INCLUDE_GUARD" "$var_namespace_include_guard";
  replace_var "NAMESPACE_DECL_BEGIN"    "$var_namespace_decl_begin";
  replace_var "NAMESPACE_DECL_END"      "$var_namespace_decl_end";

  if [ -n "$var_namespace_path" ]; then
    # Create namespace directory layout and move source files
    local path_ns_main="$var_project_dir/src/main/cpp/$var_namespace_path/";
    local path_ns_include="$var_project_dir/src/main/include/$var_namespace_path/";
    local path_ns_tests="$var_project_dir/src/main/tests/cpp/$var_namespace_path/";
    if [ -d "$var_project_dir/src/main/cpp" ]; then
      mkdir -p "$path_ns_main";
      if (( $? != 0 )); then
        failure "Failed to create source code namespace directory:" \
                "at: '$path_ns_main'";
      fi
    fi
    if [ -d "$var_project_dir/src/main/include" ]; then
      mkdir -p "$path_ns_include";
      if (( $? != 0 )); then
        failure "Failed to create source code namespace directory:" \
                "at: '$path_ns_include'";
      fi
    fi
    if [ -d "$var_project_dir/src/main/tests" ]; then
      mkdir -p "$path_ns_tests";
      if (( $? != 0 )); then
        failure "Failed to create source code namespace directory:" \
                "at: '$path_ns_tests'";
      fi
    fi

    if [ -d "$var_project_dir/src/main/cpp/namespace" ]; then
      # Create directory layout for main files
      for f in $(find "$var_project_dir/src/main/cpp/namespace" -type f); do
        mv "$f" "$path_ns_main";
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
    if [ -d "$var_project_dir/src/main/include/namespace" ]; then
      # Create directory layout for inlude header files
      for f in $(find "$var_project_dir/src/main/include/namespace" -type f); do
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
    if [ -d "$var_project_dir/src/main/tests/cpp/namespace" ]; then
      # Create directory layout for test files
      for f in $(find "$var_project_dir/src/main/tests/cpp/namespace" -type f); do
        mv "$f" "$path_ns_tests";
        if (( $? != 0 )); then
          failure "Failed to move source file into namespace layout directory";
        fi
      done
      # Remove the original now empty placeholder namespace dir
      rm -r "$var_project_dir/src/main/tests/cpp/namespace/";
      if (( $? != 0 )); then
          failure "Failed to remove template source namespace directory";
      fi
    fi
    # Update file cache
    find_all_files;
  fi
}

# [API function]
# Prompts the user to enter the C++ version to use for the project.
#
# Globals:
# var_cpp_version       - The C++ version string. Is set by this function.
# var_cpp_version_label - The C++ version label string.
#                         Is set by this function.
#
function form_cpp_version() {
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
# Globals:
# var_artifact_binary_name - The name of the binary artifact.
#                            Is set by this function.
#
function form_cpp_binary_name() {
  logI "";
  logI "Enter the name of the binary file that this project produces:";
  logI "(Defaults to '$var_project_name_lower')";
  read_user_input_text
  local entered_binary_name="$USER_INPUT_ENTERED_TEXT";
  if [ -z "$entered_binary_name" ]; then
    entered_binary_name="$var_project_name_lower";
  fi
  var_artifact_binary_name="$entered_binary_name";
}

# [API function]
# Prompts the user to enter the namespace that is used by the project code.
#
# Globals:
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

  logI "";
  logI "Enter the namespace for the project source code in dot notation.";
  logI "For example: '$cpp_namespace_example'";
  logI "(Defaults to '$cpp_namespace_default')";

  read_user_input_text;
  local _namespace_name="$USER_INPUT_ENTERED_TEXT";

  # Validate given namespace string
  if [ -z "${_namespace_name}" ]; then
    _namespace_name="$cpp_namespace_default";
  fi
  # Check for expected pattern
  local re="^[a-z][a-z\.]*[a-z]*$";
  if ! [[ ${_namespace_name} =~ $re ]]; then
    logE "Invalid input";
    if [[ ${_namespace_name} == .* || ${_namespace_name} == *. ]]; then
      failure "An invalid namespace was specified." \
              "A namespace must not start or end with a '.'";
    else
      failure "The entered namespace contains invalid characters" \
              "Only lower-case a-z and '.' characters are allowed";
    fi
  fi

  # Set global vars
  var_namespace="${_namespace_name}";
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

  # Check for disallowed names of the first package
  local _disallowed_package_names="namespace";
  if [[ " ${_disallowed_package_names} " =~ .*\ ${var_namespace_0}\ .* ]]; then
    logE "Invalid input";
    failure "An invalid namespace was specified." \
            "The name '$var_namespace_0' is disallowed";
  fi
}

# Specify supported C++ versions
add_lang_version "14" "C++14";
add_lang_version "17" "C++17";
add_lang_version "20" "C++20";

# Let the user choose a C++ project type
select_project_type "cpp" "C++";
selected_name="$FORM_PROJECT_TYPE_NAME";
selected_dir="$FORM_PROJECT_TYPE_DIR";

proceed_next_level "$selected_dir";
