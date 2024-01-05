#!/usr/bin/env bash

jq="jq -r -c"

CONFIG_GENERAL_MAX_LOG_LEVEL="'.general.max_log_level'"
CONFIG_GIT_PROJECT_DIRS="'.git.project_dirs.[]'"
CONFIG_GIT_EXCLUDED_DIRS="'.git.excluded_dirs.[]'"
CONFIG_TMUX_EXTRA_OPTIONS="'.tmux.extra_options'"

config_sample_file_path="$this_script_dir/samples/config.json"

function config_get_file_path() {
  config_file_location="" 

  if [ -n "$XDG_CONFIG_HOME" ]; then
    config_file_location="$XDG_CONFIG_HOME/project-manager/config.json"
  else
    config_file_location="$HOME/.config/project-manager/config.json"
  fi

  echo "$config_file_location"
}

function config_init() {
  # TODO: Support custom configuration file locations
  config_file="$(config_get_file_path)"

  if [ ! -e "$config_file" ]; then
    log "$LOG_VERBOSE" "No configuration file found. Copying sample configuration to '$config_file'"
    mkdir -p "$(dirname $config_file)"
    cp "$config_sample_file_path" "$config_file"
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
