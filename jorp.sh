#!/usr/bin/env bash

# Get the directory name for the current script
THIS_SCRIPT_DIR="$(cd "$(dirname "$(readlink -f "$0")")" || exit; pwd)"
export THIS_SCRIPT_DIR

####################################
#          Source functions        #
####################################
# shellcheck source-path=SCRIPTDIR
. "$THIS_SCRIPT_DIR/core/init.sh"
# shellcheck source-path=SCRIPTDIR
. "$THIS_SCRIPT_DIR/log.sh/src/log.sh"

run_project_manager "$@"
