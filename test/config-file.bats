#!/usr/bin/env bats

load test_helper

configFile () { echo -n '
# Comment 1
# Comment 2, followed by blank line

-Xmx1g
-Dsome.prop="pass a # in a string"

-Xss4m
# Comment 4
-Xms1g'
}

expectedOutput () { cat <<EOM
java
-Xmx1g
-Dsome.prop="pass a # in a string"
-Xss4m
-Xms1g
-jar
$TEST_ROOT/.sbt/launchers/0.13.13/sbt-launch.jar
about
EOM
}

@test "tolerates blank lines and comments in jvm_opts file" {
  stub_java_echo
  configFile >jvm_opts
  run sbt -jvm-opts jvm_opts about
  assert_success
  expectedOutput | assert_output
  unstub java
}
