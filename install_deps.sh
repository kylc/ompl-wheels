#!/usr/bin/env sh

build_target="${OMPL_BUILD_TARGET:-linux}"
build_arch="${OMPL_BUILD_ARCH:-x86_64}"

if [ "${build_target}" == "linux" ]; then
    yum -y install \
        eigen3 \
        ninja-build \
        llvm-devel \
        clang-devel

    ln -s /opt/python/pp310-pypy310_pp73/bin/pypy /usr/bin
fi

if [ "${build_target}" == "macos" ]; then
    brew update
    brew install eigen ninja pypy3 castxml llvm@16
fi
