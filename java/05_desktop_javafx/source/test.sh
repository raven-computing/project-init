#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} desktop application.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} desktop application.

${USAGE}

Options:

  [--interactive] [args]
                  Starts the desktop application for interactive testing.
                  All optional arguments from [args] are passed to the application as one string.
                  If specified, this must be the last given option as all subsequent
                  arguments will be interpreted as being part of the [args] option argument.

  [-?|--help]     Show this help message.
EOS
)

# Arg flags
ARG_INTERACTIVE=false;
ARG_SHOW_HELP=false;

app_args=();

# Parse all arguments given to this script
for arg in "$@"; do
  if [[ $ARG_INTERACTIVE == true ]]; then
    app_args+=("$arg");
    continue;
  fi
  case $arg in
    --interactive)
    ARG_INTERACTIVE=true;
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

if ! command -v "mvn" &> /dev/null; then
  echo "ERROR: Could not find the 'mvn' executable.";
  echo "Please make sure that Maven is correctly installed";
  exit 1;
fi

if [[ $ARG_INTERACTIVE == true ]]; then
  if (( ${#app_args[@]} > 0 )); then
    app_args="${app_args[@]}";
    mvn javafx:run "-Dapp-args=${app_args}";
  else
    mvn javafx:run;
  fi
  exit $?;
fi

mvn test;
exit $?;
