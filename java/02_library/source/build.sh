#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [--clean]      Remove all build-related directories and files and then exit.
${{VAR_SCRIPT_BUILD_ISOLATED_OPT}}

  [--skip-tests] Do not build and run any tests.

  [-?|--help]    Show this help message.
EOS
)

# Arg flags
ARG_CLEAN=false;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
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
${{VAR_SCRIPT_BUILD_ISOLATED_ARGPARSE}}
    --skip-tests)
    ARG_SKIP_TESTS=true;
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

# Check clean flag
if [[ $ARG_CLEAN == true ]]; then
  if [ -d "build" ]; then
    rm -rf "build";
  fi
  exit 0;
fi

${{VAR_SCRIPT_BUILD_ISOLATED_MAIN}}

# Ensure the required executable is available
if ! command -v "mvn" &> /dev/null; then
  echo "ERROR: Could not find the 'mvn' executable.";
  echo "Please make sure that Maven is correctly installed";
${{VAR_SCRIPT_BUILD_ISOLATED_HINT1}}
  exit 1;
fi

# Arguments passed to Maven
cmd_mvn_args="";

# Check build flags
if [[ "$ARG_SKIP_TESTS" == true ]]; then
  cmd_mvn_args="${cmd_mvn_args} -Dmaven.test.skip=true";
fi

# Call Maven
mvn "package" ${cmd_mvn_args};
exit $?;
