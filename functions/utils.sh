#!/usr/bin/env bash

LOG_ERROR="ERROR"
LOG_WARNING="WARNING"
LOG_INFO="INFO"
LOG_VERBOSE="VERBOSE"
LOG_DEBUG="DEBUG"

COLOR_DEFAULT="\033[0m"
COLOR_RED="\033[1;31m"
COLOR_YELLOW="\033[1;33m"
COLOR_BLUE="\033[1;34m"

FORMATTING_BOLD="\033[1m"
FORMATTING_NORMAL="\033[0m"

declare -rA LOG_LEVELS=(["$LOG_ERROR"]=0 ["$LOG_WARNING"]=1 ["$LOG_INFO"]=3 ["$LOG_VERBOSE"]=4 ["$LOG_DEBUG"]=5)

DEFAULT_LOG_LEVEL="INFO"
MAX_LOG_LEVEL="$DEFAULT_LOG_LEVEL"

function log_init() {
    max_log_level="$1"

    if [ -z "$max_log_level" ]; then
        max_log_level="$(config_get_item $CONFIG_GENERAL_MAX_LOG_LEVEL)"
    fi

    if [ -n "$max_log_level" ]; then
        if [ -n "${LOG_LEVELS[$max_log_level]}" ]; then
            MAX_LOG_LEVEL="$max_log_level"
        else
            log "$LOG_WARNING" "'$max_log_level' is not a valid log level"
        fi
    fi
}

function log_level_color() {
    case "$1" in
        "$LOG_ERROR")
            echo "${COLOR_RED}${1}${COLOR_DEFAULT}"
            ;;
        "$LOG_WARNING")
            echo "${COLOR_YELLOW}${1}${COLOR_DEFAULT}"
            ;;
        "$LOG_DEBUG")
            echo "${COLOR_BLUE}${1}${COLOR_DEFAULT}"
            ;;
        *)
            echo "${FORMATTING_BOLD}${1}${FORMATTING_NORMAL}"
    esac
}

function log_level_length() {
    wanted_length="$2"
    color=$(log_level_color "$1")
    original_length=${#color}
    color=${color//${COLOR_DEFAULT}/}
    color=${color//${COLOR_RED}/}
    color=${color//${COLOR_YELLOW}/}
    color=${color//${COLOR_BLUE}/}
    color=${color//${FORMATTING_BOLD}/}
    length=${#color}
    echo "$(( wanted_length + original_length - length ))"
}

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
            if [ "$MAX_LOG_LEVEL" == "$LOG_DEBUG" ]; then 
                printf "%-$(log_level_length $log_level 8)b %-55s %s\n" "$(log_level_color $log_level)" "($(realpath --relative-to="$this_script_dir" "${BASH_SOURCE[1]}"): <${FUNCNAME[1]}: ${BASH_LINENO[0]}>)" "$message" >&2
            elif [ "$MAX_LOG_LEVEL" == "$LOG_VERBOSE" ]; then
                printf "%-$(log_level_length $log_level 8)b %-35s %s\n" "$(log_level_color $log_level)" "<${FUNCNAME[1]}: ${BASH_LINENO[0]}>" "$message" >&2
            else
                printf "%-$(log_level_length $log_level 8)b %s\n" "$(log_level_color $log_level)" "$message" >&2
            fi
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
