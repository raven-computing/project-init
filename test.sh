#!/bin/bash
# Test script for the Project Init system.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the Project Init system.

${USAGE}

Run this script to perform compatibility tests for the Project Init
code on the underlying system.

Options:

  [--check-bash] Only check compatibility of the available Bash interpreter.

  [-?|--help]    Show this help message.
EOS
)

# Global constants

# Arg flags
ARG_CHECK_BASH=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --check-bash)
    ARG_CHECK_BASH=true;
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

test_result=0;

bash "tests/bash_tests.sh";
test_result=$?;

if (( $test_result == 0 )); then
  if [[ $ARG_CHECK_BASH == false ]]; then
    bash "tests/compatibility_tests.sh";
    test_result=$?;
  fi
fi

exit $test_result;
