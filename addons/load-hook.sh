#!/bin/bash
# This script will be called by the Project Init system after the loading of
# the base script has completed but before the main Project Init question
# form is executed. This script will be executed in a separate process. It will
# not have access to any functions and variables defined in any init script.
# Both stdout and stderr will be redirected to /dev/null
# The current working directory (as indicated by the command 'pwd') will be
# located in the directory that this script is placed in, i.e. the addons directory.
# 
# For example, a load-hook can be used to do a git pull to make sure that
# the private addons directory is using up-to-date code:


# git pull
