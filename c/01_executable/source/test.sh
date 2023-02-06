#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} application.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} application.

${USAGE}

Options:
${{VAR_SCRIPT_TEST_ISOLATED_OPT}}

  [-?|--help]  Show this help message.
EOS
)

# Arg flags
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
ARG_SHOW_HELP=false;

${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY}}

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
${{VAR_SCRIPT_BUILD_ISOLATED_ARGPARSE}}
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

# Need to prematurely create the build dir if it does not exist
# so it can be used as a volume by Docker when using
# an isolated test execution
if ! [ -d "build" ]; then
  mkdir "build";
fi

${{VAR_SCRIPT_TEST_ISOLATED_MAIN}}

# Ensure the required executables are available
if ! command -v "cmake" &> /dev/null; then
  echo "ERROR: Could not find the 'cmake' executable.";
  echo "ERROR: Please make sure that CMake is correctly installed";
  exit 1;
fi
if ! command -v "ctest" &> /dev/null; then
  echo "ERROR: Could not find the 'ctest' executable.";
  echo "ERROR: Please make sure that CMake and CTest are correctly installed";
  exit 1;
fi

# Check if the build dir is empty
if [ -z "$(ls -A build)" ]; then
  # Build the tests first
  echo "Building project before test run execution";
  bash build.sh;
  if (( $? != 0 )); then
    exit $?;
  fi
fi

cd "build";
if (( $? != 0 )); then
  exit $?;
fi

# Run tests with CTest
ctest --output-on-failure;
exit $?;
