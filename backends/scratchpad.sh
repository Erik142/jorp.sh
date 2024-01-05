SCRATCHPAD_PREFIX="Scratchpad"
SCRATCHPAD_SUBMENU="Create new scratchpad"

function scratchpad_get_prefix() {
  echo "$SCRATCHPAD_PREFIX"
}

function scratchpad_get_capabilities() {
  echo "$CAPABILITY_SUBMENU"
}

function scratchpad_get_items() {
  echo "$SCRATCHPAD_SUBMENU"
}

function scratchpad_show_submenu() {
  clear
  read -e -p "Enter name of scratchpad: " -i "scratch" scratchpad_name

  if [ -z "$scratchpad_name" ]; then
    log "$LOG_ERROR" "Scratchpad name is empty."
    exit 1
  fi

  session_name="${scratchpad_name}-$(date +%Y%m%d-%H%M%S)"
  tmuxinator start scratchpad -n "$session_name"

  if [[ "$TERM_PROGRAM" == "tmux" ]]; then
    tmux $TMUX_OPTS switch -t "$session_name"
  else
    tmux $TMUX_OPTS attach-session -t "$session_name"
  fi
}
