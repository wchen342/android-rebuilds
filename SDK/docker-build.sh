#!/usr/bin/env bash
set -eux -o pipefail

VERSION='s-beta-5'    # temporarily before SDK 12 comes out formally
# https://source.android.com/setup/build/building#choose-a-target
TARGET='eng'    # user, userdebug, eng

export USER=$(whoami)
export BUILD_NUMBER="${TARGET}-${VERSION}"

# Sync sources
repo init -u https://android.googlesource.com/platform/manifest -b android-$VERSION --depth=1
repo sync -c -j4

# Various fixes
# Clone missing libraries
pushd external && git clone https://android.googlesource.com/platform/external/go-cmp && popd
pushd external && git clone https://android.googlesource.com/platform/external/exfatprogs && popd
pushd external && git clone https://android.googlesource.com/platform/external/zucchini && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/base64 && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/command-fds && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/der-oid-macro && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/der-parser && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/flate2 && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/gdbstub_arch && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/kernlog && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/num-bigint && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/oid-registry && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/rusticata-macros && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/serde-xml-rs && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/x509-parser && popd
pushd external/rust/crates && git clone https://android.googlesource.com/platform/external/rust/crates/xml-rs && popd
pushd system && git clone https://android.googlesource.com/platform/system/librustutils && popd

# NNAPI is on the wrong tree
pushd packages/modules
rm -rf NeuralNetworks
git clone https://android.googlesource.com/platform/packages/modules/NeuralNetworks
cd NeuralNetworks
git checkout 0cbd76845be853d44e17247f4f07454138e4e16e
popd

# Clean up and fixes
mv build/soong/java/core-libraries/Android.bp build/soong/java/core-libraries/Android.bp.bak
mv device/google/fuchsia/bioniccompat/Android.bp device/google/fuchsia/bioniccompat/Android.bp.bak
mv external/llvm-project/pstl/build/jni/Android.mk external/llvm-project/pstl/build/jni/Android.mk.bak
pushd art && git apply ../art.patch && popd
pushd bionic/libc && git apply ../../bionic_libc.patch && popd
pushd external/conscrypt && git apply ../../external_conscrypt.patch && popd
pushd external/icu/android_icu4j && git apply ../../../external_icu_android_icu4j.patch && popd
pushd external/libxml2 && git apply ../../external_libxml2.patch && popd
# Revert https://android.googlesource.com/platform/frameworks/base/+/061b25ec6f2786662123becbe1c6d5c098922c73%5E%21/#F0
pushd frameworks/base && git apply ../../frameworks_base.patch && popd
pushd hardware/interfaces && git apply ../../hardware_interfaces.patch && popd
pushd prebuilts/tools && git apply ../../prebuilts_tools.patch && popd
pushd packages/modules/NeuralNetworks && git apply ../../../packages_modules_NeuralNetworks.patch && popd

# Build
# build/envsetup.sh cannot be run with -u
set +u
source build/envsetup.sh
lunch aosp_arm64-${TARGET}
set -u

# win_sdk build linux SDK too
#make -j$(nproc) sdk dist sdk_repo
make -j$(nproc) win_sdk dist sdk_repo
