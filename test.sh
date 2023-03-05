#!/bin/bash
# Test script for the Project Init system.

USAGE="Usage: test.sh [options]";

HELP_TEXT=$(cat << EOS
Tests the Project Init system.

${USAGE}

Run this script to execute the Project Init test suite. You can check whether your Bash
interpreter is compatible, perform compatibility tests for the utility commands that
Project Init has as a dependency, and validate the functionality of the program.
If no arguments are given, the entire test suite is run in the previously mentioned order.

Options:

  [--check-bash]       Only check compatibility of the available Bash interpreter.

  [-c|--compatibility] Only perform compatibility tests for Bash and dependent commands.

  [-f|--functionality] [tests]
                       Only perform functionality tests. The optional argument [tests] can
                       specify a comma-separated list of test case names. If provided, only
                       those functionality test cases will be executed. If no argument is
                       provided to this option, then all available functionality test cases
                       are executed. For example, specifying '-f c_library' will only
                       execute the test provided by the 'tests/test_func_c_library.sh' file.

  [--keep-output]      Do not automatically remove files generated by functionality tests.
                       Subsequent runs will still remove any residue files prior to
                       the next execution.

  [--test-path]        TEST_PATH
                       The path to the source root directory of the instance to test.
                       This option is used to instruct the testing facility to run tests for
                       an addons resource instead of the base resources. The mandatory option
                       argument must be the filesystem path to the addons resource directory.

  [-?|--help]          Show this help message.
EOS
)

# Arg flags
ARG_CHECK_BASH=false;
ARG_TEST_COMPAT=false;
ARG_TEST_FUNCT=false;
ARG_TEST_FUNCT_ARGS=();
ARG_KEEP_OUTPUT=false;
ARG_TEST_PATH=false;
ARG_SHOW_HELP=false;

# Arg helper vars
arg_check_optarg=false;
arg_optarg_key="";
arg_optarg_required="";

# Parse all arguments given to this script
for arg in "$@"; do
  if [[ $arg_check_optarg == true ]]; then
    arg_check_optarg=false;
    if [[ "$arg" != -* ]]; then
      ARG_TEST_FUNCT_ARGS+=("${arg_optarg_key}${arg}");
      arg_optarg_required="";
      shift;
      continue;
    fi
  fi
  if [ -n "$arg_optarg_required" ]; then
    echo "Missing required option argument '$arg_optarg_required'";
    exit 1;
  fi
  case $arg in
    --check-bash)
    ARG_CHECK_BASH=true;
    shift
    ;;
    -c|--compatibility)
    ARG_TEST_COMPAT=true;
    shift
    ;;
    -f|--functionality)
    ARG_TEST_FUNCT=true;
    arg_check_optarg=true;
    arg_optarg_key="--filter=";
    shift
    ;;
    --keep-output)
    ARG_KEEP_OUTPUT=true;
    ARG_TEST_FUNCT_ARGS+=("--keep-output");
    shift
    ;;
    --test-path)
    ARG_TEST_PATH=true;
    arg_check_optarg=true;
    arg_optarg_required="TEST_PATH";
    arg_optarg_key="--test-path=";
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

if [ -n "$arg_optarg_required" ]; then
  echo "Missing required option argument '$arg_optarg_required'";
  exit 1;
fi

run_bash_compat=true;
run_compat=true;
run_funct=true;

if [[ $ARG_CHECK_BASH == true ]]; then
  if [[ $ARG_TEST_COMPAT == true || $ARG_TEST_FUNCT == true ]]; then
    echo "Argument '--check-bash' cannot be used with '-c' or '-f'";
    exit 1;
  fi
  run_compat=false;
  run_funct=false;
fi

if [[ $ARG_TEST_COMPAT == true ]]; then
  if [[ $ARG_TEST_FUNCT == true ]]; then
    echo "Argument '-c' cannot be used with '-f'";
    exit 1;
  fi
  run_funct=false;
fi

if [[ $ARG_TEST_FUNCT == true ]]; then
  run_bash_compat=false;
  run_compat=false;
fi

# The test.sh might be called from an addon, in which case the current
# working directory might not actually be the expected Project Init base
# source root. Ensure the correct CWD is set
BASEPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" > /dev/null 2>&1 && pwd)";
cd "$BASEPATH";

test_result=0;

if [[ $ARG_TEST_PATH == false ]]; then
  if [[ $run_bash_compat == true ]]; then
    bash "tests/bash_tests.sh";
    test_result=$?;
  fi
  if [[ $run_compat == true ]]; then
    if (( $test_result == 0 )); then
      bash "tests/compatibility_tests.sh";
      test_result=$?;
    fi
  fi
fi

if [[ $run_funct == true ]]; then
  if (( $test_result == 0 )); then
    ftest_args="";
    if (( ${#ARG_TEST_FUNCT_ARGS[@]} > 0 )); then
      ftest_args="${ARG_TEST_FUNCT_ARGS[@]}";
    fi
    bash "tests/functionality_tests.sh" $ftest_args;
    test_result=$?;
  fi
fi

exit $test_result;
