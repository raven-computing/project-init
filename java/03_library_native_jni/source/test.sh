#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:
${{VAR_SCRIPT_TEST_ISOLATED_OPT}}

  [--native]      Only run tests for native shared libraries (using CTest).

  [--skip-jni]    Do not run Java-based tests that rely on JNI native methods.

  [--skip-native] Do not run native tests (using CTest). This option has no effect on
                  Java-based tests, even for those that rely on native code being available.

  [-?|--help]     Show this help message.
EOS
)

# Arg flags
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
ARG_NATIVE=false;
ARG_SKIP_JNI=false;
ARG_SKIP_NATIVE=false;
ARG_SHOW_HELP=false;

${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY}}

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
${{VAR_SCRIPT_BUILD_ISOLATED_ARGPARSE}}
    --native)
    ARG_NATIVE=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --skip-jni)
    ARG_SKIP_JNI=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --skip-native)
    ARG_SKIP_NATIVE=true;
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
if [[ $ARG_NATIVE == true || $ARG_SKIP_NATIVE == false ]]; then
  if ! command -v "ctest" &> /dev/null; then
    echo "ERROR: Could not find the 'ctest' executable.";
    echo "Please make sure that CMake and CTest are correctly installed";
    exit 1;
  fi
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

if [[ $ARG_NATIVE == true ]]; then
  cd "build";
  # By default, GTest does not use colourful output when logging
  # the test results to a file. But as we also show the tests
  # in a terminal, we explicitly activate colourful output.
  export GTEST_COLOR=1;
  # Run tests with CTest
  ctest --output-on-failure;
  exit $?;
fi

# Arguments passed to Maven
cmd_mvn_args="";

if [[ $ARG_SKIP_JNI == false ]]; then
  cmd_mvn_args="${cmd_mvn_args} -DbuildNativeLibs=true";
fi

if [[ $ARG_SKIP_NATIVE == false ]]; then
  cmd_mvn_args="${cmd_mvn_args} -DtestNativeLibs=true";
fi

# Call Maven
mvn "test" ${cmd_mvn_args};
exit $?;
