#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} application.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds the ${{VAR_PROJECT_NAME}} application.

${USAGE}

Options:

  [--clean]       Remove all build-related directories and files and then exit.

  [--config]      Only execute the build configuration step. This option will skip
                  the build step.

  [--debug]       Build the application with debug symbols and with
                  optimizations turned off.
${{VAR_SCRIPT_BUILD_DOCS_OPT}}
${{VAR_SCRIPT_BUILD_ISOLATED_OPT}}

  [--sanitizers]  Use sanitizers when building and running.

  [--skip-config] Skip the build configuration step. If the build tree does not
                  exist yet, then this option has no effect and the build
                  configuration step is executed.

  [--skip-tests]  Do not build any tests.

  [-?|--help]     Show this help message.
EOS
)

# Arg flags
ARG_CLEAN=false;
ARG_CONFIG=false;
ARG_DEBUG=false;
${{VAR_SCRIPT_BUILD_DOCS_ARGFLAG}}
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
ARG_SANITIZERS=false;
ARG_SKIP_CONFIG=false;
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
    --config)
    ARG_CONFIG=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --debug)
    ARG_DEBUG=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
${{VAR_SCRIPT_BUILD_DOCS_ARGPARSE}}
    --sanitizers)
    ARG_SANITIZERS=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --skip-config)
    ARG_SKIP_CONFIG=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --skip-tests)
    ARG_SKIP_TESTS=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
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

if [[ $ARG_CONFIG == true && $ARG_SKIP_CONFIG == true ]]; then
  echo "Cannot specify both --config and --skip-config options";
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

${{VAR_SCRIPT_BUILD_ISOLATED_MAIN}}

${{VAR_SCRIPT_BUILD_DOCS_MAIN}}

# Ensure the required executable is available
if ! command -v "cmake" &> /dev/null; then
  echo "ERROR: Could not find the 'cmake' executable.";
  echo "Please make sure that CMake is correctly installed";
${{VAR_SCRIPT_BUILD_ISOLATED_HINT1}}
  exit 1;
fi

cd "build";

BUILD_CONFIGURATION="Release";
BUILD_WITH_SANITIZERS="OFF";

if [[ $ARG_DEBUG == true ]]; then
  BUILD_CONFIGURATION="Debug";
fi

BUILD_TESTS="ON";

if [[ $ARG_SKIP_TESTS == true ]]; then
  BUILD_TESTS="OFF";
fi
if [[ $ARG_SANITIZERS == true ]]; then
  BUILD_WITH_SANITIZERS="ON";
fi

# CMake: Configure
if [[ $ARG_SKIP_CONFIG == false ]]; then
  cmake -DCMAKE_BUILD_TYPE="$BUILD_CONFIGURATION" \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -D${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS="$BUILD_TESTS" \
        -D${{VAR_PROJECT_NAME_UPPER}}_USE_SANITIZERS="$BUILD_WITH_SANITIZERS" ..;

  config_status=$?;
  if (( config_status != 0 )); then
    exit $config_status;
  fi
  if [[ $ARG_CONFIG == true ]]; then
    exit $config_status;
  fi
fi

CMAKE_CONFIG_ARG="";
if [[ $ARG_SKIP_CONFIG == false ]]; then
  CMAKE_CONFIG_ARG="--config $BUILD_CONFIGURATION";
fi

# CMake: Build
cmake --build . $CMAKE_CONFIG_ARG;
exit $?;
