#!/usr/bin/env bash

# Get the directory name for the current script
export this_script_dir="$(cd "$(dirname "$(readlink -f "$0")")"; pwd)"

####################################
#          Source functions        #
####################################
. "$this_script_dir/functions/init.sh"

run_project_manager "$@"
