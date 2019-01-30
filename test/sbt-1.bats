#!/usr/bin/env bats

load test_helper

@test "successes to set trace level for sbt 1.x"          { sbt_expecting "set traceLevel in ThisBuild := 1" -trace 1; }
@test "sets sbt.global.base if -sbt-dir is given sbt 1.x" { sbt_expecting "-Dsbt.global.base=$sbt_project/sbt.base" -sbt-dir "$sbt_project/sbt.base"; }
@test "default doesn't set sbt.global.base for sbt 1.x"   { sbt_rejecting "-Dsbt.global.base=$sbt_project/sbt.base"; }
