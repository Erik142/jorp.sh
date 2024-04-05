#!/usr/bin/env bash

####################################
#          Source functions        #
####################################
. "$THIS_SCRIPT_DIR/functions/config.sh"
. "$THIS_SCRIPT_DIR/functions/utils.sh"
. "$THIS_SCRIPT_DIR/backends/init.sh"

# TODO: Cleanup argument parsing examples

# option --output/-o requires 1 argument
# LONGOPTS=debug,force,output:,verbose
# OPTIONS=dfo:v
LONGOPTS=batch:,config:,debug,remove,verbose
OPTIONS=b:c:drv

export batch=n batch_args="" config_file="" debug=n verbose=n remove=n

function parse_args() {
  #set -o errexit -o pipefail -o noclobber -o nounset
  # -allow a command to fail with !’s side effect on errexit
  # -use return value from ${PIPESTATUS[0]}, because ! hosed $?
  ! getopt --test > /dev/null 
  if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
    echo "I’m sorry, 'getopt --test' failed in this environment."
    exit 1
  fi

  # -regarding ! and PIPESTATUS see above
  # -temporarily store output to be able to check for errors
  # -activate quoting/enhanced mode (e.g. by writing out “--options”)
  # -pass arguments only via   -- "$@"   to separate them correctly
  ! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
      # e.g. return value is 1
      #  then getopt has complained about wrong arguments to stdout
      exit 2
  fi
  # read getopt’s output this way to handle the quoting right:
  eval set -- "$PARSED"

  # now enjoy the options in order and nicely split until we see --
  while true; do
      case "$1" in
          -b|--batch)
              batch=y
              batch_args="$2"
              shift
              shift
              ;;
          -c|--config)
              config_file="$2"
              shift
              shift
              ;;
          -d|--debug)
              debug=y
              shift
              ;;
          -r|--remove)
              remove=y
              shift
              ;;
          -v|--verbose)
              verbose=y
              shift
              ;;
          --)
              shift
              break
              ;;
          *)
              echo "Programming error"
              exit 3
              ;;
      esac
  done
}

function run_project_manager() {
  parse_args "$@"
  config_init "$config_file"

  max_log_level=""

  if [ "$verbose" == "y" ]; then
    max_log_level="$LOG_VERBOSE"
  fi

  if [ "$debug" == "y" ]; then
    max_log_level="$LOG_DEBUG"
  fi

  log_init "$max_log_level"
  backend_init

  log "$LOG_VERBOSE"  "Arguments are '$*'"
  log "$LOG_DEBUG" "This script is located in '$THIS_SCRIPT_DIR'"

  if [ "$batch" == "y" ]; then
    backend="$(echo "$batch_args" | cut -d" " -f1)"
    batch_args="$(echo "$batch_args" | cut -d" " -f2-)"

    if [ "$(backend_has_batch "$backend")" == "n" ]; then
      log "$LOG_DEBUG" "The backend '$backend' does not support batch processing"
      exit 1
    fi

    eval "${backend}_run_batch $batch_args"
    return
  fi
  get_items "$remove"

  fzf_options="$(config_get_item "$CONFIG_FZF_EXTRA_OPTIONS")"
  selected_item="$(printf "%s\n" "${BACKEND_ITEMS[@]}" | eval fzf "$fzf_options")"

  if [ -z "$selected_item" ]; then
      log "$LOG_WARNING" "The user did not select an item"
      exit 0
  fi

  prefix="$(echo "$selected_item" | cut -d: -f1)"
  selected_item="$(echo "$selected_item" | cut -d: -f2- | xargs)"

  backend="$(get_backend_from_prefix "$prefix")"

  if [ "$(backend_has_submenu "$backend")" == "y" ]; then
    log "$LOG_DEBUG" "Showing submenu for backend '$backend'"
    show_submenu "$backend" "$remove"
  else
    if [ "$remove" == "y" ]; then
      remove_item "$backend" "$selected_item"
    else
      select_item "$backend" "$selected_item"
    fi
  fi
}
