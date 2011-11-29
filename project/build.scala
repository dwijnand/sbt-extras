import sbt._
import Keys._

object SbtExtras extends Build {
  val root = Project("sbt-extras", file(".")) settings(DebianPkg.settings:_*)
}

object DebianPkg {
  val Debian = config("debian-pkg")
  val makeDebianExplodedPackage = TaskKey[File]("make-debian-exploded-package")
  val makeZippedPackageSource = TaskKey[Unit]("make-zipped-package-source")
  val genControlFile = TaskKey[File]("generate-control-file")
  val lintian = TaskKey[Unit]("lintian")

  val settings: Seq[Setting[_]] = Seq(
    resourceDirectory in Debian <<= baseDirectory(_ / "src" / "debian"),
    resourceDirectory in Debian in makeZippedPackageSource <<= baseDirectory(_ / "src" / "debian-gzipped"),
    mappings in Debian <<= resourceDirectory in Debian map { d => (d.*** --- d) x (relativeTo(d)) },
    mappings in Debian in makeZippedPackageSource <<= resourceDirectory in Debian in makeZippedPackageSource map { d => (d.*** --- d) x (relativeTo(d)) },
    // TODO - put sbt-version into the generated sbt script.
    mappings in Debian <+= baseDirectory map { dir => (dir / "sbt" -> "usr/bin/sbt") },
    name in Debian := "sbt",
    version in Debian <<= (version, sbtVersion) apply { (v, sv) =>       
       sv + "-build-" + (v split "\\." map (_.toInt) dropWhile (_ == 0) map ("%02d" format _) mkString "")
    },
    target in Debian <<= (target, name in Debian, version in Debian) apply ((t,n, v) => t / (n +"-"+ v)),
    genControlFile <<= (name in Debian, version in Debian, target in Debian) map {
      (name, version, dir) =>
        val cfile = dir / "DEBIAN" / "control"
        IO.writer(cfile, ControlFileContent, java.nio.charset.Charset.defaultCharset, false) { o =>
           val out = new java.io.PrintWriter(o)
           out println ("Package: %s" format name)
           out println ("Version: %s" format version)
           out println ControlFileContent
        }
        cfile
    },
    makeDebianExplodedPackage <<= (mappings in Debian, genControlFile, target in Debian) map { (files, _, dir) =>
       for((file, target) <- files) {
          val tfile = dir / target
          if(file.isDirectory) IO.createDirectory(tfile)
          else {
            IO.copyFile(file,tfile)
            if(file.canExecute) tfile.setExecutable(true, false)
            if(file.canRead) tfile.setReadable(true, false)
          }
        }
        dir      
    },
    makeZippedPackageSource <<= (mappings in Debian in makeZippedPackageSource, target in Debian) map { (files, dir) =>
        for((file, target) <- files) {
          val tfile = dir / target
          if(file.isDirectory) IO.createDirectory(tfile)
          else {
            val zipped = new File(tfile.getAbsolutePath + ".gz")
            IO delete zipped
            IO.copyFile(file,tfile)
            Process(Seq("gzip", "--best", tfile.getAbsolutePath), Some(tfile.getParentFile)).!
          }
        }
        dir      
    },
    packageBin in Debian <<= (makeDebianExplodedPackage, makeZippedPackageSource, target in Debian, name in Debian, version in Debian) map { (pkgdir, _, tdir, n, v) =>
       Process(Seq("dpkg-deb", "--build", pkgdir.getAbsolutePath), Some(tdir)).!
      tdir.getParentFile / (n + "-" + v + ".deb")
    },
    lintian <<= (packageBin in Debian) map { file =>
       println("lintian -c " + file.getName + " on " + file.getParentFile.getAbsolutePath)
       Process(Seq("lintian", "-c", file.getName), Some(file.getParentFile)).!
    }
  )


  final val ControlFileContent = """Section: base
Priority: optional
Architecture: all
Depends:   curl, openjdk-6-jre-headless, bash (>= 2.05a-11)
Maintainer: Josh Suereth <joshua.suereth@typesafe.com>
Description: Simple Build Tool
 This script provides a native way to run the Simple Build Tool,
 a build tool for Scala software, also called SBT.
"""
}
