#!/usr/bin/env bash

####################################
#          Source functions        #
####################################
. "$THIS_SCRIPT_DIR/core/config.sh"
. "$THIS_SCRIPT_DIR/core/utils.sh"
. "$THIS_SCRIPT_DIR/backends/init.sh"

LONGOPTS=batch:,config:,debug,help,last-item:,remove,verbose
OPTIONS=b:c:dhl:rv

export batch=n batch_args="" config_file="" debug=n last_item_backend="" verbose=n remove=n

function usage() {
  script_name="$(basename "$(readlink -f "$0")")"
  echo "jorp.sh - A terminal multiplexer project/session manager"
  echo ""
  echo "Usage: $script_name [option]"
  echo ""
  echo "  -h,--help                                     Print this usage information"
  echo "  -b,--batch <command1>[,<command2>...]         Run the specified command(s) non-interactively"
  echo "  -c,--config <config file>                     Specify a path to a configuration file. Defaults to \$XDG_CONFIG_HOME/jorp.sh/config.json"
  echo "  -d,--debug                                    Print debug log messages. Takes precedence over verbose messages"
  echo "  -r,--remove                                   Start jorp.sh in \"removal mode\" where the chosen multiplexer session will be removed"
  echo "  -l,--last-item <backend>                      Switch to the last selected item for the backend with the name <backend>"
  echo "  -v,--verbose                                  Print verbose log messages"
}

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
          -l|--last-item)
              last_item_backend="$2"
              shift
              shift
              ;;
          -v|--verbose)
              verbose=y
              shift
              ;;
          -h|--help)
              usage
              exit 0
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

  max_log_level="INFO"

  if [ "$verbose" == "y" ]; then
    max_log_level="VERBOSE"
  fi

  if [ "$debug" == "y" ]; then
    max_log_level="DEBUG"
  fi

  set_max_log_level "$max_log_level"
  backend_init

  log_verbose  "Arguments are '$*'"
  log_debug "This script is located in '$THIS_SCRIPT_DIR'"

  if [ -n "$last_item_backend" ]; then
    backend="$last_item_backend"
    select_last_item
    return
  fi

  if [ "$batch" == "y" ]; then
    backend="$(echo "$batch_args" | cut -d" " -f1)"
    batch_args="$(echo "$batch_args" | cut -d" " -f2-)"

    if [ "$(backend_has_batch "$backend")" == "n" ]; then
      log_debug "The backend '$backend' does not support batch processing"
      exit 1
    fi

    eval "${backend}_run_batch $batch_args"
    return
  fi
  get_items "$remove"

  fzf_options="$(config_get_item "$CONFIG_FZF_EXTRA_OPTIONS")"
  selected_item="$(printf "%s\n" "${BACKEND_ITEMS[@]}" | eval fzf "$fzf_options")"

  if [ -z "$selected_item" ]; then
      log_warn "The user did not select an item"
      exit 0
  fi

  prefix="$(echo "$selected_item" | cut -d: -f1)"
  selected_item="$(echo "$selected_item" | cut -d: -f2- | xargs)"

  backend="$(get_backend_from_prefix "$prefix")"

  if [ "$(backend_has_submenu "$backend")" == "y" ]; then
    log_debug "Showing submenu for backend '$backend'"
    show_submenu "$backend" "$remove"
  else
    if [ "$remove" == "y" ]; then
      remove_item "$backend" "$selected_item"
    else
      select_item "$backend" "$selected_item"
    fi
  fi
}
