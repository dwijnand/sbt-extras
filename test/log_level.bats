#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "${sbt_release_version}"
}

stub_java() {
  stub java 'for arg; do echo "$arg"; done > java.log'
}

@test "sets log level as \"Info\" if -v was given" {
  stub_java
  run sbt -v
  assert_success
  expected() {
    java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  }
  assert_equal "$(cat java.log)" "$(expected)"
  unstub java
}

@test "sets log level as \"Debug\" if -d was given" {
  stub_java
  run sbt -d
  assert_success
  expected() {
    java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
set logLevel in Global := Level.Debug
shell
EOS
  }
  assert_equal "$(cat java.log)" "$(expected)"
  unstub java
}

@test "sets log level as \"Error\" if -q was given" {
  stub_java
  run sbt -q
  assert_success
  expected() {
    java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
set logLevel in Global := Level.Error
shell
EOS
  }
  assert_equal "$(cat java.log)" "$(expected)"
  unstub java
}
