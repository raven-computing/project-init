#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [--analyze]     Enable static source code analysis checks by the compiler.
                  This can slow down compilation time significantly.

  [--clean]       Remove all build-related directories and files and then exit.

  [--config]      Only execute the build configuration step. This option will skip
                  the build step.

  [--coverage]    Enable code coverage instrumentation. Should only be used with debug builds.

  [--debug]       Build the libraries with debug symbols and with
                  optimizations turned off.
${{VAR_SCRIPT_BUILD_DOCS_OPT}}

  [--ignore-warnings]
                  Ignore all compiler warnings during the build process. Warning messages
                  may still be shown, but will not cause the build to fail.
${{VAR_SCRIPT_BUILD_ISOLATED_OPT}}

  [--sanitizers]  Use sanitizers when building and running.

  [--shared]      Build shared libraries instead of static libraries.

  [--skip-config] Skip the build configuration step. If the build tree does not
                  exist yet, then this option has no effect and the build
                  configuration step is executed.

  [--skip-tests]  Do not build any tests.

  [-?|--help]     Show this help message.
EOS
)

# Arg flags
ARG_ANALYZE=false;
ARG_CLEAN=false;
ARG_CONFIG=false;
ARG_COVERAGE=false;
ARG_SANITIZERS=false;
ARG_SHARED=false;
ARG_DEBUG=false;
${{VAR_SCRIPT_BUILD_DOCS_ARGFLAG}}
ARG_IGNORE_WARNINGS=false;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
ARG_SKIP_CONFIG=false;
ARG_SKIP_TESTS=false;
ARG_SHOW_HELP=false;

${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY}}

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --analyze)
    ARG_ANALYZE=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --clean)
    ARG_CLEAN=true;
    shift
    ;;
    --config)
    ARG_CONFIG=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --coverage)
    ARG_COVERAGE=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --sanitizers)
    ARG_SANITIZERS=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --shared)
    ARG_SHARED=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --debug)
    ARG_DEBUG=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
    --ignore-warnings)
    ARG_IGNORE_WARNINGS=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
${{VAR_SCRIPT_BUILD_DOCS_ARGPARSE}}
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

if [[ $ARG_DEBUG == true ]]; then
  BUILD_CONFIGURATION="Debug";
fi

BUILD_TESTS="ON";
IGNORE_WARNINGS="OFF";
BUILD_ANALYZE="OFF";
BUILD_WITH_SANITIZERS="OFF";
BUILD_WITH_COVERAGE="OFF";

if [[ $ARG_IGNORE_WARNINGS == true ]]; then
  IGNORE_WARNINGS="ON";
fi
if [[ $ARG_ANALYZE == true ]]; then
  BUILD_ANALYZE="ON";
fi
if [[ $ARG_SKIP_TESTS == true ]]; then
  BUILD_TESTS="OFF";
fi
if [[ $ARG_SANITIZERS == true ]]; then
  BUILD_WITH_SANITIZERS="ON";
fi

BUILD_SHARED_LIBS="OFF";

if [[ $ARG_SHARED == true ]]; then
  BUILD_SHARED_LIBS="ON";
fi
if [[ $ARG_COVERAGE == true ]]; then
  BUILD_WITH_COVERAGE="ON";
  if [[ $ARG_SKIP_TESTS == true ]]; then
    echo "Warning: Unable to automatically generate test coverage reports" \
         "when test builds are skipped";
  fi
fi

# CMake: Configure
if [[ $ARG_SKIP_CONFIG == false ]]; then
  cmake -DCMAKE_BUILD_TYPE="$BUILD_CONFIGURATION" \
        -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
        -D${{VAR_PROJECT_NAME_UPPER}}_IGNORE_WARNINGS="$IGNORE_WARNINGS" \
        -D${{VAR_PROJECT_NAME_UPPER}}_SOURCE_ANALYSIS="$BUILD_ANALYZE" \
        -D${{VAR_PROJECT_NAME_UPPER}}_BUILD_TESTS="$BUILD_TESTS" \
        -D${{VAR_PROJECT_NAME_UPPER}}_BUILD_SHARED_LIBS="$BUILD_SHARED_LIBS" \
        -D${{VAR_PROJECT_NAME_UPPER}}_USE_SANITIZERS="$BUILD_WITH_SANITIZERS" \
        -D${{VAR_PROJECT_NAME_UPPER}}_BUILD_TEST_COVERAGE="$BUILD_WITH_COVERAGE" ..;

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
