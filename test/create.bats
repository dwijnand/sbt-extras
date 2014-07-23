#!/usr/bin/env bats

load test_helper

setup() { sbt_test_setup && mkdircd "$TEST_ROOT/newproject"; }

@test "fails to start sbt on empty project" {
  assert [ ! -f "build.sbt" ]
  assert [ ! -d "project" ]
  run sbt
  assert_failure
}

@test "starts sbt on empty project if -sbt-create was given" {
  assert [ ! -f "build.sbt" ]
  assert [ ! -d "project" ]
  stub_java
  run sbt -sbt-create
  assert_success
  unstub java
}
