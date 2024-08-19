#!/bin/bash
# Setup script for the ${{VAR_PROJECT_NAME}} project.
# This script will create and initialize a virtual environment
# for the project and set up the python path for you.

function __b_in_subshell() {
  if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
    echo "0";
  else
    echo "1";
  fi
}

function __b_confirm_setup() {
  local answer="";
  logI "The virtual environment for this project is not set up.";
  logI "Would you like to create the '${_VIRTENV_NAME}' virtual environment";
  logI "and install all needed dependencies? (y/N)";
  read -p "[INPUT] " answer;
  # Validate answer
  if [ -z "$answer" ]; then
    return 1;
  fi
  case "$answer" in
    1|YES|yes|Yes|Y|y|true|True)
    return 0;
    ;;
    0|NO|no|No|N|n|false|False)
    return 1;
    ;;
    *)
    logE "Invalid input";
    return 1;
    ;;
  esac
}

function setup_virtual_env() {
  # Check for prerequisites
  local virtualenvwrapper_script="$(which virtualenvwrapper.sh)";
  if [ -z "$virtualenvwrapper_script" ]; then
    if [ -n "$VIRTUALENVWRAPPER_SCRIPT" ] && [ -r "$VIRTUALENVWRAPPER_SCRIPT" ]; then
      virtualenvwrapper_script="$VIRTUALENVWRAPPER_SCRIPT";
    else
      logE "Could not find the virtualenvwrapper utility.";
      logE "The setup.sh script requires that the virtualenvwrapper shell functions are available.";
      logE "Please see the following documentation on how to install virtualenvwrapper:";
      logE "https://virtualenvwrapper.readthedocs.io/en/latest/install.html";
      return 1;
    fi
  fi

  # Make sure the shell functions from the wrapper are available
  source "$virtualenvwrapper_script";

  # Ensure the required executables can be found
  if ! command -v "${_PYTHON_EXEC}" &> /dev/null; then
    logE "Could not find Python executable '${_PYTHON_EXEC}'";
    return 1;
  fi

  if ! command -v "${_PIP_EXEC}" &> /dev/null; then
    logE "Could not find PIP executable '${_PIP_EXEC}'";
    return 1;
  fi

  # Ensure that global vars are set
  if [ -z "${_VIRTENV_NAME}" ]; then
    logE "Virtual environment name not set." \
        "Please set variable '_VIRTENV_NAME' in .global.sh file";
    return 1;
  fi

  # Check if virtual environment is already active
  if [ -n "$VIRTUAL_ENV" ]; then
    # Check if the active env is the target env
    if [[ "$(basename "$VIRTUAL_ENV")" == "${_VIRTENV_NAME}" ]]; then
      # Environment is already active
      return 0;
    fi
    # A different environment is already active
    logW "A virtual environment is already active: '$VIRTUAL_ENV'";
    logW "Exit active virtual environment and try again";
    return 1;
  fi

  # Check if a virtual environment with the same name already exists
  if [ -n "$(lsvirtualenv -b |grep ${_VIRTENV_NAME})" ]; then
    # Environment is already set up, so we simply switch to it
    if ! workon "${_VIRTENV_NAME}"; then
      logE "Failed to switch to virtual environment '${_VIRTENV_NAME}'";
      return 1;
    fi
    # Successfully switched to environment
    return 0;
  fi

  __b_confirm_setup;
  if (( $? != 0 )); then
    logI "Abort";
    return 1;
  fi

  # Create the virtual environment
  logI "Creating virtual environment '${_VIRTENV_NAME}'"
  if ! mkvirtualenv "${_VIRTENV_NAME}"; then
    logE "Failed to create virtual environment.";
    logE "Function mkvirtualenv() returned non-zero exit status";
    return 1;
  fi

  # Ensure the created virtual environment is active
  if [ -z "$VIRTUAL_ENV" ]; then
    if ! workon "${_VIRTENV_NAME}"; then
      logE "Failed to switch to virtual environment '${_VIRTENV_NAME}'";
      # Remove virtual environment
      rmvirtualenv "${_VIRTENV_NAME}";
      return 1;
    fi
  fi

  # Install python dependencies
  if [ -r "requirements.txt" ]; then
    logI "Installing Python dependencies";
    ${_PIP_EXEC} install -r requirements.txt;
    if (( $? != 0 )); then
      logE "Failed to install Python dependencies";
      # Exit and remove virtual environment
      deactivate && rmvirtualenv "${_VIRTENV_NAME}";
      return 1;
    fi
  fi

  # Add values from pythonpath file
  if [ -r ".pythonpath" ]; then
    local pypath="";
    while read -r line; do
      # Ignore comments
      if [[ ! "$line" == \#* ]]; then
        # Substitude variables
        pypath=$(echo "$line" |envsubst);
        logI "Adding '$pypath' to python path";
        if ! add2virtualenv "$pypath"; then
          logE "Failed to modify python path.";
          logE "Function add2virtualenv() returned non-zero exit status";
          # Exit and remove virtual environment
          deactivate && rmvirtualenv "${_VIRTENV_NAME}";
          return 1;
        fi
      fi
    done < ".pythonpath";
  fi
  logI "Setup completed";
  return 0;
}

# Source configurations
if ! source ".global.sh"; then
  echo "ERROR: Failed to source globals.";
  echo "Are you in the project root directory?";
  exit 1;
fi

# Determine whether this script is sourced or executed in a subshell
if [[ $(__b_in_subshell) == "1" ]]; then
  logE "Please run this script by sourcing it";
  exit 1;
fi

# Automatically activate the virtual env unless this
# behaviour is suppressed by specifying the env var
if [[ "$SETUPSH_VIRTUALENV_AUTO_ACTIVATE" != "0" ]]; then
  setup_virtual_env;
fi

