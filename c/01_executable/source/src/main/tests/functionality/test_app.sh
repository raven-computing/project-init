#!/bin/bash
${{VAR_COPYRIGHT_HEADER}}

function test_app_output() {
  run_app;
  assert_exit_status $EXIT_SUCCESS;
  assert_stdout_contains "${{VAR_PROJECT_SLOGAN_STRING}}";
  assert_stderr_is_empty;
}
