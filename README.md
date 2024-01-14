sbt: the rebel cut
==================

[![Test status](https://github.com/paulp/sbt-extras/workflows/Test/badge.svg?branch=master)](https://github.com/paulp/sbt-extras/actions?query=branch%3Amaster+workflow%3ATest)
[![Join the chat on gitter](https://badges.gitter.im/paulp/sbt-extras.svg)](https://gitter.im/paulp/sbt-extras)

An alternative script for running [sbt](https://github.com/sbt/sbt "sbt home").
It works with sbt 1 projects and (in principle) all earlier versions.
If you're in an sbt project directory, the system will figure out the
required versions of sbt and scala, downloading them if necessary.

## Installation

Put the (self-contained) [sbt script](https://raw.githubusercontent.com/dwijnand/sbt-extras/master/sbt "sbt") somewhere on your path, for instance:

```bash
curl -Ls https://raw.githubusercontent.com/dwijnand/sbt-extras/master/sbt > ~/bin/sbt && chmod 0755 ~/bin/sbt
```

Alternatively you can install with [Homebrew](https://brew.sh/):

```bash
brew install --HEAD dwijnand/extras/sbtx
```

**NOTE**: This will install sbt-extras as `sbtx` (to avoid clashing with the official sbt formula). If you prefer you can `alias sbt=sbtx`.

## Sample usage

sbt -v[erbosely] creating a new project built with the latest scala 2.12.x.

```
% sbt -v -212 -sbt-create about
[addSbt] arg = '++ 2.12.18'
[residual] arg = 'about'
No extra sbt options have been defined
Detected sbt version 1.9.8
Using default jvm options
Detected Java version: 8
# Executing command line:
java
-Xms512m
-Xss2m
-jar
$HOME/.sbt/launchers/1.9.8/sbt-launch.jar
"++ 2.12.18"
about

saving stty: [..]
[warn] No sbt.version set in project/build.properties, base directory: [..]
[info] Setting version to 2.12.18
[info] Loading settings for project global-plugins from [..] ...
[info] Loading global plugins from $HOME/.dotfiles/.sbt/1.0/plugins
[info] Set current project to [..] (in build file:[..])
[info] Setting Scala version to 2.12.18 on 1 projects.
[info] Reapplying settings...
[info] Set current project to [..] (in build file:[..])
[info] This is sbt 1.9.8
[info] The current project is ProjectRef(uri("file:[..]"), "[..]") [..]
[info] The current project is built against Scala 2.12.18
[info] Available Plugins
[..]
[info] sbt, sbt plugins, and build definitions are using Scala 2.12.7

restoring stty: [..]
```

## sbt -h
```
Usage: sbt [options]

Note that options which are passed along to sbt begin with -- whereas
options to this runner use a single dash. Any sbt command can be scheduled
to run first by prefixing the command with --, so --warn, --error and so on
are not special.

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
  -script <file>     Run the specified file as a scala script

  # sbt version (default: sbt.version from project/build.properties if present, otherwise 1.9.8)
  -sbt-version <version>  use the specified version of sbt (default: 1.9.8)
  -sbt-force-latest       force the use of the latest release of sbt: 1.9.8
  -sbt-dev                use the latest pre-release version of sbt: 1.9.8
  -sbt-jar      <path>    use the specified jar as the sbt launcher
  -sbt-launch-dir <path>  directory to hold sbt launchers (default: ~/.sbt/launchers)
  -sbt-launch-repo <url>  repo url for downloading sbt launcher jar (default: https://repo.scala-sbt.org/scalasbt/maven-releases)

  # scala version (default: as chosen by sbt)
  -28                        use 2.8.2
  -29                        use 2.9.3
  -210                       use 2.10.7
  -211                       use 2.11.12
  -212                       use 2.12.18
  -213                       use 2.13.12
  -scala-home <path>         use the scala build at the specified directory
  -scala-version <version>   use the specified version of scala
  -binary-version <version>  use the specified scala version when searching for dependencies

  # java version (default: java from PATH, currently java version "1.8.2_202-ea")
  -java-home <path>          alternate JAVA_HOME

  # passing options to the jvm - note it does NOT use JAVA_OPTS due to pollution
  # The default set is used if JVM_OPTS is unset and no -jvm-opts file is found
  <default>         -Xms512m -Xss2m -XX:MaxInlineLevel=18
  JVM_OPTS          environment variable holding either the jvm args directly, or
                    the reference to a file containing jvm args if given path is prepended by '@' (e.g. '@/etc/jvmopts')
                    Note: "@"-file is overridden by local '.jvmopts' or '-jvm-opts' argument.
  -jvm-opts <path>  file containing jvm args (if not given, .jvmopts in project root is used if present)
  -Dkey=val         pass -Dkey=val directly to the jvm
  -J-X              pass option -X directly to the jvm (-J is stripped)

  # passing options to sbt, OR to this runner
  SBT_OPTS          environment variable holding either the sbt args directly, or
                    the reference to a file containing sbt args if given path is prepended by '@' (e.g. '@/etc/sbtopts')
                    Note: "@"-file is overridden by local '.sbtopts' or '-sbt-opts' argument.
  -sbt-opts <path>  file containing sbt args (if not given, .sbtopts in project root is used if present)
  -S-X              add -X to sbt's scalacOptions (-S is stripped)

  # passing options exclusively to this runner
  SBTX_OPTS         environment variable holding either the sbt-extras args directly, or
                    the reference to a file containing sbt-extras args if given path is prepended by '@' (e.g. '@/etc/sbtxopts')
                    Note: "@"-file is overridden by local '.sbtxopts' or '-sbtx-opts' argument.
  -sbtx-opts <path> file containing sbt-extras args (if not given, .sbtxopts in project root is used if present)
```
