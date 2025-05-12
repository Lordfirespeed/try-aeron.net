#!/bin/bash

# define constants
AERON_GROUP="io.aeron"
AERON_DRIVER_ARTIFACT_ID="aeron-driver"
AERON_DRIVER_ARTIFACT_VERSION="1.47.5"
JAVA_VERSION="17"

# https://stackoverflow.com/a/77663806/11045433
script_directory=$(dirname "$( readlink -f "${BASH_SOURCE[0]:-"$( command -v -- "$0" )"}" )")

# https://serverfault.com/a/1100799
java_exe=$(update-alternatives --list java | grep "java-$JAVA_VERSION")

function GroupPathFromGroupName() {
  local group="${1:?missing group name argument}"
  echo "$group" | sed 's/\./\//g'
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
  local classpath_file="${4:?missing classpath file argument}"

  local group_path
  group_path="$(GroupPathFromGroupName "$group")"
  local artifact_file_stem="$HOME/.m2/repository/$group_path/$artifact/$version/$artifact-$version"
  local artifact_jar="$artifact_file_stem".jar
  local artifact_pom="$artifact_file_stem".pom

  if [ ! -e "$artifact_jar" ]; then
    GetArtifactFromMaven "$group" "$artifact" "$version"
  fi

  echo "Building classpath using Maven..." >&2
  mvn -f "$artifact_pom" dependency:build-classpath \
    -Dmdep.includeScope=runtime \
    -Dmdep.outputFile="$classpath_file" >&2
  printf ":%s" "$artifact_jar" >> "$classpath_file"
}

function CachedResolveClasspath() {
  local group="${1:?missing group name argument}"
  local artifact="${2:?missing artifact ID argument}"
  local version="${3:?missing artifact version argument}"
  local classpath_file="${4:?missing classpath file argument}"

  if [ ! -e "$classpath_file" ]; then
    ResolveClasspath "$group" "$artifact" "$version" "$classpath_file"
  fi
  cat "$classpath_file"
}

function PrepareMediaDriverClasspath() {
  MEDIA_DRIVER_CLASSPATH="$(
    CachedResolveClasspath "$AERON_GROUP" "$AERON_DRIVER_ARTIFACT_ID" "$AERON_DRIVER_ARTIFACT_VERSION" \
      "$script_directory/classpath.txt.local"
  )"
}
export -f PrepareMediaDriverClasspath

function JavaWithMediaDriverClasspath() {
  "$java_exe" --add-exports java.base/jdk.internal.misc=ALL-UNNAMED -cp "$MEDIA_DRIVER_CLASSPATH" "$@"
}
export -f JavaWithMediaDriverClasspath
