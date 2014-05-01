#!/usr/bin/env bats

load test_helper

setup() { setup_version_project; }

@test "-D options passed to jvm" { sbt_expecting "-Dfoo=foo" -Dfoo=foo; }
@test "-J options passed to jvm" { sbt_expecting "-Dbar=bar" -J-Dbar=bar; }

@test "reads jvm options from .jvmopts" {
  echo "-improbable-sbt-option" > .jvmopts
  sbt_expecting "Using jvm options defined in file .jvmopts" -v
  sbt_expecting "-improbable-sbt-option"
}

@test "reads jvm options from a file specified via -sbt-opts" {
  echo "-improbable-sbt-option" > .java-options
  sbt_expecting "Using jvm options defined in file .java-options" -jvm-opts .java-options -v
  sbt_expecting "-improbable-sbt-option" -jvm-opts .java-options
}

@test 'reads jvm options from $JVM_OPTS' {
  export JVM_OPTS="-env-var-sbt-option"
  sbt_expecting 'Using jvm options defined in $JVM_OPTS variable' -v
  sbt_expecting "-env-var-sbt-option"
}

@test 'reads jvm options from $JVM_OPTS specified file' {
  export JVM_OPTS="@.java-options"
  echo "-improbable-sbt-option" > .java-options
  sbt_expecting "Using jvm options defined in file .java-options" -v
  sbt_expecting "-improbable-sbt-option"
}

@test 'prefers .jvmopts over $JVM_OPTS' {
  export JVM_OPTS="-env-var-sbt-option"
  echo "-sbtops-sbt-option" > .jvmopts
  sbt_expecting "Using jvm options defined in file .jvmopts" -v
  sbt_expecting "-sbtops-sbt-option"
  sbt_rejecting "-env-var-sbt-option"
}

@test "uses default jvm options if none presents" {
  assert [ ! -f .jvmopts ]
  assert [ -z "$JVM_OPTS" ]
  sbt_expecting "Using default jvm options" -v
}
