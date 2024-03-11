#!/usr/bin/env bash

function common_setup() {
  if [ -z "${TOP}" ]; then
    TOP="$( cd "$( dirname "${BATS_TEST_FILENAME}" )/../" >/dev/null 2>&1 && pwd )"
    export TOP
  fi
  load "${TOP}/bats/bats-support/load"
  load "${TOP}/bats/bats-assert/load"
}
