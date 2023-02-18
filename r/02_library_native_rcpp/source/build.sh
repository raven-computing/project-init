#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [--clean]      Remove all build-related directories and files and then exit.

  [--docs]       Build the documentation and then exit.

  [--skip-tests] Do not run any tests.

  [-?|--help]    Show this help message.
EOS
)

# Arg flags
ARG_CLEAN=false;
ARG_DOCS=false;
ARG_SKIP_TESTS=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --clean)
    ARG_CLEAN=true;
    shift
    ;;
    --docs)
    ARG_DOCS=true;
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

# Source configurations
if ! source ".global.sh"; then
  echo "ERROR: Failed to source globals.";
  echo "Are you in the project root directory?";
  exit 1;
fi

# Check clean flag
if [[ $ARG_CLEAN == true ]]; then
  if [ -d "build" ]; then
    rm -rf "build";
  fi
  # Remove compiled files
  run_R_cmd "clean_dll()";
  exit 0;
fi

if ! [ -d "build" ]; then
  mkdir "build";
fi

# Ensure the required executable is available
if ! command -v "Rscript" &> /dev/null; then
  logE "ERROR: Could not find the 'Rscript' executable.";
  logE "Please make sure that R is correctly installed";
  exit 1;
fi

function build_docs() {
  logI "Building documentation";
  run_R_cmd "document()";
  if (( $? != 0)); then
    logE "Failed to build documentation";
    return 1;
  fi
  return 0;
}

# Generate code bindings with Rcpp
logI "Generating C++ bindings";
run_R_cmd "compileAttributes()";
if (( $? != 0 )); then
  logE "Failed to generate C++ bindings";
  exit 1;
fi

# Check docs flag
if [[ $ARG_DOCS == true ]]; then
  build_docs;
  exit $?;
fi

# Compile and check if code can be loaded
logI "Compiling and loading code";
run_R_cmd "load_all()";
if (( $? != 0 )); then
  build_status=$?;
  logE "Failed to load package code";
  exit $build_status;
fi

if ! build_docs; then
  exit 1;
fi

# Check skip-tests flag
if [[ $ARG_SKIP_TESTS == false ]]; then
  # Execute the test script
  bash test.sh;
  if (( $? != 0 )); then
    exit $?;
  fi
fi

# Build
logI "Creating distribution packages";

logI "Building source distribution package";
run_R_cmd "build(path='build', binary=FALSE)";
if (( $? != 0 )); then
  build_status=$?;
  logE "Failed to build distribution package";
  exit $build_status;
fi

logI "Building binary distribution package";
run_R_cmd "build(path='build', binary=TRUE)";
if (( $? != 0 )); then
  build_status=$?;
  logE "Failed to build distribution package";
  exit $build_status;
fi

logI "Build succcessful";
exit 0;

