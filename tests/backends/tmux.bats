setup() {
  source "${TOP}/tests/common.sh"
  common_setup

  THIS_SCRIPT_DIR="${TOP}"
  export THIS_SCRIPT_DIR

  source "${TOP}/log.sh/src/log.sh"
  source "${TOP}/backends/capabilities.sh"
  source "${TOP}/backends/tmux.sh"

  tmux_args_file="${BATS_TEST_TMPDIR}/tmux_args"

  # shellcheck disable=SC2329
  function tmux() {
    if [[ "$1" == "ls" ]]; then
      echo "My Project-20240101-000000: 1 windows"
      return 0
    fi

    {
      echo "ARGC:$#"
      printf 'ARG:%s\n' "$@"
    } > "$tmux_args_file"
  }
}

@test "tmux_remove_item passes a session name with spaces through as a single argument" {
  run tmux_remove_item "My Project-20240101-000000"

  assert_success
  run cat "$tmux_args_file"
  assert_output --partial "ARGC:3"
  assert_output --partial "ARG:My Project-20240101-000000"
}

@test "tmux_select_item passes a session name with spaces through as a single argument" {
  run tmux_select_item "My Project-20240101-000000"

  assert_success
  run cat "$tmux_args_file"
  assert_output --partial "ARGC:3"
  assert_output --partial "ARG:My Project-20240101-000000"
}

@test "tmux_init expands variables in extra_options into separate arguments" {
  # shellcheck disable=SC2016,SC2329
  function config_get_item() { echo '-u -S $HOME/.tmux.sock'; }

  # log_debug touches file descriptor 3, which bats also uses for its own
  # bookkeeping, so it must run inside the run() subshell, not the test body.
  # shellcheck disable=SC2329
  print_opts() {
    HOME="/home/testuser" tmux_init
    printf '%s\n' "${TMUX_OPTS_ARRAY[@]}"
  }
  run print_opts

  assert_success
  assert_output --partial "
-u
-S
/home/testuser/.tmux.sock"
}

@test "tmux_get_items uses the extra_options socket configured via tmux_init" {
  # shellcheck disable=SC2016,SC2329
  function config_get_item() { echo '-u -S $HOME/.tmux.sock'; }

  # shellcheck disable=SC2329
  init_and_list() {
    HOME="/home/testuser" tmux_init
    tmux_get_items
  }
  run init_and_list

  run cat "$tmux_args_file"
  assert_output --partial "ARG:-u"
  assert_output --partial "ARG:-S"
  assert_output --partial "ARG:/home/testuser/.tmux.sock"
}

@test "tmux_remove_item logs the tmux error instead of discarding it" {
  # shellcheck disable=SC2329
  function tmux() {
    if [[ "$1" == "ls" ]]; then
      echo "My Project-20240101-000000: 1 windows"
      return 0
    fi

    echo "session not found: My Project-20240101-000000" >&2
    return 1
  }

  run tmux_remove_item "My Project-20240101-000000"

  assert_failure
  assert_output --partial "session not found: My Project-20240101-000000"
}
