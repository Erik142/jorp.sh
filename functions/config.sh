#!/usr/bin/env bash

jq="jq -r -c -e"

CONFIG_GENERAL_MAX_LOG_LEVEL=".general.max_log_level"
CONFIG_GIT_PROJECT_DIRS=".git.project_dirs.[]"
CONFIG_GIT_EXCLUDED_DIRS=".git.excluded_dirs.[]"
CONFIG_GIT_EXTRA_FD_ARGS=".git.extra_fd_args"
CONFIG_GIT_ACTION=".git.action"
CONFIG_SCRATCHPAD_DEFAULT_NAME=".scratchpad.default_name"
CONFIG_SCRATCHPAD_ACTION=".scratchpad.action"
CONFIG_TMUX_EXTRA_OPTIONS=".tmux.extra_options"
CONFIG_FZF_EXTRA_OPTIONS=".general.fzf.extra_options"

export CONFIG_GENERAL_MAX_LOG_LEVEL
export CONFIG_GIT_PROJECT_DIRS
export CONFIG_GIT_EXCLUDED_DIRS
export CONFIG_GIT_EXTRA_FD_ARGS
export CONFIG_GIT_ACTION
export CONFIG_SCRATCHPAD_DEFAULT_NAME
export CONFIG_SCRATCHPAD_ACTION
export CONFIG_TMUX_EXTRA_OPTIONS
export CONFIG_FZF_EXTRA_OPTIONS

CUSTOM_CONFIG_FILE_PATH=""

config_sample_file_path="$THIS_SCRIPT_DIR/samples/config.json"

function config_get_file_path() {
  config_file_location="$CUSTOM_CONFIG_FILE_PATH" 

  if [ -z "$config_file_location" ]; then
    if [ -n "$XDG_CONFIG_HOME" ]; then
      config_file_location="$XDG_CONFIG_HOME/jorp.sh/config.json"
    else
      config_file_location="$HOME/.config/jorp.sh/config.json"
    fi
  fi

  echo "$config_file_location"
}

function config_init() {
  CUSTOM_CONFIG_FILE_PATH="$1"
  config_file="$(config_get_file_path)"

  if [ ! -e "$config_file" ]; then
    if [ -z "$CUSTOM_CONFIG_FILE_PATH" ]; then
      log "$LOG_VERBOSE" "No configuration file found. Copying sample configuration to '$config_file'"
      mkdir -p "$(dirname "$config_file")"
      cp "$config_sample_file_path" "$config_file"
    elif [ -n "$CUSTOM_CONFIG_FILE_PATH" ]; then
      log "$LOG_ERROR" "Custom configuration file '$CUSTOM_CONFIG_FILE_PATH' does not exist. Exiting..."
      exit 1
    fi
  fi
}

function config_get_item() {
  config_file="$(config_get_file_path)"
  if ! eval "$jq" "$1" "$config_file" 2> /dev/null; then
    log "$LOG_VERBOSE" "Could not retrieve configuration item $1"
    return
  fi
}
