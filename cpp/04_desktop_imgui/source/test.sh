#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} application.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} application.

${USAGE}

Options:

  [-?|--help]  Show this help message.
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

# Need to prematurely create the build dir if it does not exist
# so it can be used as a volume by Docker when using
# an isolated test execution
if ! [ -d "build" ]; then
  mkdir "build";
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

BUILD_CONFIGURATION="";
# Determine the build configuration of the last build.
if [ -f "CMakeCache.txt" ]; then
  BUILD_CONFIGURATION="$(grep --max-count=1 CMAKE_BUILD_TYPE CMakeCache.txt \
                         | cut  --delimiter='=' --fields=2)";
fi

# By default, GTest does not use colourful output when logging
# the test results to a file. But as we also show the tests
# in a terminal, we explicitly activate colourful output.
export GTEST_COLOR=1;

# UB-Sanitizer options.
export UBSAN_OPTIONS="halt_on_error=1:print_stacktrace=1";

# Run tests with CTest
ctest --output-on-failure --build-config "$BUILD_CONFIGURATION";
exit $?;
