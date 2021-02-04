#!/usr/bin/env bats

load test_helper

setup() {
  create_project
  stub java 'true'
}

teardown() {
  unstub java
  rm -fr "$TEST_ROOT"/* "$TEST_ROOT"/.sbt
}

curl_opts='--fail --silent --location https://* --output * : mkdir -p "$(dirname "$6")" && touch "$6"'
wget_opts='--quiet -O * https://* : mkdir -p "$(dirname "$3")" && touch "$3"'

stub_curl() {
  stub curl "$curl_opts";
  case "$1" in
    0.*) ;; # sbt <1 has no MD5 files to curl and verify
      *) stub curl "$curl_opts" && stub md5sum 'true' ;;
  esac
}
stub_wget() { stub wget "$wget_opts"; }
stub_md5sum() { stub md5sum 'true'; }

launcher_url () {
  case "$1" in
    0.7.*) echo "https://storage.googleapis.com/google-code-archive-downloads/v2/code.google.com/simple-build-tool/sbt-launch-$1.jar" ;;
   0.10.*) echo "https://repo.typesafe.com/typesafe/ivy-releases/org.scala-tools.sbt/sbt-launch/$1/sbt-launch.jar" ;;
      1.*) echo "https://repo1.maven.org/maven2/org/scala-sbt/sbt-launch/$1/sbt-launch.jar" ;;
        *) echo "https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$1/sbt-launch.jar" ;;
  esac
}

checksum_output() {
  case "$1" in
    0.*) echo "SBT versions < 1.0 do not have published MD5 checksums, skipping check" ;;
    *) echo "OK" ;;
  esac
}

write_to_properties_and_fetch ()         { write_to_properties "$1" && shift && fetch_launcher "$@"; }
write_version_to_properties_and_fetch () { write_version_to_properties "$1" && fetch_launcher "$@"; }
no_properties_and_fetch ()               { assert_no_properties && fetch_launcher "$@"; }

fetch_launcher () {
  local version="$1" && shift

  jar_output=$(cat <<EOS
Downloading sbt launcher for $version:
  From  $(launcher_url $version)
    To  $TEST_ROOT/.sbt/launchers/$version/sbt-launch.jar
EOS
)
  md5_output=$(cat <<EOS
Downloading sbt launcher $version md5 hash:
  From  $(launcher_url $version).md5
    To  $TEST_ROOT/.sbt/launchers/$version/sbt-launch.jar.md5
EOS
)

  local output_text
  # the md5 hash gets added only for sbt 1.x
  case "${version}" in
    0.*)
      output_text="${jar_output}"
      ;;
    *)
      output_text=$(cat <<EOS
${jar_output}
${md5_output}
EOS
)
    ;;
  esac

  stub_curl "${version}"
  run sbt "$@"
  assert_success
  assert_output "${output_text}"
  unstub curl
}

@test "downloads sbt 0.7.x"  { write_version_to_properties_and_fetch "$sbt_07"; }
@test "downloads sbt 0.10.x" { write_version_to_properties_and_fetch "$sbt_10"; }
@test "downloads sbt 0.11.x" { write_version_to_properties_and_fetch "$sbt_11"; }
@test "downloads sbt 0.12.x" { write_version_to_properties_and_fetch "$sbt_12"; }
@test "downloads sbt 0.13.x" { write_version_to_properties_and_fetch "$sbt_13"; }
@test "downloads sbt 1.x"    { write_version_to_properties_and_fetch "$sbt_1"; }

@test "downloads release version if build.properties is missing"    { no_properties_and_fetch "$sbt_release"; }
@test "downloads specified version when -sbt-version was given"     { no_properties_and_fetch 0.12.2 -sbt-version 0.12.2; }
@test "downloads released version when -sbt-force-latest was given" { no_properties_and_fetch "$sbt_release" -sbt-force-latest; }
@test "downloads unreleased version when -sbt-dev was given"        { no_properties_and_fetch "$sbt_dev" -sbt-dev; }

@test "downloads specified version when -sbt-version was given, even if there is build.properties" {
  write_version_to_properties $sbt_12
  stub_curl "${sbt_12}"
  run sbt -sbt-version $sbt_13
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_13:
  From  https://repo.typesafe.com/typesafe/ivy-releases/org.scala-sbt/sbt-launch/$sbt_13/sbt-launch.jar
    To  $TEST_ROOT/.sbt/launchers/$sbt_13/sbt-launch.jar
EOS
  unstub curl
}

@test "downloads released version when -sbt-force-latest was given, even if there is build.properties" {
  write_version_to_properties $sbt_12
  stub_curl "${sbt_release}"
  run sbt -sbt-force-latest
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_release:
  From  $(launcher_url $sbt_release)
    To  $TEST_ROOT/.sbt/launchers/$sbt_release/sbt-launch.jar
Downloading sbt launcher $sbt_release md5 hash:
  From  $(launcher_url $sbt_release).md5
    To  $TEST_ROOT/.sbt/launchers/$sbt_release/sbt-launch.jar.md5
EOS
  unstub curl
}

@test "downloads unreleased version when -sbt-dev was given, even if there is build.properties" {
  write_version_to_properties $sbt_13
  stub_curl "${sbt_dev}"
  run sbt -sbt-dev
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_dev:
  From  $(launcher_url $sbt_dev)
    To  $TEST_ROOT/.sbt/launchers/$sbt_dev/sbt-launch.jar
Downloading sbt launcher $sbt_dev md5 hash:
  From  $(launcher_url $sbt_dev).md5
    To  $TEST_ROOT/.sbt/launchers/$sbt_dev/sbt-launch.jar.md5
EOS
  unstub curl
}

@test "allows surrounding white spaces around '=' in build.properties" {
  write_to_properties_and_fetch "sbt.version = 0.12.1" "0.12.1"
}

@test "supports windows line endings (crlf) in build.properties" {
  write_to_properties_and_fetch "sbt.version=0.22.0-M1\r\n" "0.22.0-M1"
}

@test "supports unix line endings (lf) in build.properties" {
  write_to_properties_and_fetch "sbt.version=0.13.13\n" "0.13.13"
}

@test "skips any irrelevant lines in build.properties" {
  write_to_properties_and_fetch "# hand written:\n\nsbt.version=0.13.13\nsbt.something = else\n" "0.13.13"
}

@test "skips to download sbt-launch.jar if a file was given via -sbt-jar" {
  touch sbt-launch.jar
  run sbt -sbt-jar sbt-launch.jar
  assert_success
  assert_output <<EOS
EOS
}

@test "uses special launcher directory if -sbt-launch-dir was given" {
  write_to_properties "stub.version=$sbt_1"
  stub_curl "${sbt_1}"
  run sbt -sbt-launch-dir "${sbt_project}/xsbt"
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_1:
  From  $(launcher_url $sbt_1)
    To  ${sbt_project}/xsbt/$sbt_1/sbt-launch.jar
Downloading sbt launcher $sbt_1 md5 hash:
  From  $(launcher_url $sbt_1).md5
    To  ${sbt_project}/xsbt/$sbt_1/sbt-launch.jar.md5
EOS
  unstub curl
}

@test "uses special launcher repository if -sbt-launch-repo was given" {
  write_to_properties "stub.version=$sbt_1"
  stub_curl "${sbt_1}"
  run sbt -sbt-launch-repo "https://127.0.0.1:8080/ivy-releases"
  assert_success
  assert_output <<EOS
Downloading sbt launcher for $sbt_1:
  From  https://127.0.0.1:8080/ivy-releases/org/scala-sbt/sbt-launch/$sbt_1/sbt-launch.jar
    To  $TEST_ROOT/.sbt/launchers/$sbt_1/sbt-launch.jar
Downloading sbt launcher $sbt_1 md5 hash:
  From  https://127.0.0.1:8080/ivy-releases/org/scala-sbt/sbt-launch/$sbt_1/sbt-launch.jar.md5
    To  $TEST_ROOT/.sbt/launchers/$sbt_1/sbt-launch.jar.md5
EOS
  unstub curl
}
