setup() {
  source "${TOP}/tests/common.sh"
  common_setup

  THIS_SCRIPT_DIR="${TOP}"
  export THIS_SCRIPT_DIR

  source "${TOP}/log.sh/src/log.sh"
  source "${TOP}/backends/capabilities.sh"
  source "${TOP}/backends/scratchpad.sh"

  # shellcheck disable=SC2329
  function tmux_select_item() {
    if [ -z "$1" ]; then
      echo "ERROR: tmux_select_item called with an empty session name" >&2
      return 1
    fi

    echo "selected:$1"
  }

  # shellcheck disable=SC2016,SC2329
  function config_get_item() { echo 'echo "created:${session_name}"'; }
}

@test "scratchpad_run_batch opens an existing session when one matches" {
  # shellcheck disable=SC2329
  function tmux_get_items() { echo "scratch-20240101-000000"; }

  run scratchpad_run_batch "scratch" "y"

  assert_success
  assert_output --partial "selected:scratch-20240101-000000"
  refute_output --partial "created:"
}

@test "scratchpad_run_batch creates a new session when no existing session matches" {
  # shellcheck disable=SC2329
  function tmux_get_items() { echo ""; }

  run scratchpad_run_batch "scratch" "y"

  assert_success
  refute_output --partial "ERROR: tmux_select_item called with an empty session name"
  assert_output --partial "created:scratch-"
}
