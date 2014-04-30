#!/usr/bin/env bats

load test_helper

setup () { setup_version_project $sbt_latest_07; }

@test "fails to set trace level for sbt 0.7.x"         { sbt_expecting "Cannot set trace level" -trace 1;                                          }
@test "sets default sbt.global.base in sbt 0.7.x"      { sbt_expecting "-Dsbt.global.base=$HOME/.sbt/$sbt_latest_7";                               }
@test "sets sbt.global.base for -sbt-dir in sbt 0.7.x" { sbt_expecting "-Dsbt.global.base=$sbt_project/sbt.base" -sbt-dir "$sbt_project/sbt.base"; }
