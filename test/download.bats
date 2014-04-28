#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  stub java 'true'
}

teardown() {
  unstub java
  rm -fr "$TMP"/* "$TMP"/.sbt
}

stub_curl() {
  stub curl '--fail --silent http://* --output * : mkdir -p "$(dirname "$5")" && touch "$5"'
}

stub_wget() {
  stub wget '--quiet -O * http://* : mkdir -p "$(dirname "$3")" && touch "$3"'
}

@test "downloads sbt 0.7.x" {
  echo "sbt.version=0.7.7" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.7.7:
  From  http://simple-build-tool.googlecode.com/files/sbt-launch-0.7.7.jar
    To  ${TMP}/.sbt/launchers/0.7.7/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads sbt 0.10.x" {
  echo "sbt.version=0.10.1" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.10.1:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-tools.sbt/sbt-launch/0.10.1/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.10.1/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads sbt 0.11.x (< 0.11.3) from org.scala-tools.sbt:sbt-launch" {
  echo "sbt.version=0.11.2" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.11.2:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-tools.sbt/sbt-launch/0.11.2/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.11.2/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads sbt 0.11.x (>= 0.11.3) from org-scala-sbt:sbt-launch" {
  echo "sbt.version=0.11.3" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.11.3:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.11.3/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.11.3/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads sbt 0.12.x" {
  echo "sbt.version=0.12.4" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.12.4:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.12.4/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.12.4/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads sbt 0.13.x" {
  echo "sbt.version=0.13.0" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.13.0:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.0/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.13.0/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads release version if build.properties is missing" {
  assert [ ! -f "${sbt_project}/project/build.properties" ]
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.13.2:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.2/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.13.2/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads specified version when -sbt-version was given" {
  assert [ ! -f "${sbt_project}/project/build.properties" ]
  stub_curl
  run sbt -sbt-version 0.12.4
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.12.4:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.12.4/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.12.4/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads specified version when -sbt-version was given, even if there is build.properties" {
  echo "sbt.version=0.12.4" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt -sbt-version 0.13.2
  assert_success
  assert_output <<EOS
!!!
!!! Updated file project/build.properties setting sbt.version to: 0.13.2
!!! Previous value was: 0.12.4
!!!
Downloading sbt launcher for 0.13.2:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.2/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.13.2/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads unreleased version when -sbt-dev was given" {
  assert [ ! -f "${sbt_project}/project/build.properties" ]
  stub_curl
  run sbt -sbt-dev
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.13.3-SNAPSHOT:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.3-SNAPSHOT/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.13.3-SNAPSHOT/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads unreleased version when -sbt-dev was given, even if there is build.properties" {
  echo "sbt.version=0.13.2" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt -sbt-dev
  assert_success
  assert_output <<EOS
!!!
!!! Updated file project/build.properties setting sbt.version to: 0.13.3-SNAPSHOT
!!! Previous value was: 0.13.2
!!!
Downloading sbt launcher for 0.13.3-SNAPSHOT:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.3-SNAPSHOT/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.13.3-SNAPSHOT/sbt-launch.jar
EOS
  unstub curl
}

@test "allows surrounding white spaces around '=' in build.properties" {
  echo "sbt.version = 0.13.2" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.13.2:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.2/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.13.2/sbt-launch.jar
EOS
  unstub curl
}

@test "skips to download sbt-launch.jar if a file was given via -sbt-jar" {
  touch sbt-launch.jar
  run sbt -sbt-jar sbt-launch.jar
  assert_success
  assert_output <<EOS
EOS
}

@test "uses special launcher directory if -sbt-launch-dir was given" {
  echo "stub.version=0.13.2" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt -sbt-launch-dir "${sbt_project}/xsbt"
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.13.2:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/0.13.2/sbt-launch.jar
    To  ${sbt_project}/xsbt/0.13.2/sbt-launch.jar
EOS
  unstub curl
}

@test "uses special launcher repository if -sbt-launch-repo was given" {
  echo "stub.version=0.13.2" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt -sbt-launch-repo "http://127.0.0.1:8080/ivy-releases"
  assert_success
  assert_output <<EOS
Downloading sbt launcher for 0.13.2:
  From  http://127.0.0.1:8080/ivy-releases/org.scala-sbt/sbt-launch/0.13.2/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/0.13.2/sbt-launch.jar
EOS
  unstub curl
}
