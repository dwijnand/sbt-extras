#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "${sbt_release_version}"
}

@test "enables special ivy home if -ivy was given" {
  stub_java
  run sbt -ivy "${sbt_project}/ivy"
  assert_success
  { java_options <<EOS
-Dsbt.ivy.home=${sbt_project}/ivy
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "disables colororized output if -no-colors was given" {
  stub_java
  run sbt -no-colors
  assert_success
  { java_options <<EOS
-Dsbt.log.noformat=true
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "disables shared sbt directories if -no-share was given" {
  stub_java
  run sbt -no-share
  assert_success
  { java_options <<EOS
-Dsbt.global.base=project/.sbtboot
-Dsbt.boot.directory=project/.boot
-Dsbt.ivy.home=project/.ivy
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "enables special sbt boot directory if -sbt-boot was given" {
  stub_java
  run sbt -sbt-boot "${sbt_project}/sbt.boot"
  assert_success
  { java_options <<EOS
-Dsbt.boot.directory=${sbt_project}/sbt.boot
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "enables debug logging of incremental compiler if -debug-inc was given" {
  stub_java
  run sbt -debug-inc
  assert_success
  { java_options <<EOS
-Dxsbt.inc.debug=true
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "enables offline mode if -offline was given" {
  stub_java
  run sbt -offline
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
set offline := true
shell
EOS
  } | assert_output
  unstub java
}

@test "enables jvm debug options if -jvm-debug was given" {
  stub_java
  run sbt -jvm-debug 8000
  assert_success
  { java_options <<EOS
-Xdebug
-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "sets custom prompt if -prompt was given" {
  stub_java
  run sbt -prompt '"% "'
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
set shellPrompt in ThisBuild := (s => { val e = Project.extract(s) ; "% " })
shell
EOS
  } | assert_output
  unstub java
}

@test "sets custom scalac options if -S was given" {
  stub_java
  run sbt -S-P:continuations:enable
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
set scalacOptions in ThisBuild += "-P:continuations:enable"
shell
EOS
  } | assert_output
  unstub java
}
