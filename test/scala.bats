#!/usr/bin/env bats

load test_helper

@test "-scala-home => scalaHome"              { sbt_expecting 'set every scalaHome := Some(file("scala"))' -scala-home scala;                       }
@test "-binary-version => scalaBinaryVersion" { sbt_expecting 'set scalaBinaryVersion in ThisBuild := "2.10.2"' -binary-version 2.10.2;             }
@test "-scala-version SNAPSHOT => resolver"   { sbt_expecting 'set resolvers += Resolver.sonatypeRepo("snapshots")' -scala-version 2.12.0-SNAPSHOT; }
@test "-28 => scala 2.8"                      { sbt_expecting "++ 2.8.2" -28;                                                                       }
@test "-29 => scala 2.9"                      { sbt_expecting "++ 2.9.3" -29;                                                                       }
@test "-210 => scala 2.10"                    { sbt_expecting "++ 2.10.4" -210;                                                                     }
@test "-211 => scala 2.11"                    { sbt_expecting "++ 2.11.0" -211;                                                                     }
@test "-scala-version N => version N"         { sbt_expecting "++ 2.10.2" -scala-version 2.10.2;                                                    }
