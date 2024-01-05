#!/usr/bin/env bash

LOG_ERROR="ERROR"
LOG_WARNING="WARNING"
LOG_INFO="INFO"
LOG_VERBOSE="VERBOSE"
LOG_DEBUG="DEBUG"

declare -rA LOG_LEVELS=(["$LOG_ERROR"]=0 ["$LOG_WARNING"]=1 ["$LOG_INFO"]=3 ["$LOG_VERBOSE"]=4 ["$LOG_DEBUG"]=5)

MAX_LOG_LEVEL="$DEFAULT_LOG_LEVEL"

function log() {
    if [ $# -le 2 ] && [ $# -ne 0 ]; then
        log_level="$DEFAULT_LOG_LEVEL"
        message=""
        if [ $# -eq 2 ]; then
            log_level="$1"
            message="$2"
        else
            message="$1"
        fi

        if (( ${LOG_LEVELS["$log_level"]} <= ${LOG_LEVELS["$MAX_LOG_LEVEL"]} )); then
            echo -e "$log_level\t<${FUNCNAME[1]}>: \t$message" >&2
        fi
    else
        log "Wrong amount of arguments: '$*'"
        log "Expected 1 or 2 arguments as such:"
        log "log [LOG_LEVEL] <message>"
        exit 1
    fi
}

function get_session_name() {
  leaf_path=$(basename "$1")

  declare -a all_dirs=( $(echo "$1" | sed 's|/| |g') )
  unset all_dirs[${#all_dirs[@]}-1]

  final_path=""

  if (( ${#all_dirs[@]} >= 1 )); then
    for dir in "${all_dirs[@]}"
    do
      if [[ "${dir:0:1}" != "." ]]; then
        final_path="$final_path/${dir:0:1}"
      else
        final_path="$final_path/_"
      fi
    done
  fi

  final_path="$final_path/$leaf_path"

  echo "$final_path-$(date +%Y%m%d-%H%M%S)"
}
