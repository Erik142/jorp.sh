setup() {
  source "${TOP}"/tests/common.sh
  common_setup

  source "${TOP}"/functions/utils.sh
}

@test "can call log_init with valid argument" {
  for log_level in "${!LOG_LEVELS[@]}"; do
    run log_init "$log_level"
    assert_success
    assert_equal "$MAX_LOG_LEVEL" "$log_level"
  done
}

@test "cannot call log_init with invalid argument" {
  run log_init "hej"
  assert_failure
}


@test "can call log_init with empty argument" {
  assert log_init ""
  assert_equal "$DEFAULT_LOG_LEVEL" "$MAX_LOG_LEVEL"
}

@test "cannot log with invalid number of arguments" {
  run log
  assert_failure

  run log "1" "2" "3"
  assert_failure
}

@test "can log with valid number of arguments" {
  run log "This is a log message"
  assert_success

  run log "$LOG_INFO" "This is also a log message"
  assert_success
}

@test "log level configuration functions properly" {
  run log_init "$LOG_DEBUG"
  local level=""

  for level in "${!LOG_LEVELS[@]}"; do
    echo "$level"
    run log "$level" "This is a log message"
    assert_success
    assert_output --partial "$level"
  done
}

@test "session names without dots resolve correctly" {
  directory_path="/Test/my/directory/Is/parsing/Correctly"
  expected_session_name="/T/m/d/I/p/Correctly"

  run get_session_name "$directory_path"

  assert_output --regexp "^${expected_session_name}-"
}

@test "session names with leading dots resolve correctly" {
  directory_path="/Test/my/.directory/Is/parsing/.Correctly"
  expected_session_name="/T/m/_/I/p/_Correctly"

  run get_session_name "$directory_path"

  assert_output --regexp "^${expected_session_name}-"
}

@test "session names with trailing dots resolve correctly" {
  directory_path="/Test/my/directory./Is/parsing/Correctly."
  expected_session_name="/T/m/d/I/p/Correctly_"

  run get_session_name "$directory_path"

  assert_output --regexp "^${expected_session_name}-"
}

@test "session names with dots in the middle resolve correctly" {
  directory_path="/Test/my/direc.tory/Is/parsing/Correct.ly"
  expected_session_name="/T/m/d/I/p/Correct_ly"

  run get_session_name "$directory_path"

  assert_output --regexp "^${expected_session_name}-"
}
