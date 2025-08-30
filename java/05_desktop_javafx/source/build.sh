#!/bin/bash
# Build script for the ${{VAR_PROJECT_NAME}} desktop application.

USAGE="Usage: build.sh [options]";

HELP_TEXT=$(cat << EOS
Builds the ${{VAR_PROJECT_NAME}} desktop application.

${USAGE}

Options:

  [--clean]    Remove all build-related directories and files and then exit.
${{VAR_SCRIPT_BUILD_DOCS_OPT}}

  [-i|--image] Build an application image with jlink. This will also create
               a distributable ZIP archive from that image.

  [-?|--help]  Show this help message.
EOS
)

# Arg flags
ARG_CLEAN=false;
${{VAR_SCRIPT_BUILD_DOCS_ARGFLAG}}
ARG_BUILD_IMAGE=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --clean)
    ARG_CLEAN=true;
    shift
    ;;
${{VAR_SCRIPT_BUILD_DOCS_ARGPARSE}}
    -i|--image)
    ARG_BUILD_IMAGE=true;
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

${{VAR_SCRIPT_BUILD_DOCS_MAIN}}

# Ensure the required executable is available
if ! command -v "mvn" &> /dev/null; then
  echo "ERROR: Could not find the 'mvn' executable.";
  echo "ERROR: Please make sure that Maven is correctly installed";
  exit 1;
fi

# Arguments passed to Maven
cmd_mvn_args="";

# Check clean flag
if [[ "$ARG_CLEAN" == true ]]; then
  mvn "clean";
  exit $?;
fi

# Check build flags
if [[ "$ARG_BUILD_IMAGE" == true ]]; then
  cmd_mvn_args="${cmd_mvn_args} javafx:jlink";
fi

mvn package ${cmd_mvn_args};
exit $?;
