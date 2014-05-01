#!/usr/bin/env bats

load test_helper

@test "loads .sbt_completion.sh" {
  cd "$sbt_project"
  echo 'echo "${BASH_SOURCE[0]} has been loaded."' > .sbt_completion.sh
  sbt_expecting ".sbt_completion.sh has been loaded."
}
