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
# *                ***   Init Script for Python Projects   ***                *
# *                                 INIT LEVEL 1                              *
# *                                                                           *
# #***************************************************************************#
#
# This init script sets the following substitution variables:
#
# VAR_PYTHON_VERSION: The version string of Python to use, e.g. '3.8'
# VAR_PROJECT_VIRTENV_NAME: The name of the virtual environment for the project
# VAR_NAMESPACE_DECLARATION: The namespace of the project, in dot notation
# VAR_NAMESPACE_DECLARATION_0: The first package name in the package hierarchy
# VAR_NAMESPACE_DECLARATION_PATH: The namespace of the project, in directory
#                                 path notation (with slashes instead of dots)
# VAR_PACKAGE_DECLARATION: The module package name. Not any namespace package
# VAR_LICENSE_CLASSIFIER_SETUP_PY: The 'classifiers' arg in the setup() function
#                                  of the setup.py script
# VAR_SETUP_PY_SETUPTOOLS_IMPORT: The import statement for setuptools in
#                                 the setup.py script
# VAR_SETUP_PY_FIND_PACKAGES: The 'packages' arg in the setup() function of
#                             the setup.py script
# VAR_SCRIPT_TEST_LINT_HELP: The help text for the lint option in
#                            the test.sh script
# VAR_SCRIPT_TEST_LINT_ARG: The boolean arg flag for the lint option in
#                           the test.sh script
# VAR_SCRIPT_TEST_LINT_ARG_PARSE: The arg parsing code for the lint option
#                                 in the test.sh script
# VAR_SCRIPT_TEST_LINT_CODE: The script code block for calling the linter
#                            in the test.sh script
# VAR_REQUIREMENTS_LINT: The requirements.txt item for the linter dependency
# VAR_README_DEV_LINT: The Readme text block for informing about how to
#                      use the linter
# VAR_REQUIREMENTS_DEPLOY: The requirements.txt item for the
#                          deployment dependency
# VAR_README_DEV_DEPLOY: The Readme text block for informing about how to
#                        deploy the library to PyPI or other system


function process_files_lvl_1() {
  replace_var "PROJECT_VIRTENV_NAME"        "$var_project_virtenv_name";
  replace_var "PYTHON_VERSION"              "$var_python_version";
  replace_var "LICENSE_CLASSIFIER_SETUP_PY" "$var_license_classifier_setup_py";

  # Check whether the source code is placed in a normal module package
  # or a namespace package
  local use_namespace_package=true;
  if [[ "$var_namespace" == "$var_package" ]]; then
    use_namespace_package=false;
  fi

  if [[ $use_namespace_package == true ]]; then
    load_var_from_file "SETUP_PY_SETUPTOOLS_IMPORT_NAMESPACE";
    replace_var "SETUP_PY_SETUPTOOLS_IMPORT" "$VAR_FILE_VALUE";
    load_var_from_file "SETUP_PY_FIND_PACKAGES_NAMESPACE";
    replace_var "SETUP_PY_FIND_PACKAGES" "$VAR_FILE_VALUE";
  else
    load_var_from_file "SETUP_PY_SETUPTOOLS_IMPORT_PACKAGE";
    replace_var "SETUP_PY_SETUPTOOLS_IMPORT" "$VAR_FILE_VALUE";
    load_var_from_file "SETUP_PY_FIND_PACKAGES_PACKAGE";
    replace_var "SETUP_PY_FIND_PACKAGES" "$VAR_FILE_VALUE";
  fi

  replace_var "NAMESPACE_DECLARATION"      "$var_namespace";
  replace_var "NAMESPACE_DECLARATION_0"    "$var_namespace_0";
  replace_var "NAMESPACE_DECLARATION_PATH" "$var_namespace_path";
  replace_var "PACKAGE_DECLARATION"        "$var_package";

  # Check usage of linter
  if [[ $var_use_linter == true ]]; then
    replace_var "SCRIPT_TEST_LINT_HELP";
    replace_var "SCRIPT_TEST_LINT_ARG";
    replace_var "SCRIPT_TEST_LINT_ARG_PARSE";
    replace_var "SCRIPT_TEST_LINT_CODE";
    replace_var "REQUIREMENTS_LINT";
    replace_var "README_DEV_LINT";
    # The subst var 'VAR_SCRIPT_TEST_LINT_ARG_PARSE' contains another
    # subst var, related to Docker integration, which needs to be replaced again
    replace_var "SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD" \
                "$var_script_build_isolated_argarray_add";
  else
    replace_var "SCRIPT_TEST_LINT_HELP"      "";
    replace_var "SCRIPT_TEST_LINT_ARG"       "";
    replace_var "SCRIPT_TEST_LINT_ARG_PARSE" "";
    replace_var "SCRIPT_TEST_LINT_CODE"      "";
    replace_var "REQUIREMENTS_LINT"          "";
    replace_var "README_DEV_LINT"            "";
    # Remove pylintrc file
    if [ -f "$var_project_dir/pylintrc" ]; then
      rm "$var_project_dir/pylintrc";
      if (( $? != 0 )); then
        failure "Failed to remove template source pylintrc file";
      fi
    fi
  fi

  # Check usage of deployment script
  if [[ $var_use_deploy == true ]]; then
    replace_var "REQUIREMENTS_DEPLOY";
    replace_var "README_DEV_DEPLOY";
  else
    replace_var "REQUIREMENTS_DEPLOY" "";
    replace_var "README_DEV_DEPLOY"   "";
    # Remove the deploy script
    if [ -f "$var_project_dir/deploy.sh" ]; then
      rm "$var_project_dir/deploy.sh";
      if (( $? != 0 )); then
        failure "Failed to remove template source deploy script";
      fi
      # Update file cache
      find_all_files;
    fi
  fi

  # We assume that Python source code files are in a 'package' directory.
  # In the following we create the namespace directory layout or rename
  # the main package to the user given name. If the project template root
  # stores the *.py files in a different directory, or should have another
  # package in the project root, then this must be handled
  # by custom init code.
  if [ -n "$var_package" ]; then
    if [ -d "$var_project_dir/package/" ]; then
      # Create namespace directory layout and move source files
      local path_ns_package="$var_project_dir/$var_namespace_path/";
      mkdir -p "$path_ns_package";
      if (( $? != 0 )); then
        failure "Failed to create package directory layout";
      fi

      # Move source files into correct package
      for f in $(find "$var_project_dir/package/" -type f); do
        mv "$f" "$path_ns_package";
        if (( $? != 0 )); then
          failure "Failed to move source file into package directory";
        fi
      done
      # Remove the original empty package dir
      rm -r "$var_project_dir/package/";
      if (( $? != 0 )); then
        failure "Failed to remove template source package directory";
      fi
      # Update file cache
      find_all_files;
    fi
  fi
}

# Validation function for the Python executable script name form question.
function _validate_exec_script_name() {
  local input="$1";
  if [ -z "$input" ]; then
    return 0;
  fi
  local re="^[0-9a-zA-Z_-]+$";
  if ! [[ "$input" =~ $re ]]; then
    logI "Invalid name for executable script.";
    logI "Only lower/upper-case A-Z, digits, '-' and '_' characters are allowed";
    return 1;
  fi
  return 0;
}

# Validation function for the Python version form question.
function _validate_python_version() {
  local input="$1";
  if [ -z "$input" ]; then
    return 0;
  fi
  local re="^3\.[0-9]+$";
  if ! [[ $input =~ $re ]]; then
    if [[ $input =~ ^([0-2]|[4-9])\.? ]]; then
      logI "Unsupported Python major vesion.";
      logI "Only Python 3 versions are supported at this time.";
    else
      logI "The version must be specified as 'major.minor', e.g. '3.7' ";
    fi
    return 1;
  fi
  return 0;
}

# [API function]
# Prompts the user to enter the Python version to use for the project.
#
# The provided answer can be queried in source template files via the
# VAR_PYTHON_VERSION substitution variable.
# The associated shell global variable is set by this function.
#
# Globals:
# FORM_QUESTION_ID   - python.version
# var_python_version - The Python version string. Is set by this function.
#
function form_python_version() {
  FORM_QUESTION_ID="python.version";
  logI "";
  logI "Specify the minimum version of Python required by the project.";
  logI "Please enter the major and minor version numbers, e.g. '3.8'";
  logI "The default is '3.5'";
  read_user_input_text _validate_python_version;
  var_python_version="$USER_INPUT_ENTERED_TEXT";

  # Validate Python version string
  if [ -z "$var_python_version" ]; then
    logI "The minimum Python version will be set to 3.5";
    var_python_version="3.5";
  fi
}

# Validation function for the Python virtenv name form question.
function _validate_virtenv_name() {
  local input="$1";
  if [ -z "$input" ]; then
    return 0;
  fi
  # Validate virtual env name
  local re="^[0-9a-zA-Z_-]+$";
  if ! [[ "$input" =~ $re ]]; then
    logI "Invalid name for virtual environment.";
    logI "Only lower/upper-case A-Z, digits, '-' and '_' characters are allowed";
    return 1;
  fi
  return 0;
}

# [API function]
# Prompts the user to enter the name of the virtual environment
# to be used by the project.
#
# The provided answer can be queried in source template files via the
# VAR_PROJECT_VIRTENV_NAME substitution variable.
# The associated shell global variable is set by this function.
#
# Globals:
# FORM_QUESTION_ID         - python.virtenv.name
# var_project_virtenv_name - The name of the virtual environment.
#                            Is set by this function.
#
function form_python_virtenv_name() {
  FORM_QUESTION_ID="python.virtenv.name";
  logI "";
  logI "Specify the name of the project virtual environment.";
  logI "Or press enter to use the default name '$var_project_name_lower'";
  read_user_input_text _validate_virtenv_name;
  var_project_virtenv_name="$USER_INPUT_ENTERED_TEXT";

  if [ -z "$var_project_virtenv_name" ]; then
    var_project_virtenv_name="$var_project_name_lower";
  fi
}

# Validation function for the Python package/namespace form question.
function _validate_python_package_name() {
  local input="$1";
  if [ -z "$input" ]; then
    logI "No package name specified.";
    logI "You must specify a package name where your source code should reside";
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
  local _disallowed_package_names="package build dist tests";
  if [[ " ${_disallowed_package_names} " =~ .*\ ${_namespace_0}\ .* ]]; then
    logI "Invalid package name.";
    logI "The name '${_namespace_0}' is disallowed";
    return 1;
  fi
  return 0;
}

# [API function]
# Prompts the user to enter the name of the main package, potentially including
# any namespace packages, that is used by the project.
#
# The provided answer can be queried in source template files via the
# VAR_NAMESPACE_DECLARATION substitution variable. The namespace value will
# be in dot notation. Additionally, there are more substitution variables
# defined for specific aspects of package declarations. For example, the first
# package name in a series of namespace package declarations (dot notation) can
# be accessed by the VAR_NAMESPACE_DECLARATION_0 substitution variable.
# The associated shell global variables are set by this function.
#
# Globals:
# FORM_QUESTION_ID   - python.package.name
# var_namespace      - The entire namespace in dot notation. Is set by this function.
#                      This is equivalent to the package name if no namespace package
#                      was defined.
# var_namespace_0    - The first namespace package. Is set by this function. This is
#                      equivalent to the package name if no namespace package
#                      was defined.
# var_namespace_path - The entire namespace in path notation (with slashes).
#                      Is set by this function. This is equivalent to the package
#                      name if no namespace package was defined.
# var_package        - The main package name of the project. Is set by this function.
#                      This is always the last package name, regardless how many
#                      namespace packages were defined.
#
function form_python_package_name() {
  get_property "python.namespace.example" "raven.mynamespace.myproject";
  local py_namespace_example="$PROPERTY_VALUE";

  FORM_QUESTION_ID="python.package.name";
  logI "";
  logI "Enter the package name of the Python source code.";
  logI "You can specify multiple levels of packages in dot notation, which will put";
  logI "the lowermost package under the specified namespace packages.";
  logI "For example: '$py_namespace_example'";

  read_user_input_text _validate_python_package_name;
  local _package_namespace_name="$USER_INPUT_ENTERED_TEXT";

  # Set global vars
  var_namespace="${_package_namespace_name}";
  var_namespace_0="";
  var_namespace_path="";
  var_package="";

  if [[ ${_package_namespace_name} == *"."* ]]; then
    var_namespace_0="${var_namespace%%.*}";
    var_package="${var_namespace##*.}";
  else
    var_namespace_0="$var_namespace";
    var_package="$var_namespace";
  fi
  var_namespace_path=$(echo "$var_namespace" |tr "." "/");
}

# [API function]
# Prompts the user to enter whether he wants to use a linter during
# the project development.
#
# Globals:
# FORM_QUESTION_ID - python.use.linter
# var_use_linter   - A boolean flag indicating whether to use a linter.
#                    Is set by this function.
#
function form_python_use_linter() {
  FORM_QUESTION_ID="python.use.linter";
  logI "";
  logI "Would you like to use a linter for static code analysis? (Y/n)";
  read_user_input_yes_no true;
  var_use_linter=$USER_INPUT_ENTERED_BOOL;
}

# [API function]
# Prompts the user to enter whether he wants to deploy the project to PyPI.
#
# Globals:
# FORM_QUESTION_ID - python.pypi.deployment
# var_use_deploy   - A boolean flag indicating whether to deploy project
#                    artifacts to PyPI. Is set by this function.
#
function form_python_pypi_deployment() {
  FORM_QUESTION_ID="python.pypi.deployment";
  logI "";
  logI "Would you like to be able to deploy the build artifacts to PyPI? (y/N)";
  read_user_input_yes_no false;
  var_use_deploy=$USER_INPUT_ENTERED_BOOL;
}

# Create the mapping for the setup.py license classifier
var_license_classifier_setup_py="";
if [[ "$var_project_license" == "Apache License 2.0" ]]; then
  var_license_classifier_setup_py="License :: OSI Approved :: Apache Software License";
elif [[ "$var_project_license" == "MIT License" ]]; then
  var_license_classifier_setup_py="License :: OSI Approved :: MIT License";
elif [[ "$var_project_license" == "Boost Software License 1.0" ]]; then
  var_license_classifier_setup_py=\
"License :: OSI Approved :: Boost Software License 1.0 (BSL-1.0)";
elif [[ "$var_project_license" == "GNU General Public License 2.0" ]]; then
  var_license_classifier_setup_py=\
"License :: OSI Approved :: GNU General Public License v2 (GPLv2)";
else
  var_license_classifier_setup_py="License :: Other/Proprietary License";
fi

# Let the user choose a Python project type
select_project_type "python" "Python";
selected_name="$FORM_PROJECT_TYPE_NAME";
selected_dir="$FORM_PROJECT_TYPE_DIR";

proceed_next_level "$selected_dir";
