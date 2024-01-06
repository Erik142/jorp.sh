#!/usr/bin/env bash

jq="jq -r -c"

CONFIG_GENERAL_MAX_LOG_LEVEL="'.general.max_log_level'"
CONFIG_GIT_PROJECT_DIRS="'.git.project_dirs.[]'"
CONFIG_GIT_EXCLUDED_DIRS="'.git.excluded_dirs.[]'"
CONFIG_GIT_EXTRA_FD_ARGS="'.git.extra_fd_args'"
CONFIG_SCRATCHPAD_DEFAULT_NAME="'.scratchpad.default_name'"
CONFIG_TMUX_EXTRA_OPTIONS="'.tmux.extra_options'"

CUSTOM_CONFIG_FILE_PATH=""

config_sample_file_path="$this_script_dir/samples/config.json"

function config_get_file_path() {
  config_file_location="$CUSTOM_CONFIG_FILE_PATH" 

  if [ -z "$config_file_location" ]; then
    if [ -n "$XDG_CONFIG_HOME" ]; then
      config_file_location="$XDG_CONFIG_HOME/project-manager/config.json"
    else
      config_file_location="$HOME/.config/project-manager/config.json"
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
      mkdir -p "$(dirname $config_file)"
      cp "$config_sample_file_path" "$config_file"
    elif [ -n "$CUSTOM_CONFIG_FILE_PATH" ]; then
      log "$LOG_ERROR" "Custom configuration file '$CUSTOM_CONFIG_FILE_PATH' does not exist. Exiting..."
      exit 1
    fi
  fi
}

function config_get_item() {
  config_file="$(config_get_file_path)"
  config_item="$(eval $jq "$1" "$config_file")"

  if [ $? -ne 0 ]; then
    log "$LOG_VERBOSE" "Could not retrieve configuration item '$1'"
    return
  fi

  echo "$config_item"
}
