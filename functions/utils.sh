#!/usr/bin/env bash

function get_session_name() {
  local leaf_path
  local final_path

  leaf_path=$(basename "$1")

  ifs=$IFS
  IFS='/'
  read -ra all_dirs <<< "${1:1}"
  IFS="$ifs"
  unset "all_dirs[${#all_dirs[@]}-1]"

  final_path=""

  if (( ${#all_dirs[@]} >= 1 )); then
    for dir in "${all_dirs[@]}"
    do
      if [[ "${dir:0:1}" != "." ]]; then
        final_path="$final_path/${dir:0:1}"
      else
        final_path="$final_path/_"
      fi
    done
  fi

  final_path="$final_path/$leaf_path"
  final_path=${final_path//./_}

  echo "$final_path-$(date +%Y%m%d-%H%M%S)"
}
