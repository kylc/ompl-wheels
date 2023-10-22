#!/usr/bin/env bash

set -eux

# Dependency versions.
castxml_version="0.6.2"
boost_version="1.83.0"

# Collect some information about the build target.
build_target="${OMPL_BUILD_TARGET:-linux}"
build_arch="${OMPL_BUILD_ARCH:-x86_64}"
python_version=$(python3 -c 'import sys; v=sys.version_info; print(f"{v.major}.{v.minor}")')
python_include_path=$(python3 -c "from sysconfig import get_paths as gp; print(gp()['include'])")

build_boost() {
    b2_args="$1"

    curl -L "https://boostorg.jfrog.io/artifactory/main/release/${boost_version}/source/boost_${boost_version//./_}.tar.bz2" | tar xj
    echo "using python : ${python_version} : : ${python_include_path} ;" > "$HOME/user-config.jam"
    pushd "boost_${boost_version//./_}"
    ./bootstrap.sh

    sudo ./b2 "$b2_args" \
        --with-serialization \
        --with-filesystem \
        --with-system \
        --with-program_options \
        --with-python \
        install

    popd
}

build_castxml() {
    curl -L "https://github.com/CastXML/CastXML/archive/refs/tags/v${castxml_version}.tar.gz" | tar xz

    pushd "CastXML-${castxml_version}"
    mkdir -p build && cd build
    cmake -GNinja -DCMAKE_BUILD_TYPE=Release ..
    cmake --build .
    ninja install
    popd
}


# Work inside a temporary directory.
cd "$(mktemp -d -t 'ompl-wheels.XXX')"

# Need latest for this PR with Mac fixes:
# https://github.com/ompl/pyplusplus/pull/1
pip install git+https://github.com/ompl/pyplusplus
pip install cmake pygccxml numpy build ninja

if [ "${build_target}" == "linux" ]; then
    # Install CastXML dependency.
    build_castxml

    # Install the latest Boost, because it has to be linked to the exact version of
    # Python for which we are building the wheel.
    build_boost ""
fi

if [ "${build_target}" == "macos" ]; then
    # For Python development headers
    brew install --overwrite "python@${python_version}"

    if [ "${build_arch}" == "x86_64" ]; then
        build_boost "architecture=x86 address-model=64 cxxflags='-arch x86_64'"
    elif [ "${build_arch}" == "arm64" ]; then
        build_boost "architecture=arm address-model=64 cxxflags='-arch arm64'"
    fi
fi
