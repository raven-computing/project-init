#!/bin/bash
###############################################################################
#                                                                             #
#                   The Entrypoint for the Docker Container                   #
#                                                                             #
# The (first) arguments 'build' and 'tests' are handled in a special way.     #
# They are used to launch either the underlying project's build.sh or test.sh #
# script, respectively. All subsequent arguments are passed to those scripts  #
# transparently. If the first argument is neither 'build' nor 'tests', then   #
# all arguments are passed to the exec command as is.                         #
#                                                                             #
###############################################################################

if [[ "$1" == "build" ]]; then
  shift;
  exec ./build.sh "$@";
elif [[ "$1" == "tests" ]]; then
  shift;
  exec ./test.sh "$@";
else
  exec "$@";
fi
