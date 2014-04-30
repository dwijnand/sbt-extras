#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "0.11.3"
  echo "sbt.version=0.11.3" > "$sbt_project/project/build.properties"
}

@test "fails to set trace level for sbt 0.11.x" {
  stub_java
  run sbt -trace 1
  assert_success
  { echo "Cannot set trace level in sbt version 0.11.3"
    java_options <<EOS
-Dsbt.global.base=${HOME}/.sbt/0.11.3
-jar
${HOME}/.sbt/launchers/0.11.3/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "enables default sbt.global.base for sbt 0.11.x" {
  stub_java
  run sbt
  assert_success
  { java_options <<EOS
-Dsbt.global.base=${HOME}/.sbt/0.11.3
-jar
${HOME}/.sbt/launchers/0.11.3/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "enables special sbt.global.base for sbt 0.11.x if -sbt-dir was given" {
  stub_java
  run sbt -sbt-dir "${sbt_project}/sbt.base"
  assert_success
  { java_options <<EOS
-Dsbt.global.base=${sbt_project}/sbt.base
-jar
${HOME}/.sbt/launchers/0.11.3/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}
