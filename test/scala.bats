#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "${sbt_release_version}"
}

stub_java() {
  stub java 'for arg; do echo "$arg"; done'
}

@test "enables specified scala version if -scala-version was given" {
  stub_java
  run sbt -scala-version "2.10.2"
  assert_success
  { java_options <<EOS 
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
++ 2.10.2
shell
EOS
  } | assert_output
  unstub java
}

@test "enables resolver for snapshots if -scala-version was given and the version is SNAPSHOT" {
  stub_java
  run sbt -scala-version "2.11.0-SNAPSHOT"
  assert_success
  { java_options <<EOS 
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
set resolvers += Resolver.sonatypeRepo("snapshots")
++ 2.11.0-SNAPSHOT
shell
EOS
  } | assert_output
  unstub java
}

@test "enables scalaBinaryVersion if -binary-version was given" {
  stub_java
  run sbt -binary-version "2.10.2"
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
set scalaBinaryVersion in ThisBuild := "2.10.2"
shell
EOS
  } | assert_output
  unstub java
}

@test "enables scalaHome if -scala-home was given" {
  stub_java
  run sbt -scala-home scala
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
set every scalaHome := Some(file("scala"))
shell
EOS
  } | assert_output
  unstub java
}

@test "enables scala 2.8 if -28 was given" {
  stub_java
  run sbt -28
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
++ ${latest_28}
shell
EOS
  } | assert_output
  unstub java
}

@test "enables scala 2.9 if -29 was given" {
  stub_java
  run sbt -29
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
++ ${latest_29}
shell
EOS
  } | assert_output
  unstub java
}

@test "enables scala 2.10 if -210 was given" {
  stub_java
  run sbt -210
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
++ ${latest_210}
shell
EOS
  } | assert_output
  unstub java
}

@test "enables scala 2.11 if -211 was given" {
  stub_java
  run sbt -211
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
++ ${latest_211}
shell
EOS
  } | assert_output
  unstub java
}
