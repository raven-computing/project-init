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
_PROJECT_SRC_PACKAGE_MAIN=".";

# The array of Odoo modules in this project
ODOO_MODULES=();

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

function find_odoo_modules() {
  local module_dir="";
  local odoo_module="";
  for module_dir in $(find . -maxdepth 2 -type f -name '__manifest__.py'); do
    odoo_module="$(dirname $module_dir)";
    odoo_module="$(basename $odoo_module)";
    ODOO_MODULES+=("$odoo_module");
  done
}
