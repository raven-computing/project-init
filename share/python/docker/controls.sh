#!/bin/bash
###############################################################################
#                                                                             #
#       Project Control Code to Build and Test in Isolated Environments       #
#                                                                             #
# This shell script provides functions to handle isolated executions          #
# via Docker. Users may source this file and call the provided functions to   #
# either build or test the underlying project inside a Docker container.      #
# This can also be used to run arbitrary commands inside an isolated          #
# container or to get an interactive shell. Some execution parameters         #
# can be controlled by setting various PROJECT_CONTAINER_* variables.         #
#                                                                             #
###############################################################################

# The Dockerfile to be used for creating images for isolated builds
PROJECT_CONTAINER_BUILD_DOCKERFILE="Dockerfile-build";
# The name given to the image and container
PROJECT_CONTAINER_BUILD_NAME="${{VAR_PROJECT_NAME_LOWER}}-build";
# The version tag given to the image and container
PROJECT_CONTAINER_BUILD_VERSION="0.1";


# Executes an isolated command inside a Docker container.
#
# This function builds the image, creates a container from it
# and then runs that container. The container is removed after
# the execution has completed.
#
# The building of the Docker image can be suppressed by setting the
# environment variable PROJECT_CONTAINER_IMAGE_BUILD to the value "0".
#
# Args:
# $@ - The arguments to be passed to the container's entrypoint.
#
# Returns:
# Either the exit status of the Docker-related commands, if unsuccessful,
# or the exit status of the specified command.
#
function project_run_isolated() {
  local isolated_command="$1";
  shift;
  if [ -z "$isolated_command" ]; then
    echo "ERROR: Must provide a command to run in isolation";
    return 1;
  fi
  if ! command -v "docker" &> /dev/null; then
    echo "ERROR: Could not find the 'docker' executable.";
    echo "If you want a command to be executed in an isolated environment,";
    echo "please make sure that Docker is correctly installed ";
    return 1;
  fi

  local uid=0;
  local gid=0;
  local workdir_name="${{VAR_PROJECT_NAME_LOWER}}";
  local workdir="/root/${workdir_name}";
  # When using non-rootless Docker, the user inside the container should be a
  # regular user. We assign him the same UID and GID as the underlying host
  # user so that there are no conflicts when bind-mounting the source tree.
  # However, when rootless Docker is used, we want to use the root user inside
  # the container as it essentially maps to the underlying host user from
  # a security point of view.
  if ! docker info 2>/dev/null |grep -q "rootless"; then
    uid=$(id -u);
    gid=$(id -g);
    workdir="/home/user/${workdir_name}";
  fi
  local name_tag="${PROJECT_CONTAINER_BUILD_NAME}:${PROJECT_CONTAINER_BUILD_VERSION}";
  if [[ "$PROJECT_CONTAINER_IMAGE_BUILD" != "0" ]]; then
    echo "Building Docker image";
    docker build --build-arg UID=${uid}                                \
                 --build-arg GID=${gid}                                \
                 --build-arg DWORKDIR="${workdir}"                     \
                 --tag "$name_tag"                                     \
                 --file .docker/${PROJECT_CONTAINER_BUILD_DOCKERFILE} .

    local docker_status=$?;
    if (( docker_status != 0 )); then
      return $docker_status;
    fi
  fi

  echo "Executing isolated $isolated_command";
  docker run --name ${PROJECT_CONTAINER_BUILD_NAME}                \
             --mount type=bind,source="${PWD}",target="${workdir}" \
             --user ${uid}:${gid}                                  \
             --rm                                                  \
             --tty                                                 \
             --interactive                                         \
             "$name_tag"                                           \
             "$isolated_command"                                   \
             "$@";

  return $?;
}
