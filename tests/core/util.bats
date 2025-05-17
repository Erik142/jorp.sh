setup() {
  source "${TOP}"/tests/common.sh
  common_setup

  source "${TOP}"/core/utils.sh
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
