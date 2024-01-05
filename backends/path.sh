PATH_PREFIX="Path"
PATH_SUBMENU="Enter Custom Path"

function path_get_prefix() {
  echo "$PATH_PREFIX"
}

function path_get_capabilities() {
  echo "$CAPABILITY_SUBMENU"
}

function path_get_items() {
  echo "$PATH_SUBMENU"
}

function path_show_submenu() {
  clear
  read -p "Enter custom path to project: " project_path
  project_path=$(echo "$project_path" | sed "s|~|$HOME|g")

  if [[ ! -d "$project_path" ]]; then
    log "$LOG_ERROR" "'$project_path' does not exist."
    exit 1
  fi

  session_name="$(get_session_name $project_path)"
  tmuxinator start code-project workspace="$project_path" -n "$session_name"
}
