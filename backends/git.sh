GIT_PREFIX="Git"
GIT_SUBMENU="Find Git repositories"

function git_get_prefix() {
  echo "$GIT_PREFIX"
}

function git_get_capabilities() {
  echo "$CAPABILITY_SUBMENU"
}

function git_get_items() {
  echo "$GIT_SUBMENU"
}

function git_get_submenu_items() {
fd -u '^\.git$' --prune --exclude "\.local\/share" --exclude "Library" --exclude "\.tmux" --exclude "\.emacs\.d" --exclude "\.cargo" --type d --search-path "$HOME" -X printf '%s\n' '{//}'
}

function git_select_submenu_item() {
  if [ ! -d "$1" ]; then
    log "$LOG_ERROR" "The directory '$1' does not exist"
  fi

  session_name="$(get_session_name "$1")"
  tmuxinator start code-project workspace="$1" -n "$session_name"
}
