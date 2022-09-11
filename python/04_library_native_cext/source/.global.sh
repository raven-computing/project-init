#!/bin/bash
# ---------------------------------------------------------------------------- #
#                  Global configuration values and functions                   #
# ---------------------------------------------------------------------------- #


# Virtual environment name
_VIRTENV_NAME="${{VAR_PROJECT_VIRTENV_NAME}}";

# Python executable
_PYTHON_EXEC="python";

# PIP executable
_PIP_EXEC="pip";

# Name of the main lib Python package
_PROJECT_SRC_PACKAGE_MAIN="${{VAR_NAMESPACE_DECLARATION_0}}";

# Terminal colors
_RED="\033[0;31m";
_GREEN="\033[0;32m";
_BLUE="\033[1;34m";
_ORANGE="\033[1;33m";
_NC="\033[0m";


# Print info level statement on stdout
function logI() {
  if [[ "$TERMINAL_USE_ANSI_COLORS" == "0" ]]; then
    echo "[INFO] $*";
  else
    echo -e "[${_BLUE}INFO${_NC}] $*";
  fi
}

# Print warning level statement on stdout
function logW() {
  if [[ "$TERMINAL_USE_ANSI_COLORS" == "0" ]]; then
    echo "[WARN] $*";
  else
    echo -e "[${_ORANGE}WARN${_NC}] $*";
  fi
}

# Print error level statement on stdout
function logE() {
  if [[ "$TERMINAL_USE_ANSI_COLORS" == "0" ]]; then
    echo "[ERROR] $*";
  else
    echo -e "[${_RED}ERROR${_NC}] $*";
  fi
}
