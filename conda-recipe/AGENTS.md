# AGENTS.md — conda-recipe/

Conda package build recipe for conda-forge and Intel channel distribution.

## Files
- **meta.yaml** — package metadata, dependencies, build requirements
- **build.sh** — Linux/macOS build script
- **bld.bat** — Windows build script
- **conda_build_config.yaml** — compiler / stdlib pinning used by conda-build variants, and the `python:` list of versions that CI builds and tests (one job per entry)

## Build configuration
- **Channels:** `conda-forge`, Intel channel
- **Python versions in CI build matrix:** 3.10, 3.11, 3.12, 3.13, 3.14, 3.15, and free-threaded 3.14t and 3.15t (3.11+ for `conda-recipe-cf/`), from the `python:` list in each recipe's `conda_build_config.yaml`. A plain `conda build conda-recipe` therefore builds every listed version; pass `--python "3.12.* *_cpython"` to build one
- **Compilers:** pinned via `conda_build_config.yaml` (GCC/GXX on Linux, VS2022 on Windows); `conda-recipe-cf/` also pins gcc 15, clang 21 and `mkl_devel` 2026, as the feedstock's conda-forge pinning does
- **Dependencies:** `mkl` (runtime), `mkl-devel` (build), `cython >=3.1.0`

## Build outputs
- Conda package: `mkl-service-<version>-<build>.conda`
- Platform-specific artifacts from CI currently: `linux-64/`, `win-64/`

## CI usage
- Built in `.github/workflows/conda-package.yml`
- Artifacts uploaded per Python version and platform
- Test stage runs `conda build --test` on the built artifact, so the `test:` section of the recipe is what CI runs

## Platform specifics
- **Linux:** RTLD_GLOBAL handling in runtime init path
- **Windows:** MKL library path configuration
- **macOS:** built and tested only from `conda-recipe-cf/` in `conda-package-cf.yml`

## Maintenance
- Keep recipe metadata in sync with workflow matrix and package metadata
- MKL version pinning: track Intel MKL releases through recipe deps
