#!/usr/bin/env bash

# Get the directory name for the current script
export this_script_dir="$(cd "$(dirname "$(readlink -f "$0")")"; pwd)"

####################################
#          Source functions        #
####################################
# TODO: Add correct path to configuration file
. "$this_script_dir/project-manager.conf"
. "$this_script_dir/functions/init.sh"

run_project_manager "$@"
