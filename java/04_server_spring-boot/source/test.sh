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

${{VAR_SCRIPT_TEST_ISOLATED_MAIN}}

# Ensure the required executable is available
if ! command -v "mvn" &> /dev/null; then
  echo "ERROR: Could not find the 'mvn' executable.";
  echo "Please make sure that Maven is correctly installed";
  exit 1;
fi

# Call Maven
mvn "test";
exit $?;
