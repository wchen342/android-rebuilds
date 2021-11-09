#!/usr/bin/env bash
set -eu -o pipefail

# Must be run in sdk folder
# Note: you need more than 16GB memory excluding swap, or build will fail.
pushd ../base && source ./setup.sh && popd

container_name="android-rebuilds-sdk"
VERSION='12.0.0_r13'

docker create --name ${container_name} --workdir /home/build/wd --entrypoint "tail" android-rebuilds:base "-f" "/dev/null"
docker start "${container_name}"

# Run build script
docker cp development.patch "${container_name}":/home/build/wd/development.patch
docker cp docker-build.sh "${container_name}":/home/build/wd/docker-build.sh
docker exec --user build "${container_name}" bash -c "/home/build/wd/docker-build.sh"

# copy output
docker cp "${container_name}":/home/build/wd/out/dist/android-sdk_user-${VERSION}_linux-x86.zip android-sdk_user-${VERSION}_linux-x86.zip
docker cp "${container_name}":/home/build/wd/out/dist/android-sdk_user-${VERSION}_windows.zip android-sdk_user-${VERSION}_windows.zip
docker cp "${container_name}":/home/build/wd/out/dist/android-sdk_eng-${VERSION}_linux-x86.zip android-sdk_eng-${VERSION}_linux-x86.zip
docker cp "${container_name}":/home/build/wd/out/dist/android-sdk_eng-${VERSION}_windows.zip android-sdk_eng-${VERSION}_windows.zip

# shutdown and remove container
if docker ps --format '{{.Names}}' | grep -w "${container_name}" &> /dev/null; then
  echo "Stopping container"
  docker stop "${container_name}"
fi
if docker ps --all --format '{{.Names}}' | grep -w "${container_name}" &> /dev/null; then
  echo "Removing container"
  docker rm "${container_name}"
fi
