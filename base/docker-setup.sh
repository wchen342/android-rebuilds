#!/usr/bin/env bash
set -eux -o pipefail

# Update repositories
# Enable contrib
sed -i -e 's/ main/ main contrib/g' /etc/apt/sources.list
dpkg --add-architecture i386
apt update
apt upgrade -y

# Install repo
apt install -y repo python-is-python3 openssh-client

# Taken from Ubuntu 18.04
# https://source.android.com/setup/build/initializing#installing-required-packages-ubuntu-1804
apt -y install git-core gnupg flex bison build-essential zip \
    curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 libncurses5 \
    lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z1-dev \
    libgl1-mesa-dev libxml2-utils xsltproc unzip fontconfig tofrodos

# Set up user and working directory
useradd build -m -s /bin/bash
mkdir -p /home/build/wd
chown -R build:build /home/build

# Set up git
su -c - build 'git config --global user.email "you@example.com" && git config --global user.name "Your Name" && git config --global color.ui true'
