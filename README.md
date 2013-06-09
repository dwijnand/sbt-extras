sbt: the rebel cut
==================

An alternative script for running [sbt](https://github.com/harrah/xsbt).
It works with sbt 0.7.x projects as well as 0.10+. If you're in an sbt
project directory, the runner will figure out the versions of sbt and
scala required by the project and download them if necessary.

## Installation

To install, the "sbt" bash script at the root of the project needs to be placed on your path.

    curl https://raw.github.com/paulp/sbt-extras/master/sbt > ~/bin/sbt

It is a good idea to uninstall any pre-existing sbt installations you may have.

## Sample usage

Sample usage: create a new project using a snapshot version of sbt as
well as a snapshot version of scala, then run the sbt "about" command.

    % sbt -v -sbt-snapshot -210 -sbt-create about
    Detected sbt version 0.11.3-SNAPSHOT
    sbt snapshot is 0.11.3-20111207-052114
    # Executing command line:
    java
    -XX:+CMSClassUnloadingEnabled
    -XX:+UseConcMarkSweepGC
    -Xms1536m
    -Xmx1536m
    -XX:MaxPermSize=384m
    -XX:ReservedCodeCacheSize=192m
    -Dfile.encoding=UTF8
    -jar
    /r/sbt-extras/.lib/0.11.3-SNAPSHOT/sbt-launch.jar
    "set resolvers in ThisBuild += ScalaToolsSnapshots"
    "++ 2.10.0-SNAPSHOT"
    about

    [info] Loading global plugins from /Users/paulp/.sbt/plugins
    [info] Set current project to default-71999b (in build file:/Users/paulp/Desktop/new/)
    [info] Reapplying settings...
    [info] Set current project to default-71999b (in build file:/Users/paulp/Desktop/new/)
    Setting version to 2.10.0-SNAPSHOT
    [info] Set current project to default-71999b (in build file:/Users/paulp/Desktop/new/)
    [info] This is sbt 0.11.3-20111207-052114
    [info] The current project is {file:/Users/paulp/Desktop/new/}default-71999b
    [info] The current project is built against Scala 2.10.0-SNAPSHOT
    [info] sbt, sbt plugins, and build definitions are using Scala 2.9.1

Sample, contrived usage of `prompt` option, using both `e` and `s`:

    % sbt -prompt 'e.evalTask(Keys.scalacOptions, s) + "> "'
    [info] <snip>
    List(-deprecation)> set scalacOptions += "-Xlint"
    [info] <snip>
    List(-deprecation, -Xlint)>

Current -help output:

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
      -sbt-version  <version>   use the specified version of sbt
      -sbt-jar      <path>      use the specified jar as the sbt launcher
      -sbt-snapshot             use a snapshot version of sbt
      -sbt-launch-dir <path>    directory to hold sbt launchers (default: ./.lib)

      # scala version (default: as chosen by sbt)
      -28                       use 2.8.2
      -29                       use 2.9.3
      -210                      use 2.10.0
      -scala-home <path>        use the scala build at the specified directory
      -scala-version <version>  use the specified version of scala
      -binary-version <version> use the specified scala version when searching for dependencies

      # java version (default: java from PATH, currently java version "1.7.0_15")
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

## SBT Extra plugin

To see the plugin in action, including the thrilling custom sbt command "help-names":

    cd template-project && ../sbt -sbt-rc help-names zomg zomg2

The template files are:

    project/plugins/project/Build.scala   # you can use this as-is if you want
    project/Build.scala                   # this is a starting point for your real Build.scala

The Template build isn't quite finished.  There will most likely be a build.sbt DSL variant that does not require a project scala file.

## Simple SBT DSL

SBT extras defines a simplified task DSL for those who are defining simple tasks that do not need to be relied upon, or you are unsure and can refactor later.   Once including the sbt-extra-plugin, all you have to do is place the following in your build.sbt to create tasks:

    simple_task("zomg") is { println("ZOMG") }

or if you need to depend on other keys:

    simple_task("zomg2") on (name, version) is { (n,v) => println("ZOMG " + n + " = " + v + " !!!!!") }

The DSL currently supports between 0 and 9 dependencies.  The DSL does not allow defining tasks on different configurations, although this will be added shortly.

### Simple Setttings

SBT distinguishes between defining Setting and Tasks through the `apply` and `map` methods.   The Simple DSL has no such distinction.   Defining a setting is as easy as:

    simple_setting("name") is "project-name"

Settings can also depend on other settings.

    simple_setting("name") on (version) is { v => "project-name" + v }

Since a Setting can *only* be defined using other settings, attempting to use a non-setting in the on calls results in a type error.
