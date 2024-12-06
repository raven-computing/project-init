#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} Odoo module project.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} Odoo modules.

${USAGE}

Options:

  [--interactive]   [args]
                    Starts an Odoo instance for interactive testing.
                    All optional arguments from [args] are passed to the Odoo executable as is.
                    If specified, this must be the last given option as all subsequent
                    arguments will be interpreted as being part of the [args] option argument.
${{VAR_SCRIPT_TEST_ISOLATED_OPT}}

  [--no-virtualenv] Do not use a virtual environment for the tests.

  [-?|--help]       Show this help message.
EOS
)

# Arg flags
ARG_INTERACTIVE=false;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
ARG_NO_VIRTUALENV=false;
ARG_SHOW_HELP=false;

odoo_args=();

${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY}}

# Parse all arguments given to this script
for arg in "$@"; do
  if [[ $ARG_INTERACTIVE == true ]]; then
    odoo_args+=("$arg");
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
  if ! setup_virtual_env; then
    exit 1;
  fi
fi

if [[ $ARG_INTERACTIVE == true ]]; then
  if ! command -v "odoo" &> /dev/null; then
    logE "Could not find the 'odoo' executable.";
    logE "To interactively test, please correctly install Odoo on your system";
${{VAR_SCRIPT_TEST_ISOLATED_HINT1}}
    exit 1;
  fi
  odoo ${odoo_args[@]};
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
