#!/usr/bin/env bash

TMUX_PREFIX="Tmux"

function tmux_get_prefix() {
  echo "$TMUX_PREFIX"
}

function tmux_get_capabilities() {
  echo "$CAPABILITY_ITEM_REMOVAL"
}

function tmux_get_items() {
  tmux ls | cut -d: -f1
}

function tmux_session_exists() {
  session_exists=n
  mapfile -t tmux_sessions < <(tmux_get_items)

  for session in "${tmux_sessions[@]}";
  do
    if [[ "$session" == "$1" ]]; then
      session_exists=y
      break
    fi
  done

  echo "$session_exists"
}

function tmux_select_item() {
  session_exists="$(tmux_session_exists "$1")"

  if [ "$session_exists" != "y" ]; then
    log "$LOG_ERROR" "The tmux session '$1' does not exist"
    exit 1
  fi

  if [[ "$TERM_PROGRAM" == "tmux" ]]; then
    tmux switch -t "$1" 2>&1 > /dev/null
  else
    tmux attach-session -t "$1" 2>&1 > /dev/null
  fi
}

function tmux_remove_item() {
  session_exists="$(tmux_session_exists "$1")"

  if [ "$session_exists" == "n" ]; then
    log "$LOG_ERROR" "The tmux session '$1' does not exist"
    exit 1
  fi

  tmux kill-session -t "$1" 2>&1 > /dev/null
}
