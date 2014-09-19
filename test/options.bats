#!/usr/bin/env bats

load test_helper

@test "-ivy       => -Dsbt.ivy.home"       { sbt_expecting "-Dsbt.ivy.home=$sbt_project/ivy" -ivy "$sbt_project/ivy";                               }
@test "-no-colors => -Dsbt.log.noformat"   { sbt_expecting "-Dsbt.log.noformat=true" -no-colors;                                                    }
@test "-sbt-boot  => -Dsbt.boot.directory" { sbt_expecting "-Dsbt.boot.directory=$sbt_project/sbt.boot" -sbt-boot "$sbt_project/sbt.boot";          }
@test "-debug-inc => -Dxsbt.inc.debug"     { sbt_expecting "-Dxsbt.inc.debug=true" -debug-inc;                                                      }
@test "-offline   => offline setting"      { sbt_expecting "set offline := true" -offline;                                                          }
@test "-Sopt      => scalac -opt"          { sbt_expecting 'set scalacOptions in ThisBuild += "-P:continuations:enable"' -S-P:continuations:enable; }
@test "-prompt    => shellPrompt"          { sbt_expecting "set shellPrompt in ThisBuild" -prompt 'bippy> ';                                        }

@test "-jvm-debug => -Xdebug, -Xrunjdwp:transport" {
  sbt_expecting "-Xdebug" -jvm-debug 8000
  sbt_expecting "-Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000" -jvm-debug 8000
}

@test "-no-share => -Dsbt.global.base,-Dsbt.boot.directory,-Dsbt.ivy.home" {
  sbt_expecting "-Dsbt.global.base=project/.sbtboot" -no-share
  sbt_expecting "-Dsbt.boot.directory=project/.boot" -no-share
  sbt_expecting "-Dsbt.ivy.home=project/.ivy" -no-share
}
