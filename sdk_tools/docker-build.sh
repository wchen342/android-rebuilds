#!/usr/bin/env bash
set -eux -o pipefail

VERSION='main'    # 4.3.0

export USER=$(whoami)

# Sync sources
repo init -u https://android.googlesource.com/platform/manifest -b studio-$VERSION
repo sync -c -j4

# SDK tools
# https://sites.google.com/a/android.com/tools/build/#TOC-Building-the-Linux-and-MacOS-SDK
mkdir -p out/dist

# Build

