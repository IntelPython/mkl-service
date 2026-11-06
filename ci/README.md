# How Intel CI tests mkl-service

`.github/workflows/intel-ci.yml` builds mkl-service's conda packages and wheels in GitHub Actions and tests each one. It needs this directory, the recipe, and `pyproject.toml`.

| File | Role |
|---|---|
| `../conda-recipe/` | The conda recipe. `conda_build_config.yaml` lists the Python versions. The recipe builds on Linux, Windows and Intel macOS unless a platform-only skip in `meta.yaml`, such as `skip: true  # [win]`, rules one out. |
| `../pyproject.toml` | What the wheels are built from. Its Python classifiers list the wheels' Python versions, and its Operating System classifiers their platforms. `[tool.cibuildwheel]` holds the wheel build settings, and `[tool.gh-ci]` holds the run-time requirements the wheels need on top of `[project]`'s, which the conda packages get from the recipe: `pin-compatible` requires at least the `mkl-devel` version the build used, below its next major. |
| `../.github/workflows/intel-ci.yml` | One job reads both matrices. One job per platform and Python version builds and uploads `mkl-service <Platform> Python <version>`, and one builds `mkl-service <Platform> Wheels Python <version>`. Then one job per package tests it. |
| `matrix.py` | Reads the platforms and Python versions from the recipe, or with `--system wheel` from `pyproject.toml`. A pull request gets the oldest and the newest regular versions. |
| `build.py` | Builds one Python version: with conda-build, which runs the recipe's own tests, or with `--system wheel` with cibuildwheel, in a manylinux container on Linux. The ELF files in a wheel keep only their `$ORIGIN` RPATH and RUNPATH entries. |
| `hooks.py` | The workflow's test jobs: installs one package into a clean environment with the requirements in `config.yml`, and runs `test.py`. A conda package's environment comes from conda-forge; a wheel goes into a venv made from conda-forge's Python, with everything else from PyPI. |
| `config.yml` | Names the workflow that builds the packages, its artifact names, and what the tests need. |
| `test.py` | Runs the installed `mkl` module's test suite with pytest. |

The scripts need nothing beyond the Python standard library and the tools each one's docstring names. macOS packages build and test on Intel runners, as MKL has no Apple silicon build.

**A pull request into `master`.** Actions builds the oldest and the newest regular Python versions on Linux, Windows and macOS, as a conda package and, where `pyproject.toml` declares the platform, as a wheel, and tests each package.

**A push to `master` or a tag.** Actions builds and tests every declared version.

To support another Python, add it to `conda-recipe/conda_build_config.yaml` for the conda packages and as a classifier in `pyproject.toml` for the wheels; nothing else lists versions. Try it locally from a conda base environment with conda-build, or with cibuildwheel for wheels:

```bash
python ci/matrix.py                           # every platform and Python version
python ci/matrix.py --event pull_request      # what a pull request builds
python ci/build.py --python VERSION --output /tmp/out     # VERSION: one matrix.py lists
python ci/hooks.py --python VERSION --artifacts /tmp/out --work /tmp/hooks
python ci/build.py --system wheel --python VERSION --output /tmp/wheels
python ci/hooks.py --kind wheel --python VERSION --artifacts /tmp/wheels --work /tmp/wheel-hooks
```
