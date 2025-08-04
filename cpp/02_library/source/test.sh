#!/bin/bash
# Test script for the ${{VAR_PROJECT_NAME}} library.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the ${{VAR_PROJECT_NAME}} library.

${USAGE}

Options:

  [--coverage] Report code coverage metrics for the test runs.
${{VAR_SCRIPT_TEST_ISOLATED_OPT}}

  [-?|--help]  Show this help message.
EOS
)

# Arg flags
ARG_COVERAGE=false;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGFLAG}}
ARG_SHOW_HELP=false;

${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY}}

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --coverage)
    ARG_COVERAGE=true;
${{VAR_SCRIPT_BUILD_ISOLATED_ARGARRAY_ADD}}
    shift
    ;;
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

# Need to prematurely create the build dir if it does not exist
# so it can be used as a volume by Docker when using
# an isolated test execution
if ! [ -d "build" ]; then
  mkdir "build";
fi

${{VAR_SCRIPT_TEST_ISOLATED_MAIN}}

# Ensure the required executables are available
if ! command -v "cmake" &> /dev/null; then
  echo "ERROR: Could not find the 'cmake' executable.";
  echo "ERROR: Please make sure that CMake is correctly installed";
  exit 1;
fi
if ! command -v "ctest" &> /dev/null; then
  echo "ERROR: Could not find the 'ctest' executable.";
  echo "ERROR: Please make sure that CMake and CTest are correctly installed";
  exit 1;
fi
if [[ $ARG_COVERAGE == true ]]; then
  if ! command -v "lcov" &> /dev/null; then
    echo "ERROR: Could not find command 'lcov' to generate test coverage data";
    exit 1;
  fi
  if ! command -v "genhtml" &> /dev/null; then
    echo "ERROR: Could not find command 'genhtml' to generate test coverage report";
    exit 1;
  fi
fi

# Check if the build dir is empty
if [ -z "$(ls -A build)" ]; then
  # Build the tests first
  echo "Building project before test run execution";
  bash build.sh;
  if (( $? != 0 )); then
    exit $?;
  fi
fi

COV_INCL_PATH="$PWD";
BUILD_DIR_COV_DATA="cov";
FILE_COV_DATA_MERGED="merged.info";
BUILD_DIR_COV_REPORT="coverage_report";

if [[ $ARG_COVERAGE == true ]]; then
  # Remove previously collected test coverage data
  rm -rf "build/${BUILD_DIR_COV_DATA}" "build/${BUILD_DIR_COV_REPORT}";
  find . -name '*.gcda' -delete;
fi

cd "build";
if (( $? != 0 )); then
  exit $?;
fi

BUILD_CONFIGURATION="";
# Determine the build configuration of the last build.
if [ -f "CMakeCache.txt" ]; then
  BUILD_CONFIGURATION="$(grep --max-count=1 CMAKE_BUILD_TYPE CMakeCache.txt \
                         | cut  --delimiter='=' --fields=2)";
fi

# By default, GTest does not use colourful output when logging
# the test results to a file. But as we also show the tests
# in a terminal, we explicitly activate colourful output.
export GTEST_COLOR=1;

# UB-Sanitizer options.
export UBSAN_OPTIONS="halt_on_error=1:print_stacktrace=1";

# Run tests with CTest
ctest --output-on-failure --build-config "$BUILD_CONFIGURATION";
ctest_status=$?;

if (( ctest_status == 0 )); then
  if [[ $ARG_COVERAGE == true ]]; then
    echo "Collecting coverage data";
    mkdir "$BUILD_DIR_COV_DATA";
    if ! lcov --quiet --directory . --capture \
              --include "${COV_INCL_PATH}"'/src/*' \
              --output-file "${BUILD_DIR_COV_DATA}/${FILE_COV_DATA_MERGED}"; then
      echo "Failed to collect test coverage data";
      exit 1;
    fi
    echo "Generating test coverage report";
    genhtml_opt_args=();
    genhtml_version=($(genhtml --version |grep -o -e '[0-9.]'));
    genhtml_version="${genhtml_version[0]}";
    if (( genhtml_version >= 2 )); then
      genhtml_opt_args+=("--header-title");
      genhtml_opt_args+=("${{VAR_PROJECT_NAME}} Test Coverage");
      genhtml_opt_args+=("--footer");
      genhtml_opt_args+=("Copyright © ${{VAR_COPYRIGHT_YEAR}} ${{VAR_PROJECT_ORGANISATION_NAME}}");
    fi
    if ! genhtml --quiet --output-directory "$BUILD_DIR_COV_REPORT" \
                 --prefix "$COV_INCL_PATH" \
                 --title "${{VAR_PROJECT_NAME}} Test Coverage" \
                 "${genhtml_opt_args[@]}" \
                 "${BUILD_DIR_COV_DATA}/${FILE_COV_DATA_MERGED}"; then
      echo "Failed to generate test coverage report";
      exit 1;
    fi
    report_label="build/${BUILD_DIR_COV_REPORT}/index.html";
    report_url="file://${COV_INCL_PATH}/${report_label}";
    report_link="\e]8;;${report_url}\e\\\\${report_label}\e]8;;\e\\\\";
    echo -e "Wrote HTML report to $report_link";
  fi
fi

exit $ctest_status;
