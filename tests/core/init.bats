setup() {
  source "${TOP}/tests/common.sh"
  common_setup

  THIS_SCRIPT_DIR="${TOP}"
  export THIS_SCRIPT_DIR

  source "${TOP}/core/init.sh"
}

@test "parse_batch_command handles a backend with no extra arguments" {
  parse_batch_command "scratchpad"

  assert_equal "$batch_backend" "scratchpad"
  assert_equal "$batch_command_args" ""
}

@test "parse_batch_command splits backend name from its arguments" {
  parse_batch_command "scratchpad myname y"

  assert_equal "$batch_backend" "scratchpad"
  assert_equal "$batch_command_args" "myname y"
}
