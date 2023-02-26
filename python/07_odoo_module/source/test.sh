#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:
  [--interactive]   [ARGS]
                    Starts an Odoo instance for interactive testing.
                    All optional arguments from [ARGS] are passed to the Odoo executable as is.

  [--isolated]      Run isolated tests inside a Docker container.

  [--no-virtualenv] Do not use a virtual environment for the tests.

  [-?|--help]       Show this help message.
EOS
)

# Arg flags
ARG_INTERACTIVE=false;
ARG_ISOLATED=false;
ARG_NO_VIRTUALENV=false;
ARG_SHOW_HELP=false;

# Array of arguments passed through to an isolated run.
# Should be set in arg-parse loop below.
ARGS_ISOLATED=();

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --interactive)
    ARG_INTERACTIVE=true;
    ARGS_ISOLATED+=($arg);
    shift
    ;;
    --isolated)
    ARG_ISOLATED=true;
    # When running in an isolated container,
    # we don't need additional virtual envs
    ARGS_ISOLATED+=(--no-virtualenv);
    shift
    ;;
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

    # TODO: Allow specification of arbitrary args when using --interactive opt
    # and pass those to the odoo exec
    # ARGS_ISOLATED+=($arg);
    ;;
  esac
done

# Check if help is triggered
if [[ $ARG_SHOW_HELP == true ]]; then
  echo "$HELP_TEXT";
  exit 0;
fi

# Source setup script
if ! source "setup.sh"; then
  exit 1;
fi

if [[ $ARG_ISOLATED == true ]]; then
  source ".docker/controls.sh";
  run_isolated_tests "${ARGS_ISOLATED[@]}";
  exit $?;
fi

if [[ $ARG_NO_VIRTUALENV == false ]]; then
  # Setup and activate virtual environment
  if ! setup_virtual_env; then
    exit 1;
  fi
fi

if [[ $ARG_INTERACTIVE == true ]]; then
  if ! command -v "odoo" &> /dev/null; then
    logE "Could not find the 'odoo' executable.";
    logE "To interactively test, please correctly install Odoo on your system";
    logE "or try with the '--isolated' option to test with Docker containers.";
    exit 1;
  fi
  odoo;
  exit $?;
fi

find_odoo_modules;
for odoo_module in ${ODOO_MODULES[@]}; do
  logI "Running unit tests for module '$odoo_module'";
  ${_PYTHON_EXEC} -m unittest discover --start-directory $odoo_module/tests;
  if (( $? != 0 )); then
    logE "Tests have failed for module '$odoo_module'";
    exit 1;
  fi
done
logI "All unit tests have passed";
exit 0;
