# AGENTS.md — conda-recipe/

Conda package build recipe for conda-forge and Intel channel distribution.

## Files
- **meta.yaml** — package metadata, dependencies, build requirements
- **build.sh** — Linux/macOS build script
- **bld.bat** — Windows build script
- **conda_build_config.yaml** — build matrix (Python versions, platforms)

## Build configuration
- **Channels:** `conda-forge`, `conda-forge/label/python_rc`, Intel channel
- **Python versions:** 3.10, 3.11, 3.12, 3.13, 3.14
- **Compilers:** system default (GCC/Clang/MSVC)
- **Dependencies:** mkl (runtime), mkl-devel (build), cython

## Build outputs
- Conda package: `mkl-service-<version>-<build>.conda`
- Platform-specific: `linux-64/`, `win-64/`, `osx-64/`, `osx-arm64/`

## CI usage
- Built in `.github/workflows/conda-package.yml`
- Artifacts uploaded per Python version and platform
- Test stage uses built artifacts from channel

## Platform specifics
- **Linux:** RTLD_GLOBAL handling in build script
- **Windows:** MKL library path configuration
- **macOS:** Universal2 builds for Intel + ARM (if supported)

## Maintenance
- Keep `conda_build_config.yaml` in sync with CI matrix
- MKL version pin: track Intel MKL releases
- Python 3.14: requires `conda-forge/label/python_rc` until stable
