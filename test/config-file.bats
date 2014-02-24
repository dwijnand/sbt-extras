#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  create_launcher "${sbt_release_version}"
}

stub_java() {
  stub java 'for arg; do echo "$arg"; done'
}

configFile () { cat <<EOM
# Comment 1
# Comment 2, followed by blank line

-Xmx1g

-Xss4m
# Comment 4
EOM
}

expectedOutput () { cat <<EOM
-Xmx1g
-Xss4m
-jar
${TMP}/.sbt/launchers/0.13.1/sbt-launch.jar
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
