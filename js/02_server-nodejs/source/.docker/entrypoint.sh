#!/bin/bash
###############################################################################
#                                                                             #
#                   The Entrypoint for the Docker Container                   #
#                                                                             #
# The (first) argument 'tests' is handled in a special way. It is used to     #
# launch the underlying project's test.sh script. All subsequent arguments    #
# are passed to that script transparently. If the first argument is           #
# not 'tests', then all arguments are passed to the exec command as is.       #
#                                                                             #
###############################################################################

if [[ "$1" == "tests" ]]; then
  shift;
  exec ./test.sh "$@";
else
  exec "$@";
fi
