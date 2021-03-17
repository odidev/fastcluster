#!/usr/bin/env bash

set -e -x

arch=$(uname -m)

# Compile wheels
for PYBIN in /opt/python/*/bin; do
    if [[ "${PYBIN}" == *"cp27"* && $arch != "aarch64" ]] || \
       [[ "${PYBIN}" == *"cp35"* && $arch != "aarch64" ]] || \
       [[ "${PYBIN}" == *"cp36"* && $arch != "aarch64" ]] || \
       [[ "${PYBIN}" == *"cp37"* ]] || \
       [[ "${PYBIN}" == *"cp38"* ]] || \
       [[ "${PYBIN}" == *"cp39"* ]]; then
        "${PYBIN}/pip" install numpy scipy
        "${PYBIN}/pip" install -e /io/
	(cd /io && "${PYBIN}/python" setup.py test)
        "${PYBIN}/pip" wheel /io/ -w dist/
        rm -rf /io/build /io/*.egg-info
    fi
done

# Bundle external shared libraries into the wheels
for whl in dist/fastcluster*.whl; do
    auditwheel repair "$whl" -w /io/dist/
done
