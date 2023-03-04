#!/bin/bash
# ---------------------------------------------------------------------------- #
#                  Global configuration values and functions                   #
# ---------------------------------------------------------------------------- #


# We need the functions from the devtools library
# available when we execute R commands
R_LIB_REQUIREMENTS=$(cat << EOS
library("devtools", quietly=TRUE);
library("testthat", warn.conflicts=FALSE);
library("Rcpp");
EOS
)

# Terminal colors
_RED="\033[0;31m";
_GREEN="\033[0;32m";
_BLUE="\033[1;34m";
_ORANGE="\033[1;33m";
_NC="\033[0m";


# Execute the provided R expressions through the Rscript command
function run_R_cmd() {
  Rscript -e "$R_LIB_REQUIREMENTS $*";
  return $?;
}

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
