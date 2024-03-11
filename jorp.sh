#!/usr/bin/env bash

# Get the directory name for the current script
THIS_SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" || exit; pwd)"
export THIS_SCRIPT_DIR

####################################
#          Source functions        #
####################################
. "$THIS_SCRIPT_DIR/functions/init.sh"

run_project_manager "$@"
