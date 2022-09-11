#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [--clean]             Remove all build-related directories and files and then exit.

  [--no-native]         Do not build native shared libraries.

  [--skip-tests]        Do not build and run any tests.

  [--skip-native-tests] Do not run native tests. This option has no effect on Java-based tests,
                        even for those that rely on native code being available.

  [-?|--help]           Show this help message.
EOS
)

# Arg flags
ARG_CLEAN=false;
ARG_NO_NATIVE=false;
ARG_SKIP_TESTS=false;
ARG_SKIP_NATIVE_TESTS=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --clean)
    ARG_CLEAN=true;
    shift
    ;;
    --no-native)
    ARG_NO_NATIVE=true;
    shift
    ;;
    --skip-tests)
    ARG_SKIP_TESTS=true;
    shift
    ;;
    --skip-native-tests)
    ARG_SKIP_NATIVE_TESTS=true;
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

# Ensure the required executable is available
if ! command -v "mvn" &> /dev/null; then
  echo "ERROR: Could not find the 'mvn' executable.";
  echo "ERROR: Please make sure that Maven is correctly installed";
  exit 1;
fi

# Arguments passed to Maven
cmd_mvn_args="";

# Check clean flag
if [[ $ARG_CLEAN == true ]]; then
  mvn "clean";
  exit $?;
fi

# Check build flags
if [[ $ARG_NO_NATIVE == false ]]; then
  cmd_mvn_args="${cmd_mvn_args} -DbuildNativeLibs=true";
  if ! command -v "cmake" &> /dev/null; then
    echo "ERROR: Could not find the 'cmake' executable.";
    echo "ERROR: Please make sure that CMake is correctly installed";
    exit 1;
  fi
fi

if [[ $ARG_SKIP_TESTS == true ]]; then
  cmd_mvn_args="${cmd_mvn_args} -Dmaven.test.skip=true";
else
  if [[ $ARG_SKIP_NATIVE_TESTS == false ]]; then
    cmd_mvn_args="${cmd_mvn_args} -DtestNativeLibs=true";
    if ! command -v "ctest" &> /dev/null; then
      echo "ERROR: Could not find the 'ctest' executable.";
      echo "ERROR: Please make sure that CMake and CTest are correctly installed";
      exit 1;
    fi
  fi
fi

# Call Maven
mvn "package" ${cmd_mvn_args};
exit $?;
