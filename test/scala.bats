#!/usr/bin/env bats

load test_helper

setup() { create_project_with_launcher $sbt_release_version; }

@test "add scalaHome for -scala-home"              { sbt_expecting 'set every scalaHome := Some(file("scala"))' -scala-home scala;                       }
@test "add scalaBinaryVersion for -binary-version" { sbt_expecting 'set scalaBinaryVersion in ThisBuild := "2.10.2"' -binary-version 2.10.2;             }
@test "add resolver for snapshot versions"         { sbt_expecting 'set resolvers += Resolver.sonatypeRepo("snapshots")' -scala-version 2.12.0-SNAPSHOT; }
@test "enables scala 2.8 if -28 was given"         { sbt_expecting "++ $latest_28" -28;                                                                  }
@test "enables scala 2.9 if -29 was given"         { sbt_expecting "++ $latest_29" -29;                                                                  }
@test "enables scala 2.10 if -210 was given"       { sbt_expecting "++ $latest_210" -210;                                                                }
@test "enables scala 2.11 if -211 was given"       { sbt_expecting "++ $latest_211" -211;                                                                }
@test "enables -scala-version"                     { sbt_expecting "++ 2.10.2" -scala-version 2.10.2;                                                    }
