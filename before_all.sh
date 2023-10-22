#!/usr/bin/env bash

build_target="${OMPL_BUILD_TARGET:-linux}"
build_arch="${OMPL_BUILD_ARCH:-x86_64}"

if [ "${build_target}" == "linux" ]; then
    yum -y install \
        sudo \
        eigen3 \
        ninja-build \
        llvm-devel \
        clang-devel

    # manylinux ships with a pypy installation. Make it available on the $PATH
    # so the OMPL build process picks it up and can make use of it during the
    # Python binding generation stage.
    ln -s /opt/python/pp310-pypy310_pp73/bin/pypy /usr/bin
fi

if [ "${build_target}" == "macos" ]; then
    brew update
    brew install \
        eigen \
        ninja \
        pypy3 \
        castxml \
        llvm@16
fi
