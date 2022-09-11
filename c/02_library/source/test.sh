#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [-?|--help] Show this help message.
EOS
)

# Arg flags
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
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

if ! [ -d "build" ]; then
  # Build the tests first
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
