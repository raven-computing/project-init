#!/bin/bash
# Release script for the Project Init system.
# This will release the current source state to GitHub and mark the
# release commits with the corresponding tags.

USAGE="Usage: release.sh [options]";

HELP_TEXT=$(cat << EOS
Creates and commits a release version of the Project Init system.

${USAGE}

Run this script to create a release version of the Project Init system
and release it on GitHub. The management of release tags is handled
automatically for you.

Options:

  [--no-bump] Do not automatically bump the version after successful release.
              This has the effect that after release there is no new development
              version introduced to the system.

  [-?|--help] Show this help message.
EOS
)

# Global constants
readonly GIT_TAG_LATEST_SUFFIX="latest";
readonly GIT_ORIGIN="origin";
readonly VERSION_SUFFIX_DEV="dev";
readonly FILE_CHECK_CHANGELOG="CHANGELOG.md";

# Arg flags
ARG_NO_BUMP=false;
ARG_SHOW_HELP=false;

# Parse all arguments given to this script
for arg in "$@"; do
  case $arg in
    --no-bump)
    ARG_NO_BUMP=true;
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
    echo "Run 'release.sh --help' for more information";
    exit 1;
    ;;
  esac
done

# Check if help is triggered
if [[ $ARG_SHOW_HELP == true ]]; then
  echo "$HELP_TEXT";
  exit 0;
fi

# We rely on the functions from libinit to make our life easier
if ! source "libinit.sh"; then
  echo "ERROR: Could not source libinit.sh library"
  exit 1;
fi

# As we don't call the start_project_init() function from libinit,
# the global variable for the system properties and the global cmd
# line arg flags are never declared in this scope. Thus, we have to
# do it manually here to avoid problems when calling some of the
# funcs from libinit that try to read those variables
declare -g -A PROPERTIES;
_parse_args;

if ! _command_dependency "git"; then
  logE "Could not find requirement 'git'";
  exit $EXIT_FAILURE;
fi

if ! _load_version_base; then
  logW "Please correct the invalid version specifier before releasing";
  exit $EXIT_FAILURE;
fi

# Check whether the release script is executed from an installed instance
lenpath="${#RES_CACHE_LOCATION}";
pathbegin="${SCRIPT_LVL_0_BASE::lenpath}";
if [[ "$pathbegin" == "$RES_CACHE_LOCATION" ]]; then
  logW "Cannot release installed copy";
  exit $EXIT_FAILURE;
fi

if [[ $PROJECT_INIT_IS_DEV_VERSION == false ]]; then
  logW "Cannot release non-development version";
  exit $EXIT_FAILURE;
fi

if [[ "$(git branch --show-current)" != "master" ]]; then
  logW "Can only release from within the 'master' branch";
  exit $EXIT_FAILURE;
fi

git_current_status=$(git status --porcelain);
if [ -n "$git_current_status" ]; then
  logW "You have uncommitted or unstaged changes in your working tree.";
  logW "Please first commit or discard the following changes:";
  echo "$git_current_status";
  exit $EXIT_FAILURE;
fi

# Get version numbers
version_release="${PROJECT_INIT_VERSION::-4}";
version_release_array=( ${version_release//./ } );
version_release_major="${version_release_array[0]}";
version_release_minor="${version_release_array[1]}";
version_release_patch="${version_release_array[2]}";

# Warn if the changelog is not up-to-date
if [ -r "$FILE_CHECK_CHANGELOG" ]; then
  changelog_top=$(head -n 1 $FILE_CHECK_CHANGELOG);
  if [[ "$changelog_top" != "#### ${version_release}" ]]; then
    logW "No log entry found for the new version at the top of the changelog.";
    logW "Missing entry for version $version_release";
    logW "Please check file '$FILE_CHECK_CHANGELOG'";
    exit $EXIT_FAILURE;
  fi
else
  logW "Could not validate changelog file";
  logW "File not found: '$FILE_CHECK_CHANGELOG'";
fi

_vc="${COLOR_CYAN}${version_release}${COLOR_NC}";
logI "";
logI "You are about to release version ${_vc} of the Project Init system.";
logI "";
logI "Do you confirm that this version should be released? (y/N)";
read_user_input_yes_no false;
confirmation=$USER_INPUT_ENTERED_BOOL;
if [[ $confirmation == false ]]; then
  logI "Cancelling...";
  exit $EXIT_CANCELLED;
fi

logI "";
logI "Setting this project to release-version $version_release";
echo "$version_release" > "VERSION";
if (( $? != 0 )); then
  failure "Failed to set release-version in file";
fi

tag_this_version="v$version_release";
tag_v_latest="v${version_release_major}-${GIT_TAG_LATEST_SUFFIX}";

if [[ "$(git tag -l $tag_this_version)" != "" ]]; then
  failure "A commit tag '$tag_this_version' already exists";
fi

# First create release-commit and tag
logI "Committing release-version and adding tag";
git add "VERSION"                         &&
git commit -m "Release v$version_release" &&
git tag "$tag_this_version";
if (( $? != 0 )); then
  failure "Failed to commit and tag release-version";
fi
logI "Release-commit with tag $tag_this_version has been created";

# Now change the vX-latest tag to point to the same
# commit (the one we just made).
# We first remove the vX-latest tag and then add it again
logI "Updating tag $tag_v_latest";
if [[ "$(git tag -l $tag_v_latest)" != "" ]]; then
  git tag -d $tag_v_latest &&
  git push "$GIT_ORIGIN" :$tag_v_latest;
  if (( $? != 0 )); then
    failure "Failed to delete tag '$tag_v_latest'";
  fi
else
  logW "Tag '$tag_v_latest' does not exist yet. It will be created";
fi
git tag $tag_v_latest;
if (( $? != 0 )); then
  failure "Failed to create new tag '$tag_v_latest'";
fi
logI "Tag marking latest release has been updated";

# Determine new dev version:
# Simply bump the patch version number
v_new_major="$version_release_major";
v_new_minor="$version_release_minor";
v_new_patch=$((version_release_patch+1));
version_new_dev="${v_new_major}.${v_new_minor}.${v_new_patch}-${VERSION_SUFFIX_DEV}";

if [[ $ARG_NO_BUMP == false ]]; then
  logI "Running post-release actions";
  echo "$version_new_dev" > "VERSION" &&
  git add "VERSION"                   &&
  git commit -m "Bump version";
  if (( $? != 0 )); then
    failure "Failed to bump version";
  fi
  logI "Post-release actions completed";
fi

logI "Pushing release-commits and tags";

git push                               &&
git push $GIT_ORIGIN $tag_this_version &&
git push $GIT_ORIGIN $tag_v_latest;

_STR_SUCCESS_MESSAGE="The Project Init system v$version_release has been released";
_log_success;
exit $EXIT_SUCCESS;

