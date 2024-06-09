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
# The project name inside the container
PROJECT_CONTAINER_PROJECT_NAME="${{VAR_PROJECT_NAME_LOWER}}";


# Checks that the docker command is available.
#
# Args:
# $@ - Optional hints to be printed when the docker executable is not found.
#
# Returns:
# 0 on success, otherwise non-zero.
#
function _check_docker() {
  local hint="";
  if ! command -v "docker" &> /dev/null; then
    logE "Could not find the 'docker' executable.";
    for hint in "$@"; do
      logE "$hint";
    done
    return 1;
  fi
  return 0;
}

# Builds the Docker image.
#
# The building of the Docker image can be suppressed by setting the
# environment variable PROJECT_CONTAINER_IMAGE_BUILD to the value "0".
#
# Returns:
# The exit status of the docker build command.
#
function _docker_build() {
  if [[ "$PROJECT_CONTAINER_IMAGE_BUILD" == "0" ]]; then
    return 0;
  fi
  local uid=0;
  local gid=0;
  local workdir="/root/${PROJECT_CONTAINER_PROJECT_NAME}";
  # When using non-rootless Docker, the user inside the container should be a
  # regular user. We assign him the same UID and GID as the underlying host
  # user so that there are no conflicts when bind-mounting the source tree.
  # However, when rootless Docker is used, we want to use the root user inside
  # the container as it essentially maps to the underlying host user from
  # a security point of view.
  if ! docker info 2>/dev/null |grep -q "rootless"; then
    uid=$(id -u);
    gid=$(id -g);
    workdir="/home/user/${PROJECT_CONTAINER_PROJECT_NAME}";
  fi
  local name_tag="${PROJECT_CONTAINER_BUILD_NAME}:${PROJECT_CONTAINER_BUILD_VERSION}";
  logI "Building Docker image";
  docker build --build-arg UID=${uid}                                \
               --build-arg GID=${gid}                                \
               --build-arg DWORKDIR="${workdir}"                     \
               --tag "${name_tag}"                                   \
               --file .docker/${PROJECT_CONTAINER_BUILD_DOCKERFILE} .

  return $?;
}

# Executes an isolated command inside a Docker container.
#
# This function builds the image, creates a container from it
# and then runs that container. The container is removed after
# the execution has completed.
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
  if ! _check_docker "If you want a command to be executed in an isolated environment," \
                     "please make sure that Docker is correctly installed."; then
    return 1;
  fi

  if ! _docker_build; then
    return $?;
  fi

  local uid=0;
  local gid=0;
  local workdir="/root/${PROJECT_CONTAINER_PROJECT_NAME}";
  if ! docker info 2>/dev/null |grep -q "rootless"; then
    uid=$(id -u);
    gid=$(id -g);
    workdir="/home/user/${PROJECT_CONTAINER_PROJECT_NAME}";
  fi
  local name_tag="${PROJECT_CONTAINER_BUILD_NAME}:${PROJECT_CONTAINER_BUILD_VERSION}";
  logI "Executing isolated $isolated_command";
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

# Executes an isolated server application process inside a Docker container.
#
# This function builds the image, creates a container from it
# and then runs that container. The container is removed after
# the execution has completed.
#
# Args:
# $@ - Arguments to be passed to the server application at startup.
#
# Returns:
# The exit status of the Docker-related command. If the Docker command is
# successful, then the exit status of the executed server application is
# returned instead.
#
function _start_interactive_isolated_tests() {
  if ! _check_docker "If you want to create an isolated environment for interactive testing," \
                     "please make sure that Docker is correctly installed."; then
    return 1;
  fi

  if ! _docker_build; then
    return $?;
  fi

  local uid=0;
  local gid=0;
  local workdir="/root/${PROJECT_CONTAINER_PROJECT_NAME}";
  if ! docker info 2>/dev/null |grep -q "rootless"; then
    uid=$(id -u);
    gid=$(id -g);
    workdir="/home/user/${PROJECT_CONTAINER_PROJECT_NAME}";
  fi
  local name_tag="${PROJECT_CONTAINER_BUILD_NAME}:${PROJECT_CONTAINER_BUILD_VERSION}";
  logI "Starting isolated Docker container for interactive testing";
  docker run --name ${PROJECT_CONTAINER_BUILD_NAME}                \
             --interactive                                         \
             --tty                                                 \
             --init                                                \
             --mount type=bind,source="${PWD}",target="${workdir}" \
             --user ${uid}:${gid}                                  \
             --rm                                                  \
             --publish 8080:8080                                   \
             "$name_tag"                                           \
             "tests"                                               \
             "$@";

  return $?;
}

# Executes an isolated test process inside a Docker container.
#
# This function is used for two purposes. It either executes a 'docker build'
# followed by a 'docker run' command used to run the project's test suite, or
# it starts an interactive test session, allowing the user to interact with a
# running server application instance and test functionality. All actions are
# executed in an isolated Docker container.
#
# An interactive test session is requested by specifying
# the '--interactive' option, potentially followed by application-specific
# arguments for the isolated environment.
#
# Args:
# $@ - Arguments to be passed to the project's test.sh script to customise the
#      test process, or the arguments to be passed to the server application
#      when using an interactive test session.
#
# Returns:
# The exit status of the Docker-related commands. If the Docker commands are
# all successful, then the exit status of the executed test.sh script
# is returned instead.
# Returns the exit status of the server application process when using an
# interactive test session.
#
function project_run_isolated_tests() {
  local arg="";
  local run_interactive_session=false;
  for arg in "$@"; do
    if [[ "$arg" == "--interactive" ]]; then
      run_interactive_session=true;
      break;
   fi
  done

  if [[ $run_interactive_session == true ]]; then
    _start_interactive_isolated_tests "$@";
  else
    project_run_isolated "tests" "$@";
  fi
  return $?;
}
