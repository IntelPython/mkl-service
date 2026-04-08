#!/bin/bash
set -ex

read -r GLIBC_MAJOR GLIBC_MINOR <<<"$(conda list '^sysroot_linux-64$' \
    | tail -n 1 | awk '{print $2}' | grep -oP '\d+' | head -n 2 | tr '\n' ' ')"

if [ -d "build" ]; then
    rm -rf build
fi

# -wnx flags mean: --wheel --no-isolation --skip-dependency-check
${PYTHON} -m build -w -n -x

${PYTHON} -m wheel tags --remove \
    --platform-tag "manylinux_${GLIBC_MAJOR}_${GLIBC_MINOR}_x86_64" \
    dist/mkl_service*.whl

${PYTHON} -m pip install dist/mkl_service*.whl \
    --no-build-isolation \
    --no-deps \
    --only-binary :all: \
    --no-index \
    --prefix "${PREFIX}" \
    -vv

# Copy wheel package
if [[ -d "${WHEELS_OUTPUT_FOLDER}" ]]; then
    cp dist/mkl_service*.whl "${WHEELS_OUTPUT_FOLDER[@]}"
fi
