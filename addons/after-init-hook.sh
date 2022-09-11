#!/bin/bash
# This script will be called by the Project Init system after a new project has
# been successfully initialized. It will be executed in a separate process.
# It will not have access to any functions and variables defined in any init script.
# However, the environment variable 'VAR_PROJECT_DIR' will contain the absolute path
# to the project root directory of the initialized project.
# Both stdout and stderr will be redirected to /dev/null
# The current working directory (as indicated by the command 'pwd') will be
# located in the directory that this script is placed in, i.e. the addons directory.
# 
# For example, this hook can be used to execute some work after a new
# project has been initialized.

