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
# *               ***   Project Init Installation Script   ***                *
# *                                                                           *
# #***************************************************************************#
#
# This script is used to install/uninstall the Project Init script on a host system.
# Installation will only copy the run.sh script to an appropriate location to
# allow bootstrapping the Project Init system's latest version on demand.
# This script may also be used to uninstall the run.sh script from
# a host system by using the '--uninstall' option. By default, the user has to
# confirm the (un)installation. This can be circumvented by using
# the '--yes' option.
# The place in the filesystem where the Project Init system will be installed is
# determined by the effective user ID when running this script. When this script
# is executed by the root user, the Project Init system will be installed in a
# system-wide location, otherwise it will be installed in a user-wide location.
# This script will have an exit status of 0 if the (un)installation was
# executed successfully. Otherwise, the exit status will be non-zero.
#
# USAGE: install.sh [--uninstall] [-y|--yes]


# The file resource that will be installed
PROJECT_INIT_INSTALL_FILE="https://github.com/raven-computing/project-init/raw/v1-latest/bootstrap/run.sh";

# The name of the executable script to be installed.
# This is the command name by which the system can
# be called once it is installed
INSTALL_BIN_NAME="project-init";

# The absolute path to the location where the bootstrap script
# is installed when in SYSTEM-wide mode.
INSTALL_PATH_SYSTEM="/usr/local/bin";

# The relative path from a users home directory to the location where
# the bootstrap script is installed when in USER-wide mode.
INSTALL_PATH_USER=".local/bin";

# Effective user ID
_EUID=$(id -u);

# A boolean indicating whether the install path was
# created as a result of the installation process.
_INSTALLATION_DIR_CREATED=false;


# Parses the specified arguments.
#
# Args:
# $@ -  The arguments to parse.
#
# Globals:
# ARG_UNINSTALL  - Represents the '--uninstall' option.
# ARG_ASSUME_YES - Represents the '--yes' option.
#
function parse_args() {
  ARG_UNINSTALL=false;
  ARG_ASSUME_YES=false;
  for arg in "$@"; do
    case $arg in
      --uninstall)
      ARG_UNINSTALL=true;
      shift;
      ;;
      -y|--yes)
      ARG_ASSUME_YES=true;
      shift;
      ;;
      *)
      # Unknown argument
      echo "Unknown argument: '$arg'";
      exit 1;
      ;;
    esac
  done
}

# Prompts the user to confirm an action.
#
# Args:
# $1 - A message to be displayed to the user.
#
# Returns:
# 0 - If the user has explicitly confirmed the action,
#     i.e. given a yes-like answer.
# 1 - If the user has denied the action, i.e. given a no-like answer,
#     entered an invalid answer or nothing at all
#
function confirm_action() {
  read -r -p "$1" entered_yes_no;
  # Validate user input
  if [ -z "$entered_yes_no" ]; then
    entered_yes_no="no";
  fi
  # Validate against supported pattern
  case "$entered_yes_no" in
    1|YES|yes|Yes|Y|y|true|True)
    entered_yes_no=true;
    ;;
    0|NO|no|No|N|n|false|False)
    entered_yes_no=false;
    ;;
    *)
    echo "ERROR: Invalid input";
    echo "Please enter either yes or no";
    ;;
  esac
  if [[ $entered_yes_no == true ]]; then
    return 0;
  else
    return 1;
  fi
}

# Indicates whether the Project Init system is currently
# installed on the host.
#
# Returns:
# 0 - If, and only if, an installed Project Init system can be found.
# 1 - If no installed Project Init system can be found.
#
# Globals:
# FOUND_INSTALLATION - Will be set by this function to contain the
#                      absolute path to the installed file, including
#                      the file name, in the case that an existing
#                      installation is found. If no Projetc Init installation
#                      is found, this global variable is not set.
#
function is_installed() {
  # First, see if the corresponding command is available.
  local cmd_path;
  cmd_path="$(command -v $INSTALL_BIN_NAME)";
  if [ -n "$cmd_path" ]; then
    FOUND_INSTALLATION="$cmd_path";
    return 0;
  fi
  # Search in the system installation directory
  if [ -r "${INSTALL_PATH_SYSTEM}/${INSTALL_BIN_NAME}" ]; then
    FOUND_INSTALLATION="${INSTALL_PATH_SYSTEM}/${INSTALL_BIN_NAME}";
    return 0;
  fi
  # Search in the user's installation directory
  if [ -r "$INSTALL_PATH_USER/$INSTALL_BIN_NAME" ]; then
    FOUND_INSTALLATION="${INSTALL_PATH_USER}/${INSTALL_BIN_NAME}";
    return 0;
  fi
  return 1;
}

# Installs the Project Init system.
#
# Args:
# $1 - The install path.
#
# Returns:
# 0  - If, and only if, the system was correctly insalled.
# nz - Non-zero otherwise.
#
function install_project_init() {
  local install_path="$1";
  local install_file_name_tmp="pi_file_to_be_installed_7a17bd714f823cb5.sh";
  local cmd_exit_status=0;
  local pi_updated=false;
  # Ask for confirmation unless '--yes' option was specified
  if [[ $ARG_ASSUME_YES == false ]]; then
    local question="Do you want to install the Project Init system? (y/N): ";
    if is_installed; then
      pi_updated=true;
      question="The Project Init system is already installed. Do you want to update? (y/N): ";
    fi
    if ! confirm_action "$question"; then
      echo "Terminating...";
      return 1;
    fi
  fi
  # First download the file to a temporary directory
  if ! cd "/tmp"; then
    echo "ERROR: Failed to switch to system's temporary directory";
    return 1;
  fi
  # Ensure that wget is available
  if ! command -v "wget" &> /dev/null; then
    echo "ERROR: Could not find the 'wget' executable.";
    echo "Please make sure that wget is correctly installed.";
    return 1;
  fi
  # Fetch resource to be installed
  wget -O "$install_file_name_tmp" "$PROJECT_INIT_INSTALL_FILE" &> /dev/null;
  cmd_exit_status=$?;
  if (( cmd_exit_status != 0 )); then
    echo "ERROR: Failed to fetch resources from server:" \
         "wget returned non-zero exit status $cmd_exit_status";
    return 1;
  fi
  # Sanity check: Downloaded file exists
  if ! [ -f "$install_file_name_tmp" ]; then
    echo "ERROR: Failed to download resources. File not found";
    return 1;
  fi
  # Sanity check: Downloaded file has shebang
  local first_line;
  first_line="$(head -n 1 $install_file_name_tmp)";
  if [[ "$first_line" != "#!/bin/bash" ]]; then
    echo "ERROR: Failed to download resources. Unexpected shebang";
    rm "$install_file_name_tmp" &> /dev/null; # Cleanup
    return 1;
  fi
  # Move the downloaded file to the target installation directory
  local install_resource="${install_path}/${INSTALL_BIN_NAME}";
  if ! mv "$install_file_name_tmp" "$install_resource"; then
    echo "ERROR: Failed to install resources under '${install_path}'";
    rm "$install_file_name_tmp" &> /dev/null; # Cleanup
    return 1;
  fi
  # Set owner and group
  local _user;
  _user="$(whoami)";
  if ! chown "${_user}":"${_user}" "$install_resource"; then
    echo "ERROR: Failed to set owner of resource '${install_resource}'";
    if [[ $pi_updated == false ]]; then
      rm "$install_resource" &> /dev/null; # Cleanup
    fi
    return 1;
  fi
  # Set file permissions
  if ! chmod 755 "$install_resource"; then
    echo "ERROR: Failed to set file permissions of '${install_resource}'";
    if [[ $pi_updated == false ]]; then
      rm "$install_resource" &> /dev/null; # Cleanup
    fi
    return 1;
  fi
  # Check command is available
  if ! command -v "$INSTALL_BIN_NAME" &> /dev/null; then
    echo "WARNING: The installation directory does not seem to be on your path:";
    echo "         '${install_path}'";
    echo "WARNING: Could not find command '${INSTALL_BIN_NAME}'";
    echo "WARNING: Please make sure that the installation directory is on your path.";
    if [[ ${_INSTALLATION_DIR_CREATED} == true ]]; then
      if (( _EUID != 0 )); then
        if [ -n "$HOME" ] && [ -f "${HOME}/.profile" ]; then
          echo "Hint: You could try to source your shell startup file. Found '~/.profile'";
        fi
      fi
    fi
  fi
  # Finished
  if [[ $pi_updated == true ]]; then
    echo "Update successful";
  else
    echo "Installation successful";
  fi
  return 0;
}

# Uninstalls the Project Init system.
#
# Returns:
# 0  - If, and only if, the system was correctly uninstalled.
# nz - Non-zero otherwise.
#
function uninstall_project_init() {
  local question="Are you sure that you want to UNINSTALL the Project Init system? (y/N): ";
  if is_installed; then
    # Ask for confirmation unless '--yes' option was specified
    if [[ $ARG_ASSUME_YES == false ]]; then
      if ! confirm_action "$question"; then
        echo "Terminating...";
        return 1;
      fi
    fi
    # Check that file exists and can be removed
    if ! [ -w "$FOUND_INSTALLATION" ]; then
      echo "ERROR: Unable to remove installed file '${FOUND_INSTALLATION}'";
      if [ -f "$FOUND_INSTALLATION" ]; then
        echo "Do you have the necessary privileges?";
      fi
      return 1;
    fi
    # Remove installed file
    if ! rm "$FOUND_INSTALLATION"; then
      echo "ERROR: Failed to remove file '${FOUND_INSTALLATION}'";
      return 1;
    fi
    echo "Successfully uninstalled";
    return 0;
  else
    echo "The Project Init system does not seem to be installed";
  fi
  return 1;
}

function main() {
  # Parse arguments
  parse_args "$@";

  # Prepare installation path
  local install_path="";
  if (( _EUID == 0 )); then
    install_path="$INSTALL_PATH_SYSTEM";
  else
    if [ -z "$HOME" ]; then
      echo "ERROR: Environment variable 'HOME' is not set.";
      return 1;
    fi
    install_path="${HOME}/${INSTALL_PATH_USER}";
    if ! [ -d "$install_path" ]; then
      # Create user-wide installation directory
      if ! mkdir -p "$install_path"; then
        echo "ERROR: Failed to create user-wide installation directory '${install_path}'";
        return 1;
      fi
      _INSTALLATION_DIR_CREATED=true;
    fi
  fi

  # Execute either install or uninstall action
  if [[ $ARG_UNINSTALL == true ]]; then
    uninstall_project_init;
  else
    install_project_init "$install_path";
  fi
  return $?;
}

main "$@";
