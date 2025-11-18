//name := """recipe-ap"""
//organization := "com.example"
//
//version := "1.0-SNAPSHOT"
//
//lazy val root = (project in file(".")).enablePlugins(PlayScala)
//
//scalaVersion := "2.13.17"
//
//// 解决依赖版本冲突
//libraryDependencySchemes += "org.scala-lang.modules" %% "scala-xml" % VersionScheme.Always
//
//libraryDependencies += guice
//libraryDependencies += jdbc
//libraryDependencies += "com.h2database" % "h2" % "2.1.214"
//libraryDependencies += "com.typesafe.play" %% "play-slick" % "5.0.0"
//libraryDependencies += "com.typesafe.play" %% "play-slick-evolutions" % "5.0.0"
//libraryDependencies += "org.scalatestplus.play" %% "scalatestplus-play" % "7.0.2" % Test
//
//// Adds additional packages into Twirl
////TwirlKeys.templateImports += "com.example.controllers._"
//
//// Adds additional packages into conf/routes
//// play.sbt.routes.RoutesKeys.routesImport += "com.example.binders._"
name := """recipe-api"""
organization := "com.example"

version := "1.0-SNAPSHOT"

lazy val root = (project in file(".")).enablePlugins(PlayScala)

scalaVersion := "2.13.17"

libraryDependencySchemes += "org.scala-lang.modules" %% "scala-xml" % VersionScheme.Always

libraryDependencies += guice
libraryDependencies += jdbc
libraryDependencies += evolutions
libraryDependencies += "com.h2database" % "h2" % "2.1.214"
libraryDependencies += "org.postgresql" % "postgresql" % "42.7.1"
libraryDependencies += "org.scalatestplus.play" %% "scalatestplus-play" % "7.0.2" % Test