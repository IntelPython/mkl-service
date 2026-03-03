# AGENTS.md — conda-recipe/

Conda package build recipe for conda-forge and Intel channel distribution.

## Files
- **meta.yaml** — package metadata, dependencies, build requirements
- **build.sh** — Linux/macOS build script
- **bld.bat** — Windows build script
- **conda_build_config.yaml** — compiler / stdlib pinning used by conda-build variants

## Build configuration
- **Channels:** `conda-forge`, `conda-forge/label/python_rc`, Intel channel
- **Python versions in CI build matrix:** 3.10, 3.11, 3.12, 3.13, 3.14
- **Compilers:** pinned via `conda_build_config.yaml` (GCC/GXX on Linux, VS2022 on Windows)
- **Dependencies:** `mkl` (runtime), `mkl-devel` (build), `cython`

## Build outputs
- Conda package: `mkl-service-<version>-<build>.conda`
- Platform-specific artifacts from CI currently: `linux-64/`, `win-64/`

## CI usage
- Built in `.github/workflows/conda-package.yml`
- Artifacts uploaded per Python version and platform
- Test stage uses built artifacts from a temporary local channel

## Platform specifics
- **Linux:** RTLD_GLOBAL handling in runtime init path
- **Windows:** MKL library path configuration
- **macOS:** recipe scripts exist, but current GitHub Actions matrix does not build/test macOS

## Maintenance
- Keep recipe metadata in sync with workflow matrix and package metadata
- MKL version pinning: track Intel MKL releases through recipe deps
- Python 3.14 in CI uses `conda-forge/label/python_rc` while pre-release
