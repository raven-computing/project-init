#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

${{VAR_SCRIPT_TEST_LINT_HELP}}

  [--pyx-ann] Generate the Cython HTML annotation files.

  [-?|--help] Show this help message.
EOS
)

# Arg flags
${{VAR_SCRIPT_TEST_LINT_ARG}}
ARG_ANNOTATE=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
${{VAR_SCRIPT_TEST_LINT_ARG_PARSE}}
    --pyx-ann)
    ARG_ANNOTATE=true;
    export CYTHON_BUILD_ANNOTATION="1";
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
${{VAR_SCRIPT_TEST_LINT_CODE}}

logI "Building tests";
${_PYTHON_EXEC} setup.py build;
if (( $? != 0 )); then
  logE "Failed to build tests with C extensions";
  exit 1;
fi

# Check the annotate argument
if [[ $ARG_ANNOTATE == true ]]; then
  logI "Cython annotations have been built. Check the build directory";
  exit 0;
fi

# Find the directory containing the built sources
build_lib_dir="$(find "build/" -type d -name 'lib.*')";
if [ -z "$build_lib_dir" ]; then
  logE "Could not find library build directory";
  exit 1;
fi

# Extract the platform identifying part of the string,
# e.g. 'linux-x86_64-3.8'
platform_suffix="${build_lib_dir:10}";
# Set the build directory where the tests will be put
build_tests_dir="build/tests.$platform_suffix";
if ! [ -d "$build_tests_dir" ]; then
  mkdir "$build_tests_dir";
  if (( $? != 0 )); then
    logE "Failed to create build tests directory";
    exit 1;
  fi
fi

# Copy all build files to the build tests directory
cp -r $build_lib_dir/* $build_tests_dir/;
if (( $? != 0 )); then
  logE "Failed to copy build files to tests directory";
  exit 1;
fi

# Copy all test source files to the build tests directory
cp -r "tests/" "$build_tests_dir/";
if (( $? != 0 )); then
  logE "Failed to copy test source files to build directory";
  exit 1;
fi

# We want to run our tests like if we had pure Python modules,
# so we get the exact same environment conditions during the tests
# compared to when the project is installed.
cd "$build_tests_dir";

logI "Running unit tests";
${_PYTHON_EXEC} -m unittest;
if (( $? != 0 )); then
  logE "Tests have failed";
  exit 1;
fi
logI "All unit tests have passed";
