#!/usr/bin/env bats

load test_helper

@test "-scala-home => scalaHome"              { sbt_expecting 'set scalaHome in ThisBuild := _root_.scala.Some(file("scala"))' -scala-home scala;   }
@test "-binary-version => scalaBinaryVersion" { sbt_expecting 'set scalaBinaryVersion in ThisBuild := "2.10.2"' -binary-version 2.10.2;             }
@test "-scala-version SNAPSHOT => resolver"   { sbt_expecting 'set resolvers += Resolver.sonatypeRepo("snapshots")' -scala-version 2.12.2-SNAPSHOT; }
@test "-28 => scala 2.8"                      { sbt_expecting "++ 2.8.2" -28;                                                                       }
@test "-29 => scala 2.9"                      { sbt_expecting "++ 2.9.3" -29;                                                                       }
@test "-210 => scala 2.10"                    { sbt_expecting "++ 2.10.7" -210;                                                                     }
@test "-211 => scala 2.11"                    { sbt_expecting "++ 2.11.12" -211;                                                                    }
@test "-212 => scala 2.12"                    { sbt_expecting "++ 2.12.14" -212;                                                                     }
@test "-213 => scala 2.13"                    { sbt_expecting "++ 2.13.5" -213;                                                                     }
@test "-scala-version N => version N"         { sbt_expecting "++ 2.10.2" -scala-version 2.10.2;                                                    }
