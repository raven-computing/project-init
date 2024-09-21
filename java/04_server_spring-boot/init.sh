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
# *             ***   Init Script for Spring Boot Projects   ***              *
# *                               INIT LEVEL 2                                *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_DATABASE_NAME: The name of the database used by the application
# VAR_SPRING_DEPENDENCY_DATA_JPA: Maven dependency information for JPA usage
# VAR_SPRING_DEPENDENCY_DATA_DRIVER_MYSQL: Maven dependency information
#                                          for MySQL driver usage
# VAR_SPRING_DEPENDENCY_DATA_DRIVER_MARIADB: Maven dependency information
#                                            for MariaDB driver usage
# VAR_SPRING_DEPENDENCY_DATA_DRIVER_POSTGRESQL: Maven dependency information
#                                               for PostgreSQL driver usage
# VAR_SPRING_DEPENDENCY_SECURITY: Maven dependency information
#                                 for Spring Security usage
# VAR_SPRING_DEPENDENCY_SECURITY_TEST: Maven dependency information
#                                      for Spring Security test framework usage
# VAR_POM_DEPENDENCY_H2_TEST: Maven dependency information for the H2 in-memory
#                             database used for testing


function process_files_lvl_2() {
  replace_var "DATABASE_NAME" "$var_database_name";
  replace_var "SPRING_DEPENDENCY_DATA_JPA"                     \
              "$var_spring_dependency_data_jpa";
  # shellcheck disable=SC2154
  replace_var "SPRING_DEPENDENCY_DATA_DRIVER_MYSQL"            \
              "$var_spring_dependency_data_driver_mysql";
  # shellcheck disable=SC2154
  replace_var "SPRING_DEPENDENCY_DATA_DRIVER_MARIADB"          \
              "$var_spring_dependency_data_driver_mariadb";
  # shellcheck disable=SC2154
  replace_var "SPRING_DEPENDENCY_DATA_DRIVER_POSTGRESQL"       \
              "$var_spring_dependency_data_driver_postgresql";
  replace_var "SPRING_DEPENDENCY_SECURITY"                     \
              "$var_spring_dependency_security";
  replace_var "SPRING_DEPENDENCY_SECURITY_TEST"                \
              "$var_spring_dependency_security_test";
  replace_var "POM_DEPENDENCY_H2_TEST"                         \
              "$var_pom_dependency_h2_test";
}

# Prompts the user to specify whether to use a relational database.
#
# Globals:
# var_spring_dependency_data_jpa      - Dependency information for JPA usage.
#                                       Is set by this function.
# var_database_name                   - The name of the database.
#                                       Is set by this function.
# var_spring_dependency_data_driver_* - Maven dependency information for database
#                                       driver usage. Is set by this function.
#
function form_relational_database() {
  FORM_QUESTION_ID="java.server.relationaldb";
  logI "";
  logI "Will the project require access to a relational database? (Y/n)";
  read_user_input_yes_no true;
  if [[ $USER_INPUT_ENTERED_BOOL == true ]]; then
    logI "";
    logI "A dependency to JPA via Spring Data will be added";
    load_var_from_file "SPRING_DEPENDENCY_DATA_JPA";
    var_spring_dependency_data_jpa="$VAR_FILE_VALUE";
    load_var_from_file "POM_DEPENDENCY_H2_TEST";
    var_pom_dependency_h2_test="$VAR_FILE_VALUE";
    FORM_QUESTION_ID="java.server.relationaldb.name";
    logI "";
    logI "A database driver needs to be provided at runtime.";
    logI "Please select the database system the application should connect to:";
    read_user_input_selection "${SUPPORTED_REL_DATABASES[@]}";
    var_database_name="${SUPPORTED_REL_DATABASES[USER_INPUT_ENTERED_INDEX]}";
    var_database_key="${SUPPORTED_REL_DATABASES_KEYS[USER_INPUT_ENTERED_INDEX]}";
    if [[ "$var_database_key" == "OTHER" ]]; then
      logI "No specific database driver dependency will be" \
          "added to the project POM.";
      logI "You have to add it manually later.";
    else
      logI "A runtime dependency to the $var_database_name driver" \
          "will be added to the POM";
      load_var_from_file "spring_dependency_data_driver_${var_database_key}";
      local file_content="$VAR_FILE_VALUE";
      declare var_spring_dependency_data_driver_${var_database_key}="$file_content";
    fi
    logI "You will have to specify the database connection before you" \
        "can use the application";
  fi
}

# Prompts the user to specify whether to use the Spring Security dependency.
#
# Globals:
# var_spring_dependency_security      - Dependency information for Spring Security usage.
#                                       Is set by this function.
# var_spring_dependency_security_test - Test dependency information for Spring Security
#                                       usage. Is set by this function.
#
function form_spring_security() {
  FORM_QUESTION_ID="java.server.springsecurity";
  logI "";
  logI "Should the application use security mechanisms provided by Spring? (Y/n)";
  read_user_input_yes_no true;
  if [ $USER_INPUT_ENTERED_BOOL == true ]; then
    logI "";
    logI "A dependency to Spring Security will be added";
    load_var_from_file "SPRING_DEPENDENCY_SECURITY";
    var_spring_dependency_security="$VAR_FILE_VALUE";
    load_var_from_file "SPRING_DEPENDENCY_SECURITY_TEST";
    var_spring_dependency_security_test="$VAR_FILE_VALUE";
  fi
}

# Form questions

form_java_version;

form_java_namespace;

if [ -z "$var_namespace" ]; then
  logW "No namespace has been specified.";
  logW "It is not recommended to use the default package" \
       "for classes in a Spring Boot application";
  logW "Your project might not compile";
  warning "The initialized Spring Boot application does not have a namespace";
fi

form_relational_database;

form_spring_security;

form_docs_integration;

form_docker_integration;

# Project setup

project_init_copy;

project_init_license "java";

project_init_process;
