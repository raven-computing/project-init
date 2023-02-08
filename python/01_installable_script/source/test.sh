#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} program.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} program.

${USAGE}

Options:
${{VAR_SCRIPT_TEST_ISOLATED_OPT}}

  [--lint]          Perform static code analysis with a linter.

  [--no-virtualenv] Do not use a virtual environment for the tests.

  [-?|--help]       Show this help message.
EOS
)

# Arg flags
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
ARG_LINT=false;
ARG_NO_VIRTUALENV=false;
ARG_SHOW_HELP=false;

${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY}}

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
${{VAR_SCRIPT_BUILD_ISOLATED_ARGPARSE}}
    --lint)
    ARG_LINT=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --no-virtualenv)
    ARG_NO_VIRTUALENV=true;
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

# Source setup script
if ! source "setup.sh"; then
  exit 1;
fi

${{VAR_SCRIPT_TEST_ISOLATED_MAIN}}

if [[ $ARG_NO_VIRTUALENV == false ]]; then
  # Setup and activate virtual environment
  if ! setup_virtual_env; then
    exit 1;
  fi
fi

# Check linter flag
if [[ $ARG_LINT == true ]]; then
  if ! command -v "pylint" &> /dev/null; then
    logE "Could not find requirement 'pylint'";
    exit 1;
  fi
  logI "Performing static code analysis";
  # Add project root to sys.path. Needed for namespace packages
  pylint --init-hook="sys.path.append('.')" "$_PROJECT_SRC_PACKAGE_MAIN";
  exit 0;
fi

logI "Running unit tests";
${_PYTHON_EXEC} -m unittest;
if (( $? != 0 )); then
  logE "Tests have failed";
  exit 1;
fi
logI "All unit tests have passed";
