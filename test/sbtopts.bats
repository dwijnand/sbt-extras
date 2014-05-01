#!/usr/bin/env bats

load test_helper

custom_options_file=".sbt-custom-options"
custom_option_name="some-improbable-sbt-option"

@test "reads sbt options from .sbtopts" {
  echo $custom_option_name > .sbtopts
  sbt_expecting "Using sbt options defined in file .sbtopts" -v
  sbt_expecting $custom_option_name
}

@test "reads sbt options via -sbt-opts" {
  echo $custom_option_name > $custom_options_file
  sbt_expecting "Using sbt options defined in file $custom_options_file" -sbt-opts $custom_options_file -v
  sbt_expecting $custom_option_name -sbt-opts $custom_options_file
}

@test 'reads sbt options from $SBT_OPTS' {
  export SBT_OPTS=$custom_option_name
  sbt_expecting 'Using sbt options defined in variable $SBT_OPTS' -v
  sbt_expecting $custom_option_name
}

@test 'reads sbt options from a file specified via $SBT_OPTS' {
  export SBT_OPTS="@$custom_options_file"
  echo $custom_option_name > $custom_options_file
  sbt_expecting "Using sbt options defined in file $custom_options_file" -v
  sbt_expecting $custom_option_name
}

@test 'prefers .sbtopts over $SBT_OPTS' {
  echo $custom_option_name > .sbtopts
  export SBT_OPTS="different-improbable-sbt-option"
  sbt_expecting "Using sbt options defined in file .sbtopts" -v
  sbt_expecting $custom_option_name
}

@test "uses default sbt options if none presents" {
  assert [ ! -f .sbtopts ]
  assert [ -z "$SBT_OPTS" ]
  sbt_expecting "No extra sbt options have been defined" -v
}
