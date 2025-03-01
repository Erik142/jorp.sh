#!/usr/bin/env bash

GIT_REMOTE_PREFIX="Git Remote"
GIT_REMOTE_SUBMENU="Clone repository"

function git_remote_get_prefix() {
  echo "$GIT_REMOTE_PREFIX"
}

function git_remote_get_capabilities() {
  echo "$CAPABILITY_SUBMENU"
}

function git_remote_get_items() {
  echo "$GIT_REMOTE_SUBMENU"
}

function git_remote_show_submenu() {
  clear
  read -rp "Enter Git repository remote url: " remote_repo_url

  git_remote_repos_path="$(config_get_item "$CONFIG_GIT_REMOTE_REPOS_PATH")"
  git_remote_repos_path="$(realpath "$(echo "$git_remote_repos_path" | envsubst)")"

  if [ -n "$git_remote_repos_path" ]; then
    local_repo_path="${git_remote_repos_path}/$(basename "$remote_repo_url" | sed "s|\.git\$||")"
  else
    local_repo_path=""
  fi

  read -r -e -p "Enter local Git clone path: " -i "$local_repo_path" local_repo_path


  if [[ ! -d "$(dirname "$local_repo_path")" ]]; then
    log_debug "'$local_repo_path' does not exist."
    if ! mkdir -p "$(dirname "$local_repo_path")"; then
      log_err "Could not create the directory '$(dirname "$local_repo_path")'"
      exit 1
    fi
  fi

  if ! git clone -q "$remote_repo_url" "$local_repo_path"; then
    log_err "Could not clone git repository!"
    exit 1
  fi

  session_name="$(get_session_name "$local_repo_path")"
  tmuxinator start code-project workspace="$local_repo_path" -n "$session_name"
}
