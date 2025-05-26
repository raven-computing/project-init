#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} server application.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} server application.

${USAGE}

Options:

  [--interactive]   [args]
                    Starts the server application for interactive testing.
                    All optional arguments from [args] are passed to the application as is.
                    If specified, this must be the last given option as all subsequent
                    arguments will be interpreted as being part of the [args] option argument.
${{VAR_SCRIPT_TEST_ISOLATED_OPT}}

${{VAR_SCRIPT_TEST_LINT_HELP}}

  [--no-virtualenv] Do not use a virtual environment for the tests.

  [-?|--help]       Show this help message.
EOS
)

# Arg flags
ARG_INTERACTIVE=false;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
${{VAR_SCRIPT_TEST_LINT_ARG}}
ARG_NO_VIRTUALENV=false;
ARG_SHOW_HELP=false;

app_args=();

${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY}}

# Parse all arguments given to this script
for arg in "$@"; do
  if [[ $ARG_INTERACTIVE == true ]]; then
    app_args+=("$arg");
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    continue;
  fi
  case $arg in
    --interactive)
    ARG_INTERACTIVE=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGPARSE}}
${{VAR_SCRIPT_TEST_LINT_ARG_PARSE}}
    --no-virtualenv)
    ARG_NO_VIRTUALENV=true;
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

# Source setup script
PROJECT_VIRTUALENV_AUTO_ACTIVATE="0";
if ! source "setup.sh"; then
  exit 1;
fi

${{VAR_SCRIPT_TEST_ISOLATED_MAIN}}

if [[ $ARG_NO_VIRTUALENV == false ]]; then
  # Setup and activate virtual environment
  if ! project_setup_virtual_env; then
    exit 1;
  fi
fi

if [[ $ARG_INTERACTIVE == true ]]; then
  python -m ${{VAR_NAMESPACE_DECLARATION}} ${app_args[@]};
  exit $?;
fi

${{VAR_SCRIPT_TEST_LINT_CODE}}

logI "Running unit tests";
${_PYTHON_EXEC} -m unittest;
if (( $? != 0 )); then
  logE "Tests have failed";
  exit 1;
fi
logI "All unit tests have passed";
