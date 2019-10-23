#!/usr/bin/env bats

load test_helper

@test "launches sbt" {
  stub_java
  run sbt
  assert_success
  assert_output <<EOS
java
-Xms512m
-Xss2m
-XX:MaxInlineLevel=18
-jar
\$ROOT/.sbt/launchers/$sbt_release/sbt-launch.jar
shell
EOS
  unstub java
}
