#!/usr/bin/env bats

load test_helper

@test "-d sets log level to debug" { sbt_expecting "--debug" -d; }
@test "-w sets log level to  warn" { sbt_expecting "--warn" -w; }
@test "-q sets log level to error" { sbt_expecting "--error" -q; }
@test "-v doesn't touch log level" { sbt_rejecting "set logLevel in Global" -v; }
