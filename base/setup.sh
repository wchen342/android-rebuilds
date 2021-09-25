#!/usr/bin/env bash

docker pull debian:bookworm
docker build -t android-rebuilds:base .

# Sanity check
if [[ "$(docker images -q android-rebuilds:base 2> /dev/null)" == "" ]]; then
    exit 1
fi
