#!/usr/bin/env bash
set -eux -o pipefail

VERSION='12.0.0_r13'    # temporarily before SDK 12 comes out formally
# https://source.android.com/setup/build/building#choose-a-target
TARGET_USER='user'    # user, userdebug, eng
TARGET_ENG='eng'    # user, userdebug, eng

export JAVA_TOOL_OPTIONS="-Xmx8g"    # increase Java heap size

export USER=$(whoami)

# Sync sources
repo init -u https://android.googlesource.com/platform/manifest -b android-$VERSION --depth=1
repo sync -c -j4

# Various fixes
pushd development && git apply ../development.patch && popd

# Build

# build user
export BUILD_NUMBER="${TARGET_USER}-${VERSION}"
# build/envsetup.sh and lunch cannot be run with -u
set +u
source build/envsetup.sh
lunch sdk_arm64-${TARGET_USER}
set -u

# win_sdk build linux SDK too
#make -j$(nproc) sdk dist sdk_repo
make -j$(nproc) win_sdk dist sdk_repo

# build eng
export BUILD_NUMBER="${TARGET_ENG}-${VERSION}"
set +u
lunch sdk_arm64-${TARGET_ENG}
set -u

# win_sdk build linux SDK too
#make -j$(nproc) sdk dist sdk_repo
make -j$(nproc) win_sdk dist sdk_repo
