#!/usr/bin/env bats

load test_helper

setup () { setup_version_project $sbt_latest_13; }

@test "successes to set trace level for sbt 0.13.x"          { sbt_expecting "set every traceLevel := 1" -trace 1; }
@test "sets sbt.global.base if -sbt-dir is given sbt 0.13.x" { sbt_expecting "-Dsbt.global.base=$sbt_project/sbt.base" -sbt-dir "$sbt_project/sbt.base"; }
@test "default doesn't set sbt.global.base for sbt 0.13.x"   { sbt_rejecting "-Dsbt.global.base=$sbt_project/sbt.base"; }
