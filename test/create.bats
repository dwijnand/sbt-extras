#!/usr/bin/env bats

load test_helper

setup() {
  create_launcher $sbt_release_version
  mkdir -p "$TEST_ROOT/newproject"
  cd "$TEST_ROOT/newproject"
}

@test "fails to start sbt on empty project" {
  assert [ ! -f "build.sbt" ]
  assert [ ! -d "project" ]
  run sbt
  assert_failure
}

@test "starts sbt on empty project if -sbt-create was given" {
  assert [ ! -f "build.sbt" ]
  assert [ ! -d "project" ]
  stub java true
  run sbt -sbt-create
  assert_success
  unstub java
}
