#!/bin/bash
# Release script for the ${{VAR_PROJECT_NAME}} library.
# This will release the source and binary distributions to PyPI.

USAGE="Usage: release.sh [options]";

HELP_TEXT=$(cat << EOS
Releases the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [--testpypi] Upload the build artifacts to the TestPyPI package index
               instead of the real index.

  [-?|--help]  Show this help message.
EOS
)

# Arg flags
ARG_TESTPYPI=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --testpypi)
    ARG_TESTPYPI=true;
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
    echo "Run 'release.sh --help' for more information";
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
if ! source "setup.sh"; then
  exit 1;
fi

# Dependencies
if ! command -v "twine" &> /dev/null; then
  logE "Could not find requirement 'twine'";
  exit 1;
fi

# Build and test
bash build.sh;
if (( $? != 0 )); then
  exit $?;
fi

logI "Running distribution checks";
twine check build/dist/*;
if (( $? != 0 )); then
  logE "Distribution checks have failed";
  exit 1;
fi
logI "All distribution checks have passed";

if [[ $ARG_TESTPYPI == true ]]; then
  logI "Uploading distributions to TestPyPI";
  twine upload --repository testpypi build/dist/*;
  if (( $? != 0 )); then
    logE "Failed to upload distributions";
    exit 1;
  fi
else
  logI "Uploading distributions to PyPI";
  twine upload build/dist/*;
  if (( $? != 0 )); then
    logE "Failed to upload distributions";
    exit 1;
  fi
fi
logI "Distributions have been successfully uploaded";
