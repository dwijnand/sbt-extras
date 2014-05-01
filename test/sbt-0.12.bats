#!/usr/bin/env bats

load test_helper

setup () { setup_version_project $sbt_latest_12; }

@test "successes to set trace level for sbt 0.12.x"     { sbt_expecting "set every traceLevel := 1" -trace 1;                                       }
@test "sets sbt.global.base for -sbt-dir in sbt 0.12.x" { sbt_expecting "-Dsbt.global.base=$sbt_project/sbt.base" -sbt-dir "$sbt_project/sbt.base"; }
@test "sets default sbt.global.base in sbt 0.12.x"      { sbt_expecting "-Dsbt.global.base=$TEST_ROOT/.sbt/$sbt_latest_12";                         }
