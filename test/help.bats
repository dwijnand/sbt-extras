#!/usr/bin/env bats

load test_helper

@test "shows usage of sbt-extras" {
  run sbt -help
  assert_failure
  assert_grep "Usage: sbt [options]" -F
}
