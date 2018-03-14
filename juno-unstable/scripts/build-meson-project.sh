#!/bin/bash
set -e

check_permissions ()
{
    if [[ "$(id -u)" != 0 ]]; then
        echo "Error! Requires root permissions!" > /dev/stderr
        exit 1
    fi
}

upgrade_system ()
{
    apt-get update
    apt-get -y dist-upgrade
}

install_dependencies ()
{
    if [[ "$1" != "" ]]; then
        apt-get -y install "$1"
    else
        echo "Error! No dependency argument detected!"
        exit 1
    fi
}

grep_test ()
{
    grep -r --include \\meson.build test
    echo "Detected test in meson.build!"
}

meson_build_ninja ()
{
    echo "Attempting to build with meson and ninja in /tmp/build-dir..."
    cd /tmp/build-dir
    meson build --prefix=/usr
    ninja -C build
}

meson_build_ninja_test ()
{
    echo "Attempting to build with meson and ninja test /tmp/build-dir..."
    cd /tmp/build-dir
    meson build --prefix=/usr
    ninja -C build test
}

check_permissions

upgrade_system

install_dependencies "$1"

if [[ "$(grep_test)" != "" ]]; then
    meson_build_ninja_test
else
    meson_build_ninja
fi
