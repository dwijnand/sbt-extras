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

Sample usage: create a new project using snapshot version of scala 2.11.0, then run the sbt "about" command.

    % sbt -v -scala-version 2.11.0-SNAPSHOT -sbt-create about
    No extra sbt options have been defined
    Detected sbt version 0.13.0
    Using /Users/paulp/.sbt/0.13.0 as sbt dir, -sbt-dir to override.
    Using default jvm options
    # Executing command line:
    java
    -Dfile.encoding=UTF8
    -XX:MaxPermSize=256m
    -Xms512m
    -Xmx1g
    -XX:+CMSClassUnloadingEnabled
    -XX:+UseConcMarkSweepGC
    -jar
    /Users/paulp/.sbt/launchers/0.13.0/sbt-launch.jar
    "set resolvers += Resolver.sonatypeRepo("snapshots")"
    "++ "2.11.0-SNAPSHOT""
    about

    [info] Set current project to default-71999b (in build file:/Users/paulp/Desktop/new/)
    [info] Defining *:resolvers
    [info] The new value will be used by *:externalResolvers
    [info] Reapplying settings...
    [info] Set current project to default-71999b (in build file:/Users/paulp/Desktop/new/)
    [info] Setting version to 2.11.0-SNAPSHOT
    [info] Set current project to default-71999b (in build file:/Users/paulp/Desktop/new/)
    [info] Updating {file:/Users/paulp/Desktop/new/}default-71999b...
    [info] Resolving jline#jline;2.11 ...
    [info] downloading https://oss.sonatype.org/content/repositories/snapshots/org/scala-lang/scala-library/2.11.0-SNAPSHOT/scala-library-2.11.0-20130827.010728-375.jar ...
    [info]  [SUCCESSFUL ] org.scala-lang#scala-library;2.11.0-SNAPSHOT!scala-library.jar (87077ms)
    [info] downloading https://oss.sonatype.org/content/repositories/snapshots/org/scala-lang/scala-compiler/2.11.0-SNAPSHOT/scala-compiler-2.11.0-20130827.010728-374.jar ...
    [info]  [SUCCESSFUL ] org.scala-lang#scala-compiler;2.11.0-SNAPSHOT!scala-compiler.jar (58319ms)
    [info] downloading https://oss.sonatype.org/content/repositories/snapshots/org/scala-lang/scala-xml/2.11.0-SNAPSHOT/scala-xml-2.11.0-20130827.010728-46.jar ...
    [info]  [SUCCESSFUL ] org.scala-lang#scala-xml;2.11.0-SNAPSHOT!scala-xml.jar (5290ms)
    [info] downloading https://oss.sonatype.org/content/repositories/snapshots/org/scala-lang/scala-parser-combinators/2.11.0-SNAPSHOT/scala-parser-combinators-2.11.0-20130827.010728-46.jar ...
    [info]  [SUCCESSFUL ] org.scala-lang#scala-parser-combinators;2.11.0-SNAPSHOT!scala-parser-combinators.jar (19014ms)
    [info] downloading https://oss.sonatype.org/content/repositories/snapshots/org/scala-lang/scala-reflect/2.11.0-SNAPSHOT/scala-reflect-2.11.0-20130827.010728-374.jar ...
    [info]  [SUCCESSFUL ] org.scala-lang#scala-reflect;2.11.0-SNAPSHOT!scala-reflect.jar (15601ms)
    [info] Done updating.
    [info] This is sbt 0.13.0
    [info] The current project is {file:/Users/paulp/Desktop/new/}default-71999b
    [info] The current project is built against Scala 2.11.0-SNAPSHOT
    [info]
    [info] sbt, sbt plugins, and build definitions are using Scala 2.10.2

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
