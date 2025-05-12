#!/bin/bash

# define constants
aeronGroup="io.aeron"
aeronDriverArtifactId="aeron-driver"
aeronDriverArtifactVersion="1.47.5"
javaVersion="java-17"

# https://stackoverflow.com/a/77663806/11045433
AeronDriverDirectory=$(dirname "$( readlink -f "${BASH_SOURCE[0]:-"$( command -v -- "$0" )"}" )")

# https://serverfault.com/a/1100799
Java=$(update-alternatives --list java | grep "$javaVersion")

# 1st positional parameter: aeron directory. Defaults to /dev/shm/aeron-USER
AeronDir=${1:-"/dev/shm/aeron-$(whoami)"}

function groupPathFromGroupName() {
  local groupName="${1:?missing group name argument}"
  echo "$groupName" | sed 's/\./\//g'
}

function GetArtifactFromMaven() {
  local group="${1:?missing group name argument}"
  local artifact="${2:?missing artifact ID argument}"
  local version="${3:?missing artifact version argument}"

  echo "Fetching artifacts from Maven..." >&2
  mvn dependency:get -Dartifact="$group":"$artifact":"$version" >&2
}

function ResolveClasspath() {
  local group="${1:?missing group name argument}"
  local artifact="${2:?missing artifact ID argument}"
  local version="${3:?missing artifact version argument}"
  local classpathFile="${4:?missing classpath file argument}"

  local groupPath
  groupPath="$(groupPathFromGroupName "$group")"
  local artifactFileStem="$HOME/.m2/repository/$groupPath/$artifact/$version/$artifact-$version"
  local artifactJar="$artifactFileStem".jar
  local artifactPom="$artifactFileStem".pom

  if [ ! -e "$artifactJar" ]; then
    GetArtifactFromMaven "$group" "$artifact" "$version"
  fi
  
  echo "Building classpath using Maven..." >&2
  mvn -f "$artifactPom" dependency:build-classpath \
    -Dmdep.includeScope=runtime \
    -Dmdep.outputFile="$classpathFile" >&2
  printf ":%s" "$artifactJar" >> "$classpathFile"
}

function CachedResolveClasspath() {
  local group="${1:?missing group name argument}"
  local artifact="${2:?missing artifact ID argument}"
  local version="${3:?missing artifact version argument}"
  local classpathFile="${4:?missing classpath file argument}"

  if [ ! -e "$classpathFile" ]; then
    ResolveClasspath "$group" "$artifact" "$version" "$classpathFile"
  fi
  cat "$classpathFile"
}

classpath="$(
  CachedResolveClasspath "$aeronGroup" "$aeronDriverArtifactId" "$aeronDriverArtifactVersion" \
    "$AeronDriverDirectory/classpath.txt.local"
)"

echo Media Driver Started...
$Java --add-exports java.base/jdk.internal.misc=ALL-UNNAMED \
  -cp "$classpath" \
  -Daeron.dir="$AeronDir" io.aeron.driver.MediaDriver
echo Media Driver Stopped.
