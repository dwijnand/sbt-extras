sbt: the rebel cut
==================

An alternative script for running [sbt](https://github.com/sbt/sbt).
It works with sbt 0.13.0 projects and (in principle) all earlier versions.
If you're in an sbt project directory, the system will figure out the
required versions of sbt and scala, downloading them if necessary.

## Installation

Put the (self-contained) sbt script somewhere on your path.

    curl -s https://raw.github.com/paulp/sbt-extras/master/sbt > ~/bin/sbt && chmod 0755 ~/bin/sbt

## Sample usage

sbt -v[erbosely] creating a new project built with the latest scala 2.10.x.

    % sbt -v -210 -sbt-create about
    Detected sbt version 0.13.0
    Using $HOME/.sbt/0.13.0 as sbt dir, -sbt-dir to override.
    # Executing command line:
    /System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home/bin/java
    -Xmx1g
    -jar
    /Users/paulp/.sbt/launchers/0.13.0/sbt-launch.jar
    "++ 2.10.3-RC1"
    about

    [info] Setting version to 2.10.3-RC1
    [info] This is sbt 0.13.0
    [info] The current project is built against Scala 2.10.3-RC1
    [info]
    [info] sbt, sbt plugins, and build definitions are using Scala 2.10.2

## sbt -h

    Usage: sbt [options]

      -h | -help         print this message
      -v | -verbose      this runner is chattier
      -d | -debug        set sbt log level to Debug
      -q | -quiet        set sbt log level to Error
      -trace <level>     display stack traces with a max of <level> frames (default: -1, traces suppressed)
      -no-colors         disable ANSI color codes
      -sbt-create        start sbt even if current directory contains no sbt project
      -sbt-dir   <path>  path to global settings/plugins directory (default: ~/.sbt/<version>)
      -sbt-boot  <path>  path to shared boot directory (default: ~/.sbt/boot in 0.11+)
      -ivy       <path>  path to local Ivy repository (default: ~/.ivy2)
      -no-share          use all local caches; no sharing
      -offline           put sbt in offline mode
      -jvm-debug <port>  Turn on JVM debugging, open at the given port.
      -batch             Disable interactive mode
      -prompt <expr>     Set the sbt prompt; in expr, 's' is the State and 'e' is Extracted

      # sbt version (default: from project/build.properties if present, else latest release)
      !!! The only way to accomplish this pre-0.12.0 if there is a build.properties file which
      !!! contains an sbt.version property is to update the file on disk.  That's what this does.
      -sbt-version  <version>   use the specified version of sbt (default: 0.13.0)
      -sbt-jar      <path>      use the specified jar as the sbt launcher
      -sbt-launch-dir <path>    directory to hold sbt launchers (default: /Users/paulp/.sbt/launchers)

      # scala version (default: as chosen by sbt)
      -28                       use 2.8.2
      -29                       use 2.9.3
      -210                      use 2.10.3 (or latest 2.10.x release or RC)
      -211                      use 2.11.0-M4 (or latest milestone)
      -scala-home <path>        use the scala build at the specified directory
      -scala-version <version>  use the specified version of scala
      -binary-version <version> use the specified scala version when searching for dependencies

      # java version (default: java from PATH, currently java version "1.6.0_51")
      -java-home <path>         alternate JAVA_HOME

      # passing options to the jvm - note it does NOT use JAVA_OPTS due to pollution
      # The default set is used if JVM_OPTS is unset and no -jvm-opts file is found
      <default>        -Dfile.encoding=UTF8 -XX:MaxPermSize=256m -Xms512m -Xmx1g -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC
      JVM_OPTS         environment variable holding either the jvm args directly, or
                       the reference to a file containing jvm args if given path is prepended by '@' (e.g. '@/etc/jvmopts')
                       Note: "@"-file is overridden by local '.jvmopts' or '-jvm-opts' argument.
      -jvm-opts <path> file containing jvm args (if not given, .jvmopts in project root is used if present)
      -Dkey=val        pass -Dkey=val directly to the jvm
      -J-X             pass option -X directly to the jvm (-J is stripped)

      # passing options to sbt, OR to this runner
      SBT_OPTS         environment variable holding either the sbt args directly, or
                       the reference to a file containing sbt args if given path is prepended by '@' (e.g. '@/etc/sbtopts')
                       Note: "@"-file is overridden by local '.sbtopts' or '-sbt-opts' argument.
      -sbt-opts <path> file containing sbt args (if not given, .sbtopts in project root is used if present)
      -S-X             add -X to sbt's scalacOptions (-S is stripped)
