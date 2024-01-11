GIT_PREFIX="Git"
GIT_SUBMENU="Find Git repositories"

GIT_DEFAULT_ACTION='cd ${git_repository_path}'

declare -a GIT_PROJECT_DIRS
declare -a GIT_EXCLUDED_DIRS

function git_init(){
  mapfile -t GIT_PROJECT_DIRS < <(config_get_item "$CONFIG_GIT_PROJECT_DIRS")
  mapfile -t GIT_EXCLUDED_DIRS < <(config_get_item "$CONFIG_GIT_EXCLUDED_DIRS")
}

function git_get_prefix() {
  echo "$GIT_PREFIX"
}

function git_get_capabilities() {
  echo "$CAPABILITY_SUBMENU|$CAPABILITY_REQUIRE_INIT"
}

function git_get_items() {
  echo "$GIT_SUBMENU"
}

function git_get_submenu_items() {
  exclude_str=""
  for exclude_dir in "${GIT_EXCLUDED_DIRS[@]}";
  do
    exclude_dir="$(echo $exclude_dir | sed 's|\/|\\\/|g')"
    exclude_dir="$(echo $exclude_dir | sed 's|\.|\\\.|g')"
    exclude_str="${exclude_str} --exclude \"${exclude_dir}\""
  done

  search_dirs=""

  for search_dir in "${GIT_PROJECT_DIRS[@]}";
  do
    search_dirs="${search_dirs} --search-path ${search_dir}"

    if [[ "$search_dir" != *"/" ]]; then
      search_dir="${search_dir}/"
    fi
    search_filter="$(echo $search_dir | sed -e 's|\.|\\\.|g')"
    search_filter="$(echo $search_filter | sed -e 's|\/|\\\\\\\/|g')"
    exclude_str="$(echo $exclude_str | sed "s|$search_filter||g")"
  done

  extra_fd_args="$(config_get_item "$CONFIG_GIT_EXTRA_FD_ARGS")"
  fd_command="fd -u '^\.git$' --prune $exclude_str --type d $search_dirs $extra_fd_args -X printf '%s\\n' '{//}'"
  log "$LOG_DEBUG" "Exclude dirs: '$exclude_str'"
  log "$LOG_DEBUG" "Search filter: '$search_filter'"
  log "$LOG_DEBUG" "Search dir: '$search_dir'"
  log "$LOG_DEBUG" "fd command is: '$fd_command'"
  eval "$fd_command"
}

function git_select_submenu_item() {
  if [ ! -d "$1" ]; then
    log "$LOG_ERROR" "The directory '$1' does not exist"
  fi

  # The following variables are available upon terminal multiplexer session
  # creation
  git_repository_path="$1"
  git_repository_name="$(basename "$git_repository_path")"
  git_repository_parent_dir="$(dirname "$git_repository_path")"
  session_name="$(get_session_name "$git_repository_path")"

  action="$(config_get_item "$CONFIG_GIT_ACTION")"

  if [ -z "$action" ]; then
    action="$GIT_DEFAULT_ACTION"
    log "$LOG_VERBOSE" "Executing default git action: '$action'"
  fi

  eval "$action"
}
