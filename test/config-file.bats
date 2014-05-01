#!/usr/bin/env bats

load test_helper

configFile () { cat <<EOM
# Comment 1
# Comment 2, followed by blank line

-Xmx1g
-Dsome.prop="pass a # in a string"

-Xss4m
# Comment 4
EOM
}

expectedOutput () { cat <<EOM
-Xmx1g
-Dsome.prop="pass a # in a string"
-Xss4m
-jar
$TEST_ROOT/.sbt/launchers/0.13.2/sbt-launch.jar
about
EOM
}

@test "tolerates blank lines and comments in jvm_opts file" {
  stub_java
  configFile >jvm_opts
  run sbt -jvm-opts jvm_opts about
  assert_success
  expectedOutput | assert_output
  unstub java
}
