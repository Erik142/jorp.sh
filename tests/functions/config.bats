setup() {
  source "${TOP}/tests/common.sh"
  common_setup

  THIS_SCRIPT_DIR="${TOP}"
  CONFIG_DIR="$(mktemp -d)"
  DEFAULT_HOME="${HOME}"
  HOME="${CONFIG_DIR}"
  CUSTOM_CONFIG_FILE_PATH=""

  export THIS_SCRIPT_DIR
  export CONFIG_DIR
  export DEFAULT_HOME
  export HOME
  export CUSTOM_CONFIG_FILE_PATH

  source "${TOP}"/functions/config.sh
  source "${TOP}"/log.sh/src/log.sh
}

teardown() {
  if [ -d "${CONFIG_DIR}" ]; then
    rm -rf "${CONFIG_DIR}"
  fi

  if [ "${DEFAULT_HOME}" != "${HOME}" ]; then
    export HOME="${DEFAULT_HOME}"
  fi
}

@test "can get config file location with XDG_CONFIG_HOME set" {
  expected_config_file_location="${CONFIG_DIR}/jorp.sh/config.json"
  XDG_CONFIG_HOME="${CONFIG_DIR}" run config_get_file_path

  assert_success
  assert_output "${expected_config_file_location}"
}

@test "can get config file location with XDG_CONFIG_HOME unset" {
  unset XDG_CONFIG_HOME

  expected_config_file_location="${HOME}/.config/jorp.sh/config.json"
  run config_get_file_path

  assert_success
  assert_output "${expected_config_file_location}"
}

@test "can get config file location with custom config path" {
  expected_config_file_location="${CONFIG_DIR}/.config/jorp.sh/config.json"
  export CUSTOM_CONFIG_FILE_PATH="${expected_config_file_location}"
  HOME="${HOME}" run config_get_file_path

  assert_success
  assert_output "${expected_config_file_location}"
}

@test "can init without a config file in default location" {
  expected_config_file_location="${CONFIG_DIR}/jorp.sh/config.json"
  assert [ ! -e "$expected_config_file_location" ]

  XDG_CONFIG_HOME="${CONFIG_DIR}" run config_init

  assert_success
  assert [ -f "$expected_config_file_location" ]
}

@test "can init with a config file in default location" {
  expected_config_file_location="${CONFIG_DIR}/jorp.sh/config.json"

  assert [ ! -e "$expected_config_file_location" ]
  assert [ -d "$CONFIG_DIR" ]

  mkdir -p "$(dirname "$expected_config_file_location")"
  cp "${TOP}/tests/samples/config.json" "$expected_config_file_location"
  config_hashsum_before="$(sha256sum "$expected_config_file_location" | cut -d" " -f1)"

  assert [ -n "$config_hashsum_before" ]

  XDG_CONFIG_HOME="${CONFIG_DIR}" run config_init

  assert_success

  config_hashsum_after="$(sha256sum "$expected_config_file_location" | cut -d" " -f1)"

  assert [ "$config_hashsum_after" == "$config_hashsum_before" ]
}

@test "can init with custom config file" {
  expected_config_file_location="${CONFIG_DIR}/jorp.sh/config.json"

  assert [ ! -e "$expected_config_file_location" ]
  assert [ -d "$CONFIG_DIR" ]

  mkdir -p "$(dirname "$expected_config_file_location")"
  cp "${TOP}/tests/samples/config.json" "$expected_config_file_location"
  config_hashsum_before="$(sha256sum "$expected_config_file_location" | cut -d" " -f1)"

  assert [ -n "$config_hashsum_before" ]

  run config_init "$expected_config_file_location"

  assert_success

  config_hashsum_after="$(sha256sum "$expected_config_file_location" | cut -d" " -f1)"

  assert [ "$config_hashsum_after" == "$config_hashsum_before" ]
}

@test "cannot init with non-existent custom config file" {
  expected_config_file_location="${CONFIG_DIR}/jorp.sh/config.json"

  assert [ ! -e "$expected_config_file_location" ]
  assert [ -d "$CONFIG_DIR" ]

  run config_init "$expected_config_file_location"

  assert_failure
}

@test "can retrieve valid config item" {
  expected_config_file_location="${CONFIG_DIR}/jorp.sh/config.json"

  assert [ ! -e "$expected_config_file_location" ]
  assert [ -d "$CONFIG_DIR" ]

  mkdir -p "$(dirname "$expected_config_file_location")"
  cp "${TOP}/tests/samples/config.json" "$expected_config_file_location"

  assert [ -f "$expected_config_file_location" ]

  XDG_CONFIG_HOME="${CONFIG_DIR}" config_init

  XDG_CONFIG_HOME="${CONFIG_DIR}" run config_get_item "$CONFIG_GENERAL_MAX_LOG_LEVEL"
  assert_success

  assert_output "DEBUG"
}

@test "cannot retrieve valid non-existent config item" {
  expected_config_file_location="${CONFIG_DIR}/jorp.sh/config.json"

  assert [ ! -e "$expected_config_file_location" ]
  assert [ -d "$CONFIG_DIR" ]

  mkdir -p "$(dirname "$expected_config_file_location")"
  cp "${TOP}/tests/samples/config.json" "$expected_config_file_location"

  assert [ -f "$expected_config_file_location" ]

  XDG_CONFIG_HOME="${CONFIG_DIR}" config_init

  XDG_CONFIG_HOME="${CONFIG_DIR}" run config_get_item "$CONFIG_GIT_EXTRA_FD_ARGS"
  assert_success

  assert_output --partial "Could not retrieve configuration item"
}

@test "cannot retrieve invalid config item" {
  expected_config_file_location="${CONFIG_DIR}/jorp.sh/config.json"

  assert [ ! -e "$expected_config_file_location" ]
  assert [ -d "$CONFIG_DIR" ]

  mkdir -p "$(dirname "$expected_config_file_location")"
  cp "${TOP}/tests/samples/config.json" "$expected_config_file_location"

  assert [ -f "$expected_config_file_location" ]

  XDG_CONFIG_HOME="${CONFIG_DIR}" config_init

  XDG_CONFIG_HOME="${CONFIG_DIR}" run config_get_item "$CONFIG_GENERAL_MAX_LEVEL"
  assert_success

  assert_output --partial "Could not retrieve configuration item"
}
