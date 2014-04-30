#!/usr/bin/env bats

load test_helper

setup() { setup_version_project; }

@test "reads jvm options from .jvmopts" {
  echo "-foo" > .jvmopts

  sbt_expecting "Using jvm options defined in file .jvmopts" -v

  stub_java
  run sbt
  assert_success
  assert_output <<EOS
-foo
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  unstub java
}

@test "reads jvm options from a file specified via -sbt-opts" {
  echo "-bar" > .java-options

  sbt_expecting "Using jvm options defined in file .java-options" -jvm-opts .java-options -v

  stub_java
  run sbt -jvm-opts .java-options
  assert_success
  assert_output <<EOS
-bar
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  unstub java
}

@test "reads jvm options from \$JVM_OPTS" {
  export JVM_OPTS="-baz"

  sbt_expecting "Using jvm options defined in \$JVM_OPTS variable" -v

  stub_java
  run sbt
  assert_output <<EOS
-baz
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  unstub java
}

@test "reads jvm options from a file specified via \$JVM_OPTS" {
  export JVM_OPTS="@.java-options"
  echo "-baz" > .java-options

  sbt_expecting "Using jvm options defined in file .java-options" -v

  stub_java
  run sbt
  assert_success
  assert_output <<EOS
-baz
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  unstub java
}

@test "passes special jvm options if -D was given" { sbt_expecting "-Dfoo=foo" -Dfoo=foo; }
@test "passes special jvm options if -J was given" { sbt_expecting "-Dbar=bar" -J-Dbar=bar; }

@test "prefers jvm options in .jvmopts than one in \$JVM_OPTS if both present" {
  echo "-foo" > .jvmopts
  export JVM_OPTS="-bar"

  sbt_expecting "Using jvm options defined in file .jvmopts" -v
}

@test "uses default jvm options if none presents" {
  assert [ ! -f .jvmopts ]
  assert [ -z "$JVM_OPTS" ]
  sbt_expecting "Using default jvm options" -v
}
