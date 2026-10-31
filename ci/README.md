# How Intel Python CI tests mkl-service

Intel Python CI (gh-ci) builds and tests mkl-service's conda packages and wheels in GitHub Actions. Intel's Jenkins then tests each package again on Intel machines and scans it, and on a release tag publishes the packages it tested as the tag's GitHub Release. Everything it needs from this repository is in this directory, one workflow, the recipe, and `pyproject.toml`.

| File | Role |
|---|---|
| `../conda-recipe-cf/` | The conda recipe. `conda_build_config.yaml` lists the Python versions. The recipe builds on Linux, Windows and Intel macOS unless a platform-only skip in `meta.yaml`, such as `skip: true  # [win]`, rules one out. |
| `../pyproject.toml` | What the wheels are built from. Its Python classifiers list the wheels' Python versions, and its Operating System classifiers their platforms. `[tool.cibuildwheel]` holds the wheel build settings, and `[tool.gh-ci]` holds the run-time requirements the wheels need on top of `[project]`'s, which the conda packages get from the recipe. |
| `../.github/workflows/intel-ci.yml` | One job reads both matrices. One job per platform and Python version builds and uploads `mkl-service <Platform> Python <version>`, and one builds `mkl-service <Platform> Wheels Python <version>`. Then one job per package tests it. |
| `matrix.py` | Reads the platforms and Python versions from the recipe, or with `--system wheel` from `pyproject.toml`. A pull request gets the oldest and the newest regular versions. |
| `build.py` | Builds one Python version: with conda-build, which runs the recipe's own tests, or with `--system wheel` with cibuildwheel, in a manylinux container on Linux. |
| `hooks.py` | The workflow's test jobs: installs one package into a clean environment with the requirements in `config.yml`, and runs `test.py` the way Jenkins does. A conda package's environment comes from conda-forge; a wheel's has only Python from conda-forge and everything else from PyPI. |
| `config.yml` | Tells gh-ci which workflow builds the packages, what its artifacts are called, and what the tests need. |
| `test.py` | Runs the installed `mkl` module's test suite with pytest, in Actions and again in Jenkins. |

The scripts need only the Python standard library and are the same in every repository gh-ci tests, except that `matrix.py` here looks for `conda-recipe-cf/` first. Scanning is not the repository's to define: Jenkins runs its own scans. macOS packages are built and tested in Actions only, on Intel runners as MKL has no Apple silicon build; Jenkins neither tests, scans nor releases them.

**A pull request into `master`.** Actions builds the oldest and the newest regular Python versions on Linux, Windows and macOS, as a conda package and, where `pyproject.toml` declares the platform, as a wheel, and tests each package. Jenkins notices the pull request within 3 minutes, waits for that whole run, and then tests and scans every package at once. Each cell posts its own status on the pull request, and `intel-ci/pr` sums them up.

**A release tag.** Actions builds every declared version, and Jenkins tests and scans all of them before it publishes the release.

To support another Python, add it to `conda-recipe-cf/conda_build_config.yaml` for the conda packages and as a classifier in `pyproject.toml` for the wheels; nothing else lists versions. Try it locally from a conda base environment with conda-build, or with cibuildwheel for wheels:

```bash
python ci/matrix.py                           # every platform and Python version
python ci/matrix.py --event pull_request      # what a pull request builds
python ci/build.py --python VERSION --output /tmp/out     # VERSION: one matrix.py lists
python ci/hooks.py --python VERSION --artifacts /tmp/out --work /tmp/hooks
python ci/build.py --system wheel --python VERSION --output /tmp/wheels
python ci/hooks.py --kind wheel --python VERSION --artifacts /tmp/wheels --work /tmp/wheel-hooks
```
