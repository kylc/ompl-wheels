FROM quay.io/pypa/manylinux_2_28_x86_64 AS stage1
MAINTAINER Kyle Cesare <kcesare@gmail.com>

WORKDIR /work

RUN yum -y install \
        eigen3 \
        llvm-devel \
        clang-devel \
        ninja-build \
        \
    && yum -y clean all \
    && rm -rf /var/cache

# Put the built-in PyPy in a place that OMPL will recognize it.
RUN ln -s /opt/python/pp310-pypy310_pp73/bin/pypy /usr/bin

# Install CastXML dependency.
RUN git clone --depth 1 https://github.com/CastXML/CastXML /work/CastXML

WORKDIR /work/CastXML
RUN mkdir build \
    && cd build \
    && cmake -GNinja -DCMAKE_BUILD_TYPE=Release .. \
    && cmake --build . \
    && ninja install

ARG PYTHON_VERSION="3.10"

# Install the latest Boost (Boost.Python in the repos is too old and links to
# Python 3.6, causing problems).
WORKDIR /work/boost
RUN curl -L https://boostorg.jfrog.io/artifactory/main/release/1.82.0/source/boost_1_82_0.tar.bz2 | tar xj \
    && echo "using python : ${PYTHON_VERSION} ;" > /root/user-config.jam \
    && cd boost_1_82_0 \
    && ./bootstrap.sh \
    && ./b2 install

# Finally build OMPL!
COPY ompl /work/ompl

WORKDIR /work/ompl
COPY patches patches
COPY setup.py .
RUN patch -p1 -i patches/*.patch
RUN python${PYTHON_VERSION} -m pip install cmake pyplusplus pygccxml numpy build ninja
RUN python${PYTHON_VERSION} -m build --no-isolation --wheel
RUN auditwheel repair dist/*.whl

FROM scratch AS export-stage
COPY --from=stage1 /work/ompl/wheelhouse/* .
