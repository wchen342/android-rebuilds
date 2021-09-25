#!/usr/bin/env bash

# Remove old image if exists
if [[ "$(docker images -q android-rebuilds:base 2> /dev/null)" != "" ]]; then
    docker image rm android-rebuilds:base
fi

docker pull debian:bookworm
docker build -t android-rebuilds:base .

# Sanity check
if [[ "$(docker images -q android-rebuilds:base 2> /dev/null)" == "" ]]; then
    exit 1
fi
