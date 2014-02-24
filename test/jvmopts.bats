#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "${sbt_release_version}"
}

stub_java() {
  stub java 'for arg; do echo "$arg"; done'
}

@test "reads jvm options from .jvmopts" {
  echo "-foo" > .jvmopts

  stub_java
  run sbt -v
  assert_success
  assert_output_contains "Using jvm options defined in file .jvmopts"
  unstub java

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

  stub_java
  run sbt -jvm-opts .java-options -v
  assert_success
  assert_output_contains "Using jvm options defined in file .java-options"
  unstub java

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

  stub_java
  run sbt -v
  assert_success
  assert_output_contains "Using jvm options defined in \$JVM_OPTS variable"
  unstub java

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

  stub_java
  run sbt -v
  assert_success
  assert_output_contains "Using jvm options defined in file .java-options"
  unstub java

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

@test "prefers jvm options in .jvmopts than one in \$JVM_OPTS if both present" {
  echo "-foo" > .jvmopts
  export JVM_OPTS="-bar"

  stub_java
  run sbt -v
  assert_success
  assert_output_contains "Using jvm options defined in file .jvmopts"
  unstub java
}

@test "uses default jvm options if none presents" {
  assert [ ! -f .jvmopts ]
  assert [ -z "$JVM_OPTS" ]

  stub_java
  run sbt -v
  assert_output_contains "Using default jvm options"
  unstub java
}

@test "passes special jvm options if -D was given" {
  stub_java
  run sbt -Dfoo=foo
  assert_success
  { java_options <<EOS
-Dfoo=foo
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}

@test "passes special jvm options if -J was given" {
  stub_java
  run sbt -J-Dbar=bar
  assert_success
  { java_options <<EOS
-Dbar=bar
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
shell
EOS
  } | assert_output
  unstub java
}
