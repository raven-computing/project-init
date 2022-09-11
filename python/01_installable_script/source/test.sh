#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} program.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} program.

${USAGE}

Options:

${{VAR_SCRIPT_TEST_LINT_HELP}}

  [-?|--help] Show this help message.
EOS
)

# Arg flags
${{VAR_SCRIPT_TEST_LINT_ARG}}
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
${{VAR_SCRIPT_TEST_LINT_ARG_PARSE}}
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

# Source setup script
if ! source "setup.sh"; then
  exit 1;
fi
${{VAR_SCRIPT_TEST_LINT_CODE}}

logI "Running unit tests";
${_PYTHON_EXEC} -m unittest;
if (( $? != 0 )); then
  logE "Tests have failed";
  exit 1;
fi
logI "All unit tests have passed";
