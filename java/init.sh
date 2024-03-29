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
# *                 ***   Init Script for Java Projects   ***                 *
# *                                 INIT LEVEL 1                              *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_PROJECT_GROUP_ID: The Maven group ID used for the project
# VAR_PROJECT_ARTIFACT_ID: The Maven artifact ID used for the project
# VAR_JAVA_VERSION: The Java version in conventional form
# VAR_JAVA_VERSION_LABEL: The Java version label
# VAR_JAVA_VERSION_POM: The Java version in the form as used inside a POM
# VAR_NAMESPACE_DECLARATION: The namespace of the project, in dot notation
# VAR_NAMESPACE_DECLARATION_PATH: The namespace of the project, in path notation
# VAR_NAMESPACE_0: The first package name in the namespace hierarchy
# VAR_NAMESPACE_DECLARATION_TRAILING_SEP: The namespace in dot notation, with a
#                                         trailing dot at the end as
#                                         the last character
# VAR_NAMESPACE_PACKAGE_DECLARATION: The package declaration statement in
#                                    a .java file, indicating the namespace

# All supported relational database names and
# their corresponding identifiers
SUPPORTED_REL_DATABASES=();
SUPPORTED_REL_DATABASES_KEYS=();

# Files which should not be moved under
# a specified namespace directory layout
FILES_NO_MOVE=();
FILES_NO_MOVE+=('module-info.java');


function process_files_lvl_1() {
  replace_var "PROJECT_GROUP_ID"                   "$var_project_group_id";
  replace_var "PROJECT_ARTIFACT_ID"                "$var_project_artifact_id";
  replace_var "JAVA_VERSION"                       "$var_java_version";
  replace_var "JAVA_VERSION_LABEL"                 "$var_java_version_label";
  replace_var "NAMESPACE_DECLARATION"              "$var_namespace";
  replace_var "NAMESPACE_DECLARATION_0"            "$var_namespace_0";
  replace_var "NAMESPACE_DECLARATION_PATH"         "$var_namespace_path";
  replace_var "NAMESPACE_DECLARATION_TRAILING_SEP" "$var_namespace_trailing_sep";

  # Check for Java 8 compatibility requirement and adjust the POM based on that.
  if [[ "$var_java_version" == "1.8" ]]; then
    replace_var "POM_PROPERTIES" "";
    load_var_from_file "POM_PROFILES";
    replace_var "POM_PROFILES" "$VAR_FILE_VALUE";
  else
    load_var_from_file "POM_PROPERTIES";
    replace_var "POM_PROPERTIES" "$VAR_FILE_VALUE";
    replace_var "POM_PROFILES" "";
  fi

  replace_var "JAVA_VERSION_POM" "$var_java_version_pom";

  if [ -z "$var_namespace" ]; then
    replace_var "NAMESPACE_PACKAGE_DECLARATION" "";
  else
    replace_var "NAMESPACE_PACKAGE_DECLARATION" "package $var_namespace;";
    expand_namespace_directories "$var_namespace_path"     \
                                 "src/main/java/namespace" \
                                 "src/test/java/namespace";
  fi
}

# [API function]
# Prompts the user to enter the Java version to use for the project.
#
# The provided answer can be queried in source template files via the
# VAR_JAVA_VERSION and VAR_JAVA_VERSION_LABEL substitution variables.
# Additionally, since the version identifier might differ when used
# inside a Maven POM, the VAR_JAVA_VERSION_POM substitution variable is
# also set. It should be used instead when setting the used Java
# version inside a POM. The associated shell global variables are
# set by this function.
#
# Globals:
# FORM_QUESTION_ID       - java.version
# var_java_version       - The Java version string. Is set by this function.
# var_java_version_label - The Java version label string. Is set by this function.
# var_java_version_pom   - The Java version string as used in a project's POM.
#                          Is set by this function.
#
function form_java_version() {
  FORM_QUESTION_ID="java.version";
  logI "";
  logI "Select the version of Java to be used by the project:";
  read_user_input_selection "${SUPPORTED_LANG_VERSIONS_LABELS[@]}";
  var_java_version="${SUPPORTED_LANG_VERSIONS_IDS[USER_INPUT_ENTERED_INDEX]}";
  var_java_version_label="${SUPPORTED_LANG_VERSIONS_LABELS[USER_INPUT_ENTERED_INDEX]}";
  var_java_version_pom="$var_java_version";
}

# Validation function for the namespace form question.
function _validate_java_namespace() {
  local input="$1";
  if [ -z "$input" ]; then
    logI "Please specify a namespace";
    return 1;
  fi
  # Check for expected pattern
  local re="^[a-z.]*$";
  if ! [[ ${input} =~ $re ]]; then
    logI "Only lower-case a-z and '.' characters are allowed";
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
  local _disallowed_package_names="namespace jni";
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
# VAR_NAMESPACE_DECLARATION substitution variable. The namespace value will
# be in dot notation. The associated shell global variable is
# set by this function.
#
# Globals:
# FORM_QUESTION_ID           - java.namespace
# var_namespace              - The entire namespace in dot notation.
#                              Is set by this function.
# var_namespace_trailing_sep - The namespace in dot notation, with a
#                              trailing dot at the end as the last character.
#                              Is set by this function.
# var_namespace_path         - The entire namespace in path notation
#                              (with slashes). Is set by this function.
#
function form_java_namespace() {
  FORM_QUESTION_ID="java.namespace";
  logI "";
  logI "Enter the namespace of the main class in dot notation.";
  get_property "java.namespace.example" "raven.myproject";
  local j_namespace_example="$PROPERTY_VALUE";
  logI "For example: '$j_namespace_example'";
  read_user_input_text _validate_java_namespace;
  local entered_namespace="$USER_INPUT_ENTERED_TEXT";

  var_namespace="$entered_namespace";
  var_namespace_path="${var_namespace//.//}";
  var_namespace_trailing_sep="${var_namespace}.";
  if [[ $var_namespace == *"."* ]]; then
    var_namespace_0="${var_namespace%%.*}";
  else
    var_namespace_0="$var_namespace";
  fi
}

function set_database_system() {
  local j_db_str="$1";
  local j_db_key="$2";
  SUPPORTED_REL_DATABASES+=("$j_db_str");
  SUPPORTED_REL_DATABASES_KEYS+=("$j_db_key");
}

# Set variables from properties
get_property "java.pom.groupid" "com.raven-computing";
var_project_group_id="$PROPERTY_VALUE";

# Set the Maven artifactId to be the lower-case version of the project name
# shellcheck disable=SC2154
var_project_artifact_id="$var_project_name_lower";

# Specify supported relational database systems
set_database_system "MySQL" "mysql";
set_database_system "MariaDB" "mariadb";
set_database_system "PostgreSQL" "postgresql";
set_database_system "Other" "OTHER";

# Specify supported Java versions
add_lang_version "1.8" "Java 8";
add_lang_version "11" "Java 11";
add_lang_version "17" "Java 17";
add_lang_version "21" "Java 21";

select_project_type "java" "Java";
selected_name="$FORM_PROJECT_TYPE_NAME";
selected_dir="$FORM_PROJECT_TYPE_DIR";

proceed_next_level "$selected_dir";
