setup() {
  source "${TOP}/tests/common.sh"
  common_setup

  THIS_SCRIPT_DIR="${TOP}"
  export THIS_SCRIPT_DIR

  source "${TOP}/log.sh/src/log.sh"
  source "${TOP}/backends/capabilities.sh"
  source "${TOP}/backends/git.sh"

  # shellcheck disable=SC2016,SC2329
  function config_get_item() { echo 'echo "action-ran:${git_repository_path}"'; }
}

@test "git_select_submenu_item runs the configured action for an existing directory" {
  run git_select_submenu_item "${TOP}"

  assert_success
  assert_output --partial "action-ran:${TOP}"
}

@test "git_select_submenu_item does not run the configured action for a missing directory" {
  run git_select_submenu_item "${TOP}/does-not-exist"

  assert_failure
  refute_output --partial "action-ran:"
}
