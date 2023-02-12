#!/bin/bash
###############################################################################
#                                                                             #
#                   The Entrypoint for the Docker Container                   #
#                                                                             #
# The (first) argument 'app' is handled in a special way. It is used to       #
# launch the underlying project's run.sh script. All subsequent arguments     #
# are passed to that script transparently. If the first argument is           #
# not 'app', then all arguments are passed to the exec command as is.         #
#                                                                             #
###############################################################################

if [[ "$1" == "app" ]]; then
  shift;
  exec ./run.sh "$@";
else
  exec "$@";
fi
