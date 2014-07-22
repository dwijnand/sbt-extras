#!/usr/bin/env bats

load test_helper

custom_options_file=".java-options"
custom_option_name="-improbable-jvm-option"

@test "-D options passed to jvm" { sbt_expecting "-Dfoo=foo" -Dfoo=foo; }
@test "-J options passed to jvm" { sbt_expecting "-Dbar=bar" -J-Dbar=bar; }

@test "reads jvm options from .jvmopts" {
  echo "$custom_option_name" > .jvmopts
  sbt_expecting_echo "Using jvm options defined in file .jvmopts" -v
  sbt_expecting_echo "$custom_option_name"
}

@test "reads jvm options from a file specified via -sbt-opts" {
  echo "$custom_option_name" > $custom_options_file
  sbt_expecting_echo "Using jvm options defined in file $custom_options_file" -jvm-opts $custom_options_file -v
  sbt_expecting_echo "$custom_option_name" -jvm-opts $custom_options_file
}

@test 'reads jvm options from $JVM_OPTS' {
  export JVM_OPTS="-env-var-sbt-option"
  sbt_expecting_echo 'Using jvm options defined in $JVM_OPTS variable' -v
  sbt_expecting_echo "-env-var-sbt-option"
}

@test 'reads jvm options from $JVM_OPTS specified file' {
  export JVM_OPTS="@$custom_options_file"
  echo "$custom_option_name" > $custom_options_file
  sbt_expecting_echo "Using jvm options defined in file $custom_options_file" -v
  sbt_expecting_echo "$custom_option_name"
}

@test 'prefers .jvmopts over $JVM_OPTS' {
  export JVM_OPTS="-env-var-sbt-option"
  echo "-sbtops-sbt-option" > .jvmopts
  sbt_expecting_echo "Using jvm options defined in file .jvmopts" -v
  sbt_expecting_echo "-sbtops-sbt-option"
  sbt_rejecting_echo "-env-var-sbt-option"
}

@test "uses default jvm options if none presents" {
  assert [ ! -f .jvmopts ]
  assert [ -z "$JVM_OPTS" ]
  sbt_expecting "Using default jvm options" -v
}
