#!/usr/bin/env bats

load test_helper

@test "-d sets log level to debug" { sbt_expecting "set logLevel in Global := Level.Debug" -d; }
@test "-q sets log level to error" { sbt_expecting "set logLevel in Global := Level.Error" -q; }
@test "-v doesn't touch log level" { sbt_rejecting "set logLevel in Global" -v; }
