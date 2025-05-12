#!/bin/bash

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
export -f GetArtifactFromMaven

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
export -f ResolveClasspath

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
export -f CachedResolveClasspath
