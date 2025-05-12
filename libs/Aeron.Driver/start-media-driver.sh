#!/bin/bash

# https://stackoverflow.com/a/77663806/11045433
AeronDriverDirectory=$(dirname "$( readlink -f "${BASH_SOURCE[0]:-"$( command -v -- "$0" )"}" )")

# 1st positional parameter: aeron directory. Defaults to /dev/shm/aeron-USER
AeronDir=${1:-"/dev/shm/aeron-$(whoami)"}

source "$AeronDriverDirectory/java-with-media-driver-classpath.sh"

PrepareMediaDriverClasspath
echo Media Driver Started...
JavaWithMediaDriverClasspath -Daeron.dir="$AeronDir" io.aeron.driver.MediaDriver
echo Media Driver Stopped.
