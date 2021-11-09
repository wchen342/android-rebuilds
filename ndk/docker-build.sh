#!/usr/bin/env bash
set -eux -o pipefail

VERSION='r23'

export USER=$(whoami)

# Sync sources
repo init -u https://android.googlesource.com/platform/manifest -b ndk-$VERSION --depth=1
repo sync -c -j4

# Fixes
# Remove bundled python
mv prebuilts/python3 prebuilts/python3-bak

# Build
cd ndk
python checkbuild.py --no-build-tests --package --system linux
python checkbuild.py --no-build-tests --package --system windows64
