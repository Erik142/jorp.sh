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
