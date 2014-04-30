#!/usr/bin/env bats

load test_helper

setup() { setup_version_project $sbt_latest_10; }

@test "fails to set trace level for sbt 0.10.x" {
  stub_java
  run sbt -trace 1
  assert_success
  { echo "Cannot set trace level in sbt version $sbt_latest_10"
    java_options <<EOS
-Dsbt.global.base=${HOME}/.sbt/$sbt_latest_10
-jar
${HOME}/.sbt/launchers/$sbt_latest_10/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "enables default sbt.global.base for sbt 0.10.x" {
  stub_java
  run sbt
  assert_success
  { java_options <<EOS
-Dsbt.global.base=${HOME}/.sbt/$sbt_latest_10
-jar
${HOME}/.sbt/launchers/$sbt_latest_10/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "enables special sbt.global.base for sbt 0.10.x if -sbt-dir was given" {
  stub_java
  run sbt -sbt-dir "${sbt_project}/sbt.base"
  assert_success
  { java_options <<EOS
-Dsbt.global.base=${sbt_project}/sbt.base
-jar
${HOME}/.sbt/launchers/$sbt_latest_10/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}
