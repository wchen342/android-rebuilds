#!/usr/bin/env bash
set -eux -o pipefail

VERSION='12.0.0_r2'    # temporarily before SDK 12 comes out formally
# https://source.android.com/setup/build/building#choose-a-target
TARGET='eng'    # user, userdebug, eng

export USER=$(whoami)
export BUILD_NUMBER="${TARGET}-${VERSION}"

# Sync sources
repo init -u https://android.googlesource.com/platform/manifest -b android-$VERSION --depth=1
repo sync -c -j4

# Various fixes
pushd development && git apply ../development.patch && popd

# Build
# build/envsetup.sh cannot be run with -u
set +u
source build/envsetup.sh
lunch sdk_arm64-${TARGET}
set -u

# win_sdk build linux SDK too
#make -j$(nproc) sdk dist sdk_repo
make -j$(nproc) win_sdk dist sdk_repo
