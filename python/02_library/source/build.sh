#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds distribution packages for the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [--clean]         Remove the build data and related files and then exit.
${{VAR_SCRIPT_BUILD_ISOLATED_OPT}}

  [--no-virtualenv] Do not use a virtual environment for the build.

  [--skip-tests]    Do not run unit tests.

  [-?|--help]       Show this help message.
EOS
)

# Arg flags
ARG_CLEAN=false;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
ARG_NO_VIRTUALENV=false;
ARG_SKIP_TESTS=false;
ARG_SHOW_HELP=false;

${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY}}

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --clean)
    ARG_CLEAN=true;
    shift
    ;;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGPARSE}}
    --no-virtualenv)
    ARG_NO_VIRTUALENV=true;
    shift
    ;;
    --skip-tests)
    ARG_SKIP_TESTS=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
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
    echo "Run 'build.sh --help' for more information";
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

# Check clean flag
if [[ $ARG_CLEAN == true ]]; then
  if [ -d "build" ]; then
    rm -r "build";
  fi
  if [ -d "dist" ]; then
    rm -r "dist";
  fi
  if [ -d *.egg-info ]; then
    rm -r *.egg-info;
  fi
  logI "Removed build data";
  exit 0;
fi

${{VAR_SCRIPT_BUILD_ISOLATED_MAIN}}

if [[ $ARG_NO_VIRTUALENV == false ]]; then
  # Setup and activate virtual environment
  if ! setup_virtual_env; then
    exit 1;
  fi
fi

# Check skip-tests flag
if [[ $ARG_SKIP_TESTS == false ]]; then
  # Execute the test script
  test_args="";
  if [[ $ARG_NO_VIRTUALENV == true ]]; then
    test_args="--no-virtualenv";
  fi
  bash test.sh $test_args;
  if (( $? != 0 )); then
    exit $?;
  fi
fi

logI "Building source and binary distribution packages";
${_PYTHON_EXEC} setup.py sdist bdist_wheel;
if (( $? != 0 )); then
  logE "Failed to build distribution packages";
  exit 1;
fi
logI "Build successful";
