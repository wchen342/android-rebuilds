#!/usr/bin/env bash
set -eu -o pipefail

pushd ../base && source ./setup.sh && popd

container_name="android-rebuilds-sdk"

docker create --name ${container_name} --workdir /home/build/wd --entrypoint "tail" android-rebuilds:base "-f" "/dev/null"
docker start "${container_name}"

# Run build script
docker cp docker-build.sh "${container_name}":/home/build/wd/docker-build.sh
docker cp art.patch "${container_name}":/home/build/wd/art.patch
docker cp bionic_libc.patch "${container_name}":/home/build/wd/bionic_libc.patch
docker cp external_conscrypt.patch "${container_name}":/home/build/wd/external_conscrypt.patch
docker cp external_icu_android_icu4j.patch "${container_name}":/home/build/wd/external_icu_android_icu4j.patch
docker cp external_libxml2.patch "${container_name}":/home/build/wd/external_libxml2.patch
docker cp frameworks_base.patch "${container_name}":/home/build/wd/frameworks_base.patch
docker cp hardware_interfaces.patch "${container_name}":/home/build/wd/hardware_interfaces.patch
docker cp prebuilts_tools.patch "${container_name}":/home/build/wd/prebuilts_tools.patch
docker cp packages_modules_NeuralNetworks.patch "${container_name}":/home/build/wd/packages_modules_NeuralNetworks.patch
docker exec --user build "${container_name}" bash -c "/home/build/wd/docker-build.sh"

# copy output

# shutdown and remove container
# if docker ps --format '{{.Names}}' | grep -w "${container_name}" &> /dev/null; then
#   echo "Stopping container"
#   docker stop "${container_name}"
# fi
# if docker ps --all --format '{{.Names}}' | grep -w "${container_name}" &> /dev/null; then
#   echo "Removing container"
#   docker rm "${container_name}"
# fi
