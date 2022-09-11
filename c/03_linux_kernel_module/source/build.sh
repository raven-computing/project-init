#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} kernel module.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds the ${{VAR_PROJECT_NAME}} kernel module.

${USAGE}

Options:

  [--clean]      Remove all build-related directories and files and then exit.

  [-?|--help]    Show this help message.
EOS
)

# Arg flags
ARG_CLEAN=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --clean)
    ARG_CLEAN=true;
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

# Ensure the required executable is available
if ! command -v "make" &> /dev/null; then
  echo "ERROR: Could not find the 'make' executable.";
  echo "ERROR: Please make sure that Make is correctly installed";
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

# Build
make;
exit $?;
