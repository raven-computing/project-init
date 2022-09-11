#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} application.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds the ${{VAR_PROJECT_NAME}} application.

${USAGE}

Options:

  [--clean]       Remove all build-related directories and files and then exit.

  [--debug]       Build the application with debug symbols and with
                  optimizations turned off.

  [--shared-libs] Build dependencies as shared libraries.

  [--skip-tests]  Do not build any tests.

  [-?|--help]     Show this help message.
EOS
)

# Arg flags
ARG_CLEAN=false;
ARG_DEBUG=false;
ARG_SHARED_LIBS=false;
ARG_SKIP_TESTS=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --clean)
    ARG_CLEAN=true;
    shift
    ;;
    --debug)
    ARG_DEBUG=true;
    shift
    ;;
    --shared-libs)
    ARG_SHARED_LIBS=true;
    shift
    ;;
    --skip-tests)
    ARG_SKIP_TESTS=true;
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
if ! command -v "cmake" &> /dev/null; then
  echo "ERROR: Could not find the 'cmake' executable.";
  echo "ERROR: Please make sure that CMake is correctly installed";
  exit 1;
fi

# Check clean flag
if [[ $ARG_CLEAN == true ]]; then
  if [ -d "build" ]; then
    rm -rf "build";
  fi
  exit 0;
fi

if ! [ -d "build" ]; then
  mkdir "build";
fi

cd "build";

BUILD_CONFIGURATION="Release";

if [[ $ARG_DEBUG == true ]]; then
  BUILD_CONFIGURATION="Debug";
fi

BUILD_SHARED_LIBS="OFF";

if [[ $ARG_SHARED_LIBS == true ]]; then
  BUILD_SHARED_LIBS="ON";
fi

BUILD_TESTS="ON";

if [[ $ARG_SKIP_TESTS == true ]]; then
  BUILD_TESTS="OFF";
fi

# Configure
cmake -DCMAKE_BUILD_TYPE="$BUILD_CONFIGURATION" \
      -DBUILD_SHARED_LIBS="$BUILD_SHARED_LIBS" \
      -D${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS="$BUILD_TESTS" .. ;

if (( $? != 0 )); then
  exit $?;
fi

# Build
cmake --build . --config "$BUILD_CONFIGURATION";
exit $?;
