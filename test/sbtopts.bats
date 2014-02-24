#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "${sbt_release_version}"
}

stub_java() {
  stub java 'for arg; do echo "$arg"; done'
}

@test "reads sbt options from .sbtopts" {
  echo "foo" > .sbtopts

  stub_java
  run sbt -v
  assert_success
  assert_output_contains "Using sbt options defined in file .sbtopts"
  unstub java

  stub_java
  run sbt
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
foo
EOS
  } | assert_output
  unstub java
}

@test "reads sbt options from a file specified via -sbt-opts" {
  echo "bar" > .xsbt-options

  stub_java
  run sbt -sbt-opts .xsbt-options -v
  assert_success
  assert_output_contains "Using sbt options defined in file .xsbt-options"
  unstub java

  stub_java
  run sbt -sbt-opts .xsbt-options
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
bar
EOS
  } | assert_output
  unstub java
}

@test "reads sbt options from \$SBT_OPTS" {
  export SBT_OPTS="baz"

  stub_java
  run sbt -v
  assert_success
  assert_output_contains "Using sbt options defined in variable \$SBT_OPTS"
  unstub java

  stub_java
  run sbt
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
baz
EOS
  } | assert_output
  unstub java
}

@test "reads sbt options from a file specified via \$SBT_OPTS" {
  export SBT_OPTS="@.xsbt-options"
  echo "baz" > .xsbt-options

  stub_java
  run sbt -v
  assert_success
  assert_output_contains "Using sbt options defined in file .xsbt-options"
  unstub java

  stub_java
  run sbt
  assert_success
  { java_options <<EOS
-jar
${TMP}/.sbt/launchers/${sbt_release_version}/sbt-launch.jar
baz
EOS
  } | assert_output
  unstub java
}

@test "prefers sbt options in .sbtopts than one in \$SBT_OPTS if both present" {
  echo "foo" > .sbtopts
  export SBT_OPTS="bar"

  stub_java
  run sbt -v
  assert_success
  assert_output_contains "Using sbt options defined in file .sbtopts"
  unstub java
}

@test "uses default sbt options if none presents" {
  assert [ ! -f .sbtopts ]
  assert [ -z "$SBT_OPTS" ]

  stub_java
  run sbt -v
  assert_output_contains "No extra sbt options have been defined"
  unstub java
}
