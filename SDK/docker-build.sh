#!/usr/bin/env bash
set -eux -o pipefail

VERSION='s-beta-5'    # temporarily before SDK 12 comes out formally
# https://source.android.com/setup/build/building#choose-a-target
TARGET='user'    # user, userdebug, eng

export USER=$(whoami)
export BUILD_NUMBER="${TARGET}-${VERSION}"

# Sync sources
repo init -u https://android.googlesource.com/platform/manifest -b android-$VERSION --depth=1
repo sync -c -j4

# Build
# build/envsetup.sh cannot be run with -u
set +u
source build/envsetup.sh
set -u
lunch sdk-${TARGET}

# win_sdk build linux SDK too
#make -j$(nproc) sdk dist sdk_repo
make -j$(nproc) win_sdk dist sdk_repo
