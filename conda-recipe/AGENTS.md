# AGENTS.md — conda-recipe/

The conda recipe, built against `conda-forge` only and set up like `conda-forge/mkl-service-feedstock`.

## Files
- **meta.yaml** — package metadata, dependencies, build requirements
- **build.sh** — Linux/macOS build script
- **bld.bat** — Windows build script
- **conda_build_config.yaml** — the feedstock's compiler, stdlib and `mkl_devel` pins, and the `python:` list CI builds

## CI usage
- Built on Linux, Windows and macOS in `.github/workflows/conda-package-cf.yml` and `.github/workflows/intel-ci.yml`
- Test stage runs `conda build --test` on the built artifact, so the `test:` section of the recipe is what CI runs
- Wheels don't come from this recipe: `intel-ci.yml` builds them from `pyproject.toml` with `ci/build.py`

## Platform specifics
- **Linux:** RTLD_GLOBAL handling in runtime init path
- **Windows:** MKL library path configuration
