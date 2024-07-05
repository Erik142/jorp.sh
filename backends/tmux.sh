#!/usr/bin/env bash

TMUX_PREFIX="Tmux"

TMUX_OPTS=""

function tmux_init() {
  TMUX_OPTS="$(config_get_item "$CONFIG_TMUX_EXTRA_OPTIONS")"
  if [ -n "$TMUX_OPTS" ]; then
    log_debug "Extra tmux options are: '$TMUX_OPTS'"
  fi
}

function tmux_get_prefix() {
  echo "$TMUX_PREFIX"
}

function tmux_get_capabilities() {
  echo "$CAPABILITY_ITEM_REMOVAL|$CAPABILITY_REQUIRE_INIT|$CAPABILITY_SELECT_LAST_ITEM"
}

function tmux_get_items() {
  log_debug "Executing command 'tmux $TMUX_OPTS ls'"
  eval tmux "$TMUX_OPTS" ls | cut -d: -f1
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
    log_err "The tmux session '$1' does not exist"
    exit 1
  fi

  if [[ "$TERM_PROGRAM" == "tmux" ]]; then
    eval tmux "$TMUX_OPTS" switch -t "$1" > /dev/null 2>&1
  else
    eval tmux "$TMUX_OPTS" attach-session -t "$1" > /dev/null 2>&1
  fi
}

function tmux_select_last_item() {
  local last_session
  last_session="$(tmux display-message -p "#{client_last_session}")"

  if [ -z "$last_session" ]; then
    log_warn "Could not find last tmux session"
    exit 0
  fi

  tmux_select_item "$last_session"
}

function tmux_remove_item() {
  session_exists="$(tmux_session_exists "$1")"

  if [ "$session_exists" == "n" ]; then
    log_err "The tmux session '$1' does not exist"
    exit 1
  fi

  eval tmux "$TMUX_OPTS" kill-session -t "$1" > /dev/null 2>&1
}
