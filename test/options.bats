#!/usr/bin/env bats

load test_helper

setup() { setup_version_project; }

@test "-ivy triggers sbt.ivy.home"            { sbt_expecting "-Dsbt.ivy.home=$sbt_project/ivy" -ivy "$sbt_project/ivy";                               }
@test "-no-colors triggers sbt.log.noformat"  { sbt_expecting "-Dsbt.log.noformat=true" -no-colors;                                                    }
@test "-sbt-boot triggers sbt.boot.directory" { sbt_expecting "-Dsbt.boot.directory=$sbt_project/sbt.boot" -sbt-boot "$sbt_project/sbt.boot";          }
@test "-debug-inc triggers xsbt.inc.debug"    { sbt_expecting "-Dxsbt.inc.debug=true" -debug-inc;                                                      }
@test "-offline triggers offline mode"        { sbt_expecting "set offline := true" -offline;                                                          }
@test "-S passes scalac options"              { sbt_expecting 'set scalacOptions in ThisBuild += "-P:continuations:enable"' -S-P:continuations:enable; }

@test "-prompt enables custom prompt" {
  sbt_expecting 'set shellPrompt in ThisBuild := (s => { val e = Project.extract(s) ; "% " })' -prompt '"% "';
}

@test "-jvm-debug triggers jvm debug options" {
  sbt_expecting "-Xdebug" -jvm-debug 8000
  sbt_expecting "-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000" -jvm-debug 8000
}

@test "-no-share sets three properties" {
  sbt_expecting "-Dsbt.global.base=project/.sbtboot" -no-share
  sbt_expecting "-Dsbt.boot.directory=project/.boot" -no-share
  sbt_expecting "-Dsbt.ivy.home=project/.ivy" -no-share
}
