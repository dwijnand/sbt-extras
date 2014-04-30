#!/usr/bin/env bats

load test_helper

setup() { setup_version_project; }

custom_options_file=".sbt-custom-options"

@test "reads sbt options from .sbtopts" {
  echo "some-improbable-sbt-option" > .sbtopts
  sbt_expecting "Using sbt options defined in file .sbtopts" -v
  sbt_expecting "some-improbable-sbt-option"
}

@test "reads sbt options via -sbt-opts" {
  echo "some-improbable-sbt-option" > $custom_options_file
  sbt_expecting "Using sbt options defined in file $custom_options_file" -sbt-opts $custom_options_file -v
  sbt_expecting "some-improbable-sbt-option" -sbt-opts $custom_options_file
}

@test 'reads sbt options from $SBT_OPTS' {
  export SBT_OPTS="some-improbable-sbt-option"
  sbt_expecting 'Using sbt options defined in variable $SBT_OPTS' -v
  sbt_expecting "some-improbable-sbt-option"
}

@test 'reads sbt options from a file given in $SBT_OPTS' {
  export SBT_OPTS="some-improbable-sbt-option"
  sbt_expecting 'Using sbt options defined in variable $SBT_OPTS' -v
  sbt_expecting "some-improbable-sbt-option"
}

@test "reads sbt options from a file specified via \$SBT_OPTS" {
  export SBT_OPTS="@$custom_options_file"
  echo "some-improbable-sbt-option" > $custom_options_file
  sbt_expecting "Using sbt options defined in file $custom_options_file" -v
  sbt_expecting "some-improbable-sbt-option"
}

@test 'prefers .sbtopts over $SBT_OPTS' {
  echo "some-improbable-sbt-option" > .sbtopts
  export SBT_OPTS="different-improbable-sbt-option"
  sbt_expecting "Using sbt options defined in file .sbtopts" -v
  sbt_expecting "some-improbable-sbt-option"
}

@test "uses default sbt options if none presents" {
  assert [ ! -f .sbtopts ]
  assert [ -z "$SBT_OPTS" ]
  sbt_expecting "No extra sbt options have been defined" -v
}
