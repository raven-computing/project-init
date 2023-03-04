#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [--check]    Perform distribution checks.

  [-?|--help]  Show this help message.
EOS
)

# Arg flags
ARG_CHECK=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --check)
    ARG_CHECK=true;
    shift
    ;;
    -\?|--help)
    ARG_SHOW_HELP=true;
    shift
    ;;
    *)
    # Unknown Argument
    echo "Unknown argument: '$arg'";
    echo "$USAGE";
    echo "";
    echo "Run 'test.sh --help' for more information";
    exit 1;
    ;;
  esac
done

# Check if help is triggered
if [[ $ARG_SHOW_HELP == true ]]; then
  echo "$HELP_TEXT";
  exit 0;
fi

# Source configurations
if ! source ".global.sh"; then
  echo "ERROR: Failed to source globals.";
  echo "Are you in the project root directory?";
  exit 1;
fi

# Ensure the required executable is available
if ! command -v "Rscript" &> /dev/null; then
  logE "ERROR: Could not find the 'Rscript' executable.";
  logE "Please make sure that R is correctly installed";
  exit 1;
fi

# Check flag
if [[ $ARG_CHECK == true ]]; then
  logI "Performing distribution checks";
  run_R_cmd "check()";
  exit $?;
fi

logI "Running unit tests";
run_R_cmd "test(stop_on_failure=TRUE)";
if (( $? != 0 )); then
  echo "";
  logE "Tests have failed";
  exit 1;
fi
echo "";
logI "All unit tests have passed";
exit 0;
