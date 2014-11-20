sbt: the rebel cut
==================

[![Build Status](https://travis-ci.org/paulp/sbt-extras.png)](https://travis-ci.org/paulp/sbt-extras)

An alternative script for running [sbt](https://github.com/sbt/sbt "sbt home").
It works with sbt 0.13.0 projects and (in principle) all earlier versions.
If you're in an sbt project directory, the system will figure out the
required versions of sbt and scala, downloading them if necessary.

## Installation

Put the (self-contained) [sbt script](https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt "sbt") somewhere on your path, for instance:

```bash
curl -s https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt > ~/bin/sbt \
  && chmod 0755 ~/bin/sbt
```

## Sample usage

sbt -v[erbosely] creating a new project built with the latest scala 2.10.x.

```
% sbt -v -210 -sbt-create about
Detected sbt version 0.13.7
Detected Java version: 1.8.0_25
# Executing command line:
/Library/Java/JavaVirtualMachines/jdk1.8.0_11.jdk/Contents/Home/bin/java
-jar
$HOME/.sbt/launchers/0.13.7/sbt-launch.jar
"++ 2.10.4"
about

[info] Setting version to 2.10.4
[info] This is sbt 0.13.7
[info] The current project is built against Scala 2.10.4
[info] sbt, sbt plugins, and build definitions are using Scala 2.10.4
```

## sbt -h
```
Usage: sbt [options]

Note that options which are passed along to sbt begin with -- whereas
options to this runner use a single dash. Any sbt command can be scheduled
to run first by prefixing the command with --, so --warn, --error and so on
are not special.

Output filtering: if there is a file in the home directory called .sbtignore
and this is not an interactive sbt session, the file is treated as a list of
bash regular expressions. Output lines which match any regex are not echoed.
One can see exactly which lines would have been suppressed by starting this
runner with the -x option.

  -h | -help         print this message
  -v                 verbose operation (this runner is chattier)
  -d, -w, -q         aliases for --debug, --warn, --error (q means quiet)
  -x                 debug this script
  -trace <level>     display stack traces with a max of <level> frames (default: -1, traces suppressed)
  -debug-inc         enable debugging log for the incremental compiler
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

  # sbt version (default: sbt.version from project/build.properties if present, otherwise 0.13.7)
  -sbt-force-latest         force the use of the latest release of sbt: 0.13.7
  -sbt-version  <version>   use the specified version of sbt (default: 0.13.7)
  -sbt-dev                  use the latest pre-release version of sbt: 0.13.8-M1
  -sbt-jar      <path>      use the specified jar as the sbt launcher
  -sbt-launch-dir <path>    directory to hold sbt launchers (default: ~/.sbt/launchers)
  -sbt-launch-repo <url>    repo url for downloading sbt launcher jar (default: http://typesafe.artifactoryonline.com/typesafe/ivy-releases)

  # scala version (default: as chosen by sbt)
  -28                       use 2.8.2
  -29                       use 2.9.3
  -210                      use 2.10.4
  -211                      use 2.11.4
  -scala-home <path>        use the scala build at the specified directory
  -scala-version <version>  use the specified version of scala
  -binary-version <version> use the specified scala version when searching for dependencies

  # java version (default: java from PATH, currently java version "1.7.0_65")
  -java-home <path>         alternate JAVA_HOME

  # passing options to the jvm - note it does NOT use JAVA_OPTS due to pollution
  # The default set is used if JVM_OPTS is unset and no -jvm-opts file is found
  <default>        -XX:MaxPermSize=384m -Xms512m -Xmx1536m -Xss2m -XX:ReservedCodeCacheSize=256m -XX:+TieredCompilation -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC
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
```

## My ~/.sbtignore - fairly aggressive.

```
# sbt ignore regexps
Starting sbt with output filtering enabled
^\[info\][ ]+(Resolving|Loading|Done|Attempting|Formatting|Updating)[ ]
^\[info\] Main Scala API documentation
^\[info\].*published[ ]+.*(sources\.jar|javadoc\.jar|\.pom)$
^\[info\].*published ivy to
^\[warn\] Credentials file
^\[info\] Wrote.*[.]pom
This usage is deprecated
Attempting to overwrite
delivering ivy file to
warnings? found$
re[-]run with [-](unchecked|deprecation|feature) for details
model contains[ ]
[ ]delivering[ ]
^Graphviz dot encountered an error when generating the diagram for:
^These are usually spurious errors, but if you notice a persistant error on
^a diagram, please use the -diagrams-debug flag and report a bug with the output
^Graphviz will be restarted...
^Diagrams will be disabled for this run because the graphviz dot tool
^has malfunctioned too many times. These scaladoc flags may help:
^Please note that graphviz package
^[*]+$
^-diagrams-
^$
```
