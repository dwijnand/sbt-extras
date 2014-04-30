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

curl_opts='--fail --silent http://* --output * : mkdir -p "$(dirname "$5")" && touch "$5"'
wget_opts='--quiet -O * http://* : mkdir -p "$(dirname "$3")" && touch "$3"'

stub_curl() { stub curl "$curl_opts"; }
stub_wget() { stub wget "$wget_opts"; }

launcher_url () {
  case "$1" in
    0.7.*) echo "http://simple-build-tool.googlecode.com/files/sbt-launch-$1.jar" ;;
   0.10.*) echo "http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-tools.sbt/sbt-launch/$1/sbt-launch.jar" ;;
        *) echo "http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$1/sbt-launch.jar" ;;
  esac
}

download_version () {
  echo "sbt.version=$1" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $1:
  From  $(launcher_url $1)
    To  ${TMP}/.sbt/launchers/$1/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads sbt 0.7.x"  { download_version "$sbt_latest_07"; }
@test "downloads sbt 0.10.x" { download_version "$sbt_latest_10"; }
@test "downloads sbt 0.11.x" { download_version "$sbt_latest_11"; }
@test "downloads sbt 0.12.x" { download_version "$sbt_latest_12"; }
@test "downloads sbt 0.13.x" { download_version "$sbt_latest_13"; }

@test "downloads release version if build.properties is missing" {
  assert [ ! -f "${sbt_project}/project/build.properties" ]
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_release_version:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$sbt_latest_13/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/$sbt_release_version/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads specified version when -sbt-version was given" {
  specified_version="0.12.2"
  assert [ ! -f "${sbt_project}/project/build.properties" ]
  stub_curl
  run sbt -sbt-version $specified_version
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $specified_version:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$specified_version/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/$specified_version/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads specified version when -sbt-version was given, even if there is build.properties" {
  echo "sbt.version=$sbt_latest_12" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt -sbt-version $sbt_latest_13
  assert_success
  assert_output <<EOS
!!!
!!! Updated file project/build.properties setting sbt.version to: $sbt_latest_13
!!! Previous value was: $sbt_latest_12
!!!
Downloading sbt launcher for $sbt_latest_13:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$sbt_latest_13/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/$sbt_latest_13/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads unreleased version when -sbt-dev was given" {
  assert [ ! -f "${sbt_project}/project/build.properties" ]
  stub_curl
  run sbt -sbt-dev
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_latest_dev:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$sbt_latest_dev/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/$sbt_latest_dev/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads unreleased version when -sbt-dev was given, even if there is build.properties" {
  echo "sbt.version=$sbt_latest_13" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt -sbt-dev
  assert_success
  assert_output <<EOS
!!!
!!! Updated file project/build.properties setting sbt.version to: $sbt_latest_dev
!!! Previous value was: $sbt_latest_13
!!!
Downloading sbt launcher for $sbt_latest_dev:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$sbt_latest_dev/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/$sbt_latest_dev/sbt-launch.jar
EOS
  unstub curl
}

@test "allows surrounding white spaces around '=' in build.properties" {
  echo "sbt.version = $sbt_latest_13" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_latest_13:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$sbt_latest_13/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/$sbt_latest_13/sbt-launch.jar
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
  echo "stub.version=$sbt_latest_13" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt -sbt-launch-dir "${sbt_project}/xsbt"
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_latest_13:
  From  http://typesafe.artifactoryonline.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$sbt_latest_13/sbt-launch.jar
    To  ${sbt_project}/xsbt/$sbt_latest_13/sbt-launch.jar
EOS
  unstub curl
}

@test "uses special launcher repository if -sbt-launch-repo was given" {
  echo "stub.version=$sbt_latest_13" > "${sbt_project}/project/build.properties"
  stub_curl
  run sbt -sbt-launch-repo "http://127.0.0.1:8080/ivy-releases"
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_latest_13:
  From  http://127.0.0.1:8080/ivy-releases/org.scala-sbt/sbt-launch/$sbt_latest_13/sbt-launch.jar
    To  ${TMP}/.sbt/launchers/$sbt_latest_13/sbt-launch.jar
EOS
  unstub curl
}
