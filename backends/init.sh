#!/usr/bin/env bash

. $this_script_dir/backends/capabilities.sh
. $this_script_dir/backends/tmux.sh
. $this_script_dir/backends/git.sh
. $this_script_dir/backends/path.sh
. $this_script_dir/backends/scratchpad.sh

backends=("tmux" "git" "path" "scratchpad" )

declare -a BACKEND_ITEMS

function get_items() {
  remove="$1"
  BACKEND_ITEMS=()
  index=0
  for backend in "${backends[@]}";
  do
    log "$LOG_DEBUG" "Processing backend: $backend"
    if [ "$remove" == "y" ]; then
      if [ "$(backend_has_removal "$backend")" != "y" ]; then
        log "$LOG_DEBUG" "Backend '$backend' does not support removal of items, skipping..."
        continue
      else
        log "$LOG_DEBUG" "Backend '$backend' supports removal of items..."
      fi
    fi

    prefix="$(${backend}_get_prefix)" 
    mapfile -t backend_items < <(${backend}_get_items)

    for backend_item in "${backend_items[@]}";
    do
      BACKEND_ITEMS[$index]="$prefix: $backend_item"
      index=$((index + 1)) 
    done
  done

  for item in "${BACKEND_ITEMS[@]}";
  do
    log "$LOG_DEBUG" "$item"
  done
}

function get_backend_from_prefix() {
  for backend in "${backends[@]}";
  do
    prefix="$(${backend}_get_prefix)"
    if [ "$prefix" == "$1" ]; then
      echo "$backend"
      return
    fi
  done

  log "$LOG_ERROR" "The prefix '$1' does not correspond to any registered backend"
}

function find_and_execute_backend_function() {
  function="$1"
  chosen_backend="$2"
  shift 2

  for backend in "${backends[@]}";
  do
    if [ "$backend" == "$chosen_backend" ]; then
      declare -F "${backend}_${function}" > /dev/null;
      
      if [ "$?" -ne "0" ]; then
        log "$LOG_ERROR" "The function '${backend}_${function} does not exist"
        exit 1
      fi
    
      ${backend}_${function} "$@"
      return
    fi
  done

  log "$LOG_ERROR" "The backend '$chosen_backend' is not valid"
  exit 1
}

function select_item() {
  find_and_execute_backend_function "select_item" "$@"
}

function remove_item() {
  find_and_execute_backend_function "remove_item" "$@"
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

function show_submenu() {
  local backend="$1"
  if [[ "$(find_and_execute_backend_function "get_capabilities" "$backend")" != *"$CAPABILITY_SUBMENU"* ]]; then
    log "$LOG_DEBUG" "The backend '$backend' does not have a submenu"
    exit 1
  fi

  declare -F "${backend}_show_submenu" > /dev/null;

  if [ "$?" -eq "0" ]; then 
    log "$LOG_DEBUG" "The backend '$backend' implements a custom submenu. Showing it..."
    find_and_execute_backend_function "show_submenu" "$backend"
  else
    log "$LOG_DEBUG" "The backend '$backend' does not implement a custom submenu. Showing standard submenu..."
    mapfile -t submenu_items < <(find_and_execute_backend_function "get_submenu_items" "$backend")

    selected_item="$(printf "%s\n" "${submenu_items[@]}" | fzf)"

    if [ -z "$selected_item" ]; then
        log "$LOG_WARNING" "The user did not select an item"
        exit 0
    fi

    log "$LOG_DEBUG" "Selected submenu item: $selected_item"
    find_and_execute_backend_function "select_submenu_item" "$backend" "$selected_item"
  fi
}
