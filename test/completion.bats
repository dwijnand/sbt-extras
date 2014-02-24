#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "${sbt_release_version}"
}

@test "loads .sbt_completion.sh" {
  cd "${sbt_project}"
  echo 'echo "${BASH_SOURCE[0]} has been loaded."' > .sbt_completion.sh
  stub java true
  run sbt
  assert_success
  assert_output ".sbt_completion.sh has been loaded."
  unstub java
}
