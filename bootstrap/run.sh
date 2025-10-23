#!/bin/bash
# Copyright (C) 2025 Raven Computing
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# #***************************************************************************#
# *                                                                           *
# *              ***   Project Init Bootstrap Run Script   ***                *
# *                                                                           *
# #***************************************************************************#
#
# This script is used to bootstrap the Project Init system and run it without
# installing the content on the host system. By default, all resources are
# cached into the system's temporary directory. This behaviour can be adjusted
# by specifying the '--no-cache' option, which will clear the caches before
# and after execution of the Project Init system main program. Once the cache
# is filled, it is reused in subsequent invocations of this program.
# By default, the content of a reused cache is updated in every new invocation
# of the program. This behaviour can be adjusted by specifying the '--no-pull'
# option, which will disable cache updates and use the locally available
# cache as is.
# All other arguments are passed as is to the Project Init system's
# main program.
# This script will return the exit status of the Project Init system's main
# program, i.e. 0 for success and non-zero otherwise.
#
# This script will behave differently when the PROJECT_INIT_BOOTSTRAP_FETCHONLY
# environment variable is set to '1'. If this is true, then this script will
# only try to make the latest Project Init base resources available in the cache
# directory and then exit immediately. The Project Init system's main program is
# not run in this case and his script will return exit status 0 for success
# and non-zero otherwise. In the case of success, the path to the base resource
# cache is printed to stdout.
#
# USAGE: run.sh [--no-cache] [--no-pull]


# The repository of the Project Init base resources
PROJECT_INIT_PUBLIC_REPOSITORY="https://github.com/raven-computing/project-init.git";

# The Git branch or tag to use when cloning the repository
PROJECT_INIT_PUBLIC_REPOSITORY_TAG="v1-latest";

# The name of the main script to be executed after Project Init
# resources are made available.
PROJECT_INIT_SCRIPT_MAIN="initmain.sh";

# The absolute path to the location where to
# cache Project Init resources.
PROJECT_INIT_CACHE_LOCATION="/tmp";

# Effective user ID
_EUID=$(id -u);


# Removes cached data dirs in system's temporary directory.
function remove_cache_data() {
  cd "$PROJECT_INIT_CACHE_LOCATION" || return;
  # Check cache for base resources
  local cache_dir_pattern="pi_cache_${_EUID}_*";
  local cache_dirs=( $cache_dir_pattern );
  local cache_dir="";
  if [[ "${cache_dirs[0]}" != "$cache_dir_pattern" ]]; then
    for cache_dir in "${cache_dirs[@]}"; do
      if [ -d "$cache_dir" ]; then
        rm -rf "$cache_dir";
      fi
    done
  fi
  # Check cache for addons resources
  cache_dir_pattern="piar_cache_${_EUID}_*";
  cache_dirs=( $cache_dir_pattern );
  if [[ "${cache_dirs[0]}" != "$cache_dir_pattern" ]]; then
    for cache_dir in "${cache_dirs[@]}"; do
      if [ -d "$cache_dir" ]; then
        rm -rf "$cache_dir";
      fi
    done
  fi
}

# Fetches the Project Init base resources from the public repository
# via Git and puts all files in a temporary cache directory. If the cache
# is already filled, it is updated instead.
#
# Returns:
# 0 - If the Project Init system was successfully bootstrapped,
# 1 - Otherwise.
#
function bootstrap_project_init() {
  # Find suitable cache dir
  local cache_dir_pattern="pi_cache_${_EUID}_*";
  local cache_dirs=( $cache_dir_pattern );
  local base_res_dir="";
  # Check if a cache dir already exists
  if [[ "${cache_dirs[0]}" == "$cache_dir_pattern" ]]; then
    # No cache dir found, so create one
    base_res_dir="$(mktemp -d pi_cache_${_EUID}_XXXXXXXXXX)";
    cmd_exit_status=$?;
    if (( $cmd_exit_status != 0 )); then
      echo "ERROR: Command 'mktemp' returned non-zero exit status $cmd_exit_status";
      echo "ERROR: Failed to create Project Init resource cache" \
           "under $PROJECT_INIT_CACHE_LOCATION";
      return 1;
    fi
    local cache_dir="$PROJECT_INIT_CACHE_LOCATION/$base_res_dir";
    local git_tag="";
    if [ -n "$PROJECT_INIT_PUBLIC_REPOSITORY_TAG" ]; then
      git_tag="-b $PROJECT_INIT_PUBLIC_REPOSITORY_TAG";
    fi
    if [[ $arg_version_str == false ]]; then
      echo -n "Loading...";
    fi
    # Fetch the latest resources and store them in the cache dir
    git clone $git_tag --depth 1 "$PROJECT_INIT_PUBLIC_REPOSITORY" "$cache_dir" &> /dev/null;
    cmd_exit_status=$?;
    if (( $cmd_exit_status != 0 )); then
      echo "FAILURE";
      rm -rf "$base_res_dir";
      echo "ERROR: Command 'git clone' returned non-zero exit status $cmd_exit_status";
      echo "ERROR: Failed to fetch Project Init resources from: ";
      echo "       '$PROJECT_INIT_PUBLIC_REPOSITORY'";
      echo "and caching them under '$cache_dir'";
      return 1;
    fi
    cd "$base_res_dir";
  else
    # At least one cache dir found
    base_res_dir="${cache_dirs[0]}";
    cd "$base_res_dir";
    if [[ $arg_version_str == false ]]; then
      echo -n "Loading...";
    fi
    cmd_exit_status=0;
    if [[ $arg_no_pull == false ]]; then
      # Update cache so that we always use the latest version
      git pull &> /dev/null;
      cmd_exit_status=$?;
    fi
    if (( $cmd_exit_status != 0 )); then
      local cache_dir="$PROJECT_INIT_CACHE_LOCATION/$base_res_dir";
      echo "FAILURE";
      echo "ERROR: Command 'git pull' returned non-zero exit status $cmd_exit_status";
      echo "ERROR: Failed to update cached Project Init resources: ";
      echo "   at: '$cache_dir'";
      if [[ $arg_no_cache == false ]]; then
        echo "You could try to remove the cache directory '$cache_dir' ";
        echo "or use the '--no-cache' option and try again.";
      else
        echo "Cache cleared. Please try again.";
      fi
      return 1;
    fi
  fi
  if [[ $arg_version_str == false ]]; then
    echo "OK";
  fi
  if [[ "$PROJECT_INIT_BOOTSTRAP_FETCHONLY" == "1" ]]; then
    echo "$PROJECT_INIT_CACHE_LOCATION/$base_res_dir";
  fi
  return 0;
}

function main() {
  # Ensure this script is not executed by the root user,
  # except when running inside a Docker container.
  if (( ${_EUID} == 0 )); then
    if ! [ -f "/.dockerenv" ]; then
      echo "WARNING: There is no need for this program to be executed by the root user.";
      echo "Please use a regular user instead.";
      return 1;
    fi
  fi
  arg_version_str=false;
  arg_no_cache=false;
  arg_no_pull=false;
  for arg in "$@"; do
    case $arg in
      --no-cache)
      arg_no_cache=true;
      ;;
      --no-pull)
      arg_no_pull=true;
      ;;
      -#)
      # Used to not show the loading text when only the
      # version identifier string is requested
      arg_version_str=true;
      ;;
    esac
  done

  if [[ "$PROJECT_INIT_BOOTSTRAP_FETCHONLY" == "1" ]]; then
    arg_version_str=true;
  fi

  # Ensure that git and mktemp are available
  if ! command -v "git" &> /dev/null; then
    echo "Could not find the 'git' executable.";
    echo "Please make sure that git is correctly installed.";
    return 1;
  fi
  if ! command -v "mktemp" &> /dev/null; then
    echo "Could not find the 'mktemp' executable.";
    echo "Please make sure that mktemp is correctly installed.";
    return 1;
  fi
  local cmd_exit_status=0;
  # Save the CWD and restore it before starting initmain
  local _USER_CWD="$PWD";
  cd "$PROJECT_INIT_CACHE_LOCATION";
  cmd_exit_status=$?;
  if (( cmd_exit_status != 0 )); then
    echo "ERROR: Failed to change active working directory" \
         "to $PROJECT_INIT_CACHE_LOCATION";
    return 1;
  fi
  if [[ $arg_no_cache == true ]]; then
    remove_cache_data;
  fi

  bootstrap_project_init;

  local exit_status=$?;
  if (( exit_status == 0 )); then
    export PROJECT_INIT_BOOTSTRAP="1";
    if [[ "$PROJECT_INIT_BOOTSTRAP_FETCHONLY" != "1" ]]; then
      if [ -r "$PROJECT_INIT_SCRIPT_MAIN" ]; then
        if [ -x "$PROJECT_INIT_SCRIPT_MAIN" ]; then
          # Correct working paths
          local CACHE_LOCATION_BASE="$PWD";
          cd "${_USER_CWD}";

          # Run the Project Init main script
          bash "${CACHE_LOCATION_BASE}/${PROJECT_INIT_SCRIPT_MAIN}" "$@";

          exit_status=$?;
        else
          echo "ERROR: Project init script '$PROJECT_INIT_SCRIPT_MAIN' is not executable.";
          exit_status=1;
        fi
      else
        echo "ERROR: Project init script '$PROJECT_INIT_SCRIPT_MAIN' not found.";
        exit_status=1;
      fi
    fi
  fi

  if [[ $arg_no_cache == true ]]; then
    remove_cache_data;
  fi
  return $exit_status;
}

main "$@";
