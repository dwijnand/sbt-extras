export TMP="$BATS_TEST_DIRNAME/tmp"
export HOME="$TMP"
export PATH="$BATS_TEST_DIRNAME/../bin:$TMP/bin:/usr/bin:/usr/sbin:/bin:/sbin"

unset JAVA_HOME
unset JVM_OPTS
unset SBT_OPTS

export sbt_latest_07="0.7.7"
export sbt_latest_10="0.10.1"
export sbt_latest_11="0.11.3"
export sbt_latest_12="0.12.4"
export sbt_latest_13="0.13.2"
export sbt_latest_dev="0.13.5-M4"

export sbt_release_version="$sbt_latest_13"
export sbt_unreleased_version="$sbt_latest_dev"

export cms_opts="-XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC"
export jit_opts="-XX:ReservedCodeCacheSize=256m -XX:+TieredCompilation"
export default_jvm_opts="-Dfile.encoding=UTF8 -XX:MaxPermSize=384m -Xms512m -Xmx1536m -Xss2m $jit_opts $cms_opts"
export noshare_opts="-Dsbt.global.base=project/.sbtboot -Dsbt.boot.directory=project/.boot -Dsbt.ivy.home=project/.ivy"
export latest_28="2.8.2"
export latest_29="2.9.3"
export latest_210="2.10.4"
export latest_211="2.11.0"

# Usage: f <string which should be in output> [args to sbt]
sbt_expecting () {
  local expecting="$1" && shift
  stub_java
  run sbt "$@"
  assert_success
  assert_output_contains "$expecting"
  unstub java
}

echo_default_jvm_opts () {
  OLDIFS=$IFS
  IFS=" "
  for arg in $default_jvm_opts; do echo "$arg"; done
  IFS="$OLDIFS"
}

echo_closing_jvm_opts () {
  cat <<EOM
-Dsbt.global.base=$HOME/.sbt/$1
-jar
$HOME/.sbt/launchers/$1/sbt-launch.jar
shell
EOM
}

standard_java_options () {
  echo_default_jvm_opts
  echo_closing_jvm_opts
}

setup_version_project () {
  create_project

  if [[ $# -eq 0 ]]; then
    create_launcher $sbt_release_version
  else
    create_launcher $1
    echo "sbt.version=$1" > "$sbt_project/project/build.properties"
  fi
}

create_project() {
  export sbt_project="${TMP}/myproject"
  mkdir -p "${sbt_project}/project"
  cd "${sbt_project}"
}

create_launcher() {
  mkdir -p "${TMP}/.sbt/launchers/$1"
  touch "${TMP}/.sbt/launchers/$1/sbt-launch.jar"
}

java_options() {
  echo_default_jvm_opts
  cat
}

teardown() {
  rm -fr "$TMP"/* "$TMP"/.sbt
}

stub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  shift

  export "${prefix}_STUB_PLAN"="${TMP}/${program}-stub-plan"
  export "${prefix}_STUB_RUN"="${TMP}/${program}-stub-run"
  export "${prefix}_STUB_END"=

  mkdir -p "${TMP}/bin"
  ln -sf "${BATS_TEST_DIRNAME}/stubs/stub" "${TMP}/bin/${program}"

  touch "${TMP}/${program}-stub-plan"
  for arg in "$@"; do printf "%s\n" "$arg" >> "${TMP}/${program}-stub-plan"; done
}

unstub() {
  local program="$1"
  local prefix="$(echo "$program" | tr a-z- A-Z_)"
  local path="${TMP}/bin/${program}"

  export "${prefix}_STUB_END"=1

  local STATUS=0
  "$path" || STATUS="$?"

  rm -f "$path"
  rm -f "${TMP}/${program}-stub-plan" "${TMP}/${program}-stub-run"
  return "$STATUS"
}

assert() {
  if ! "$@"; then
    flunk "failed: $@"
  fi
}

flunk() {
  { if [ "$#" -eq 0 ]; then cat -
    else echo "$@"
    fi
  } | sed "s:${TMP}:\${TMP}:g" >&2
  return 1
}

assert_success() {
  if [ "$status" -ne 0 ]; then
    { echo "command failed with exit status $status"
      echo "output: $output"
    } | flunk
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_failure() {
  if [ "$status" -eq 0 ]; then
    flunk "expected failed exit status"
  elif [ "$#" -gt 0 ]; then
    assert_output "$1"
  fi
}

assert_equal() {
  if [ "$1" != "$2" ]; then
    { echo "expected: $1"
      echo "actual:   $2"
    } | flunk
  fi
}

assert_output() {
  local expected
  if [ $# -eq 0 ]; then expected="$(cat -)"
  else expected="$1"
  fi
  assert_equal "$expected" "$output"
}

assert_output_contains() {
  local expected="$1"
  echo "$output" | grep -F -- "$expected" >/dev/null || {
    { echo "expected output to contain $expected"
      echo "actual: $output"
    } | flunk
  }
}

stub_java () {
  stub java 'for arg; do echo "$arg"; done'
}
