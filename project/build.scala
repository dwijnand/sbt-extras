import sbt._
import Keys._

object SbtExtras extends Build {
  val root = Project("sbt-extras", file(".")) settings(DebianPkg.settings:_*)
}

object DebianPkg {
  val Debian = config("debian-pkg")
  val makeDebianExplodedPackage = TaskKey[File]("make-debian-exploded-package")

  val settings: Seq[Setting[_]] = Seq(
    resourceDirectory in Debian <<= baseDirectory(_ / "src" / "debian"),
    target in Debian <<= target(_ / "debian"),
    mappings in Debian <<= resourceDirectory in Debian map { d => (d.*** --- d) x (relativeTo(d)) },
    mappings in Debian <+= baseDirectory map { dir => (dir / "sbt" -> "usr/bin/sbt") },
    makeDebianExplodedPackage <<= (mappings in Debian, target in Debian) map { (files, dir) =>
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
    packageBin in Debian <<= (makeDebianExplodedPackage, target in Debian) map { (pkgdir, tdir) =>
       Process(Seq("dpkg-deb", "--build", pkgdir.getAbsolutePath), Some(tdir)).!
      tdir / "debian.deb"
    }
  )
  
}
