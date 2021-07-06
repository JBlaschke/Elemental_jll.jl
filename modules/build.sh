#!/usr/bin/env bash

set -e


install-patchelf () {

    pushd $(readlink -f $(dirname ${BASH_SOURCE[0]}))

    git submodule update --init --recursive patchelf

    pushd patchelf
    ./bootstrap.sh
    ./configure prefix=$(pwd)/..
    make
    make check
    make install

    git clean -fdx .
    popd
    popd
}



install-patchelf
