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

  [-?|--help]          Show this help message.
EOS
)

# Arg flags
ARG_CHECK_BASH=false;
ARG_TEST_COMPAT=false;
ARG_TEST_FUNCT=false;
ARG_TEST_FUNCT_ARG="";
ARG_KEEP_OUTPUT=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
arg_check_optarg=false;
for arg in "$@"; do
  if [[ $arg_check_optarg == true ]]; then
    arg_check_optarg=false;
    if [[ "$arg" != -* ]]; then
      ARG_TEST_FUNCT_ARG="$arg";
      shift;
      continue;
    fi
  fi
  case $arg in
    -b|--check-bash)
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
    shift
    ;;
    --keep-output)
    ARG_KEEP_OUTPUT=true;
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

run_bash_compat=true;
run_compat=true;
run_funct=true;

if [[ $ARG_CHECK_BASH == true ]]; then
  if [[ $ARG_TEST_COMPAT == true || $ARG_TEST_FUNCT == true ]]; then
    echo "Argument '-b' cannot be used with '-c' or '-f'";
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

test_result=0;

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

if [[ $run_funct == true ]]; then
  if (( $test_result == 0 )); then
    ftest_args="";
    if [[ $ARG_KEEP_OUTPUT == true ]]; then
      ftest_args="--keep-output";
    fi
    if [[ $ARG_TEST_FUNCT_ARG != "" ]]; then
      ftest_args="${ftest_args} --filter=${ARG_TEST_FUNCT_ARG}";
    fi
    bash "tests/functionality_tests.sh" "$ftest_args";
    test_result=$?;
  fi
fi

exit $test_result;
