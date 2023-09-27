#!/usr/bin/env sh

export DOCKER_BUILDKIT=1

declare -a PYVERS=('3.8' '3.9' '3.10' '3.11' '3.12')
for PYVER in "${PYVERS[@]}"; do
    echo "Building $PYVER"
    docker build . --file Dockerfile --build-arg PYTHON_VERSION="$PYVER" --output out
done
