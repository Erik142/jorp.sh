#!/usr/bin/env bash

. "$THIS_SCRIPT_DIR/backends/capabilities.sh"
. "$THIS_SCRIPT_DIR/backends/tmux.sh"
. "$THIS_SCRIPT_DIR/backends/git.sh"
. "$THIS_SCRIPT_DIR/backends/git_remote.sh"
. "$THIS_SCRIPT_DIR/backends/path.sh"
. "$THIS_SCRIPT_DIR/backends/scratchpad.sh"

backends=("tmux" "git" "git_remote" "path" "scratchpad" )

declare -a BACKEND_ITEMS

function backend_init() {
  for backend in "${backends[@]}";
  do
    if [ "$(backend_require_init "$backend")" == "y" ]; then
      log_debug "Executing init function for backend '$backend'"
      find_and_execute_backend_function "init" "$backend"
    fi
  done
}

function get_items() {
  remove="$1"
  BACKEND_ITEMS=()
  index=0
  for backend in "${backends[@]}";
  do
    log_debug "Processing backend: $backend"
    if [ "$remove" == "y" ]; then
      if [ "$(backend_has_removal "$backend")" != "y" ]; then
        log_debug "Backend '$backend' does not support removal of items, skipping..."
        continue
      else
        log_debug "Backend '$backend' supports removal of items..."
      fi
    fi

    prefix="$("${backend}"_get_prefix)"
    mapfile -t backend_items < <("${backend}"_get_items)

    for backend_item in "${backend_items[@]}";
    do
      BACKEND_ITEMS[index]="$prefix: $backend_item"
      index=$((index + 1))
    done
  done

  for item in "${BACKEND_ITEMS[@]}";
  do
    log_debug "$item"
  done
}

function get_backend_from_prefix() {
  for backend in "${backends[@]}";
  do
    prefix="$("${backend}"_get_prefix)"
    if [ "$prefix" == "$1" ]; then
      echo "$backend"
      return
    fi
  done

  log_err "The prefix '$1' does not correspond to any registered backend"
}

function find_and_execute_backend_function() {
  function="$1"
  chosen_backend="$2"
  shift 2

  for backend in "${backends[@]}";
  do
    if [ "$backend" == "$chosen_backend" ]; then
      if ! declare -F "${backend}_${function}" > /dev/null; then
        log_err "The function '${backend}_${function} does not exist"
        exit 1
      fi

      "${backend}"_"${function}" "$@"
      return
    fi
  done

  log_err "The backend '$chosen_backend' is not valid"
  exit 1
}

function select_item() {
  find_and_execute_backend_function "select_item" "$@"
}

function remove_item() {
  find_and_execute_backend_function "remove_item" "$@"
}

function backend_require_init() {
  [[ "$(find_and_execute_backend_function "get_capabilities" "$backend")" == *"$CAPABILITY_REQUIRE_INIT"* ]] && \
    echo "y" || echo "n"
}

function backend_has_removal() {
  [[ "$(find_and_execute_backend_function "get_capabilities" "$backend")" == *"$CAPABILITY_ITEM_REMOVAL"* ]] && \
    echo "y" || echo "n"
}

function backend_has_submenu() {
  [[ "$(find_and_execute_backend_function "get_capabilities" "$backend")" == *"$CAPABILITY_SUBMENU"* ]] && \
    echo "y" || echo "n"
}

function backend_has_batch() {
  [[ "$(find_and_execute_backend_function "get_capabilities" "$backend")" == *"$CAPABILITY_BATCH"* ]] && \
    echo "y" || echo "n"
}

function backend_has_lastitem() {
  [[ "$(find_and_execute_backend_function "get_capabilities" "$backend")" == *"$CAPABILITY_SELECT_LAST_ITEM"* ]] && \
    echo "y" || echo "n"
}

function show_submenu() {
  local backend="$1"
  if [[ "$(find_and_execute_backend_function "get_capabilities" "$backend")" != *"$CAPABILITY_SUBMENU"* ]]; then
    log_debug "The backend '$backend' does not have a submenu"
    exit 1
  fi

  if declare -F "${backend}_show_submenu" > /dev/null; then
    log_debug "The backend '$backend' implements a custom submenu. Showing it..."
    find_and_execute_backend_function "show_submenu" "$backend"
  else
    log_debug "The backend '$backend' does not implement a custom submenu. Showing standard submenu..."
    mapfile -t submenu_items < <(find_and_execute_backend_function "get_submenu_items" "$backend")

    fzf_options="$(config_get_item "$CONFIG_FZF_EXTRA_OPTIONS")"
    selected_item="$(printf "%s\n" "${submenu_items[@]}" | eval fzf "$fzf_options")"

    if [ -z "$selected_item" ]; then
        log_warn "The user did not select an item"
        exit 0
    fi

    log_debug "Selected submenu item: $selected_item"
    find_and_execute_backend_function "select_submenu_item" "$backend" "$selected_item"
  fi
}

function select_last_item() {
  if [[ "$(backend_has_lastitem "$backend")" == "n" ]]; then
    log_err "The backend '$backend' does not support selection of last item"
    exit 1
  fi

  find_and_execute_backend_function "select_last_item" "$backend"
}
