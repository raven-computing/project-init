#!/bin/bash
# Run script for the ${{VAR_PROJECT_NAME}} server application.

USAGE="Usage: run.sh [options]";

HELP_TEXT=$(cat << EOS
Runs the ${{VAR_PROJECT_NAME}} server application.

${USAGE}

Options:
${{VAR_SCRIPT_RUN_ISOLATED_OPT}}

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
    echo "Run 'run.sh --help' for more information";
    exit 1;
    ;;
  esac
done

# Check if help is triggered
if [[ $ARG_SHOW_HELP == true ]]; then
  echo "$HELP_TEXT";
  exit 0;
fi

${{VAR_SCRIPT_RUN_ISOLATED_MAIN}}

# Ensure the required executable is available
if ! command -v "node" &> /dev/null; then
  echo "ERROR: Could not find the 'node' executable.";
  echo "Please make sure that Node.js is correctly installed";
${{VAR_SCRIPT_RUN_ISOLATED_HINT1}}
  exit 1;
fi
if ! command -v "npm" &> /dev/null; then
  echo "ERROR: Could not find the 'npm' executable.";
  echo "Please make sure that NPM is correctly installed";
${{VAR_SCRIPT_RUN_ISOLATED_HINT1}}
  exit 1;
fi

if ! [ -d "node_modules" ]; then
  npm install;
fi

node "app.js";
