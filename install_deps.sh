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
    export HOMEBREW_NO_INSTALLED_DEPENDENTS_CHECK=1
    export HOMEBREW_NO_AUTO_UPDATE=1

    # Overwrite whatever Python binaries are shipped in our CI image.
    # see: https://github.com/orgs/Homebrew/discussions/3895
    brew install --force --overwrite python@3.10

    brew install eigen ninja pypy3 castxml llvm@16
fi
