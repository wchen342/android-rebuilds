#!/usr/bin/env bash
set -eu -o pipefail

pushd ../base && source ./setup.sh && popd

container_name="android-rebuilds-ndk"
VERSION='r23'

docker create --name ${container_name} --workdir /home/build/wd --entrypoint "tail" android-rebuilds:base "-f" "/dev/null"
docker start "${container_name}"

# Run build script
docker cp docker-build.sh "${container_name}":/home/build/wd/docker-build.sh
docker exec --user build "${container_name}" bash -c "/home/build/wd/docker-build.sh"

# copy output
docker cp "${container_name}":/home/build/wd/out/dist/android-ndk-0-linux-x86_64.zip android-ndk-${VERSION}-linux-x86_64.zip
docker cp "${container_name}":/home/build/wd/out/dist/android-ndk-0-windows-x86_64.zip android-ndk-${VERSION}-windows-x86_64.zip

# shutdown and remove container
if docker ps --format '{{.Names}}' | grep -w "${container_name}" &> /dev/null; then
  echo "Stopping container"
  docker stop "${container_name}"
fi
if docker ps --all --format '{{.Names}}' | grep -w "${container_name}" &> /dev/null; then
  echo "Removing container"
  docker rm "${container_name}"
fi
