# AGENTS.md — .github/

CI/CD workflows, automation, security scanning, and package distribution.

## Workflows
The conda workflows build and test the Python versions in the `python:` list of their recipe's `conda_build_config.yaml`; the other build/test workflows list theirs in the workflow file.

- **conda-package.yml** — main build/test pipeline (Linux/Windows)
- **conda-package-cf.yml** — build/test using only conda-forge channel (Linux/Windows/macOS), set up like `conda-forge/mkl-service-feedstock`: Windows uses `windows-2022` (Visual Studio 2022)
- **build-with-clang.yml** — Linux Clang compiler compatibility validation
- **build-with-standard-clang.yml** — standard Clang compiler compatibility validation
- **build_pip.yml** — validates editable build
- **pre-commit.yml** — code quality checks (flake8, etc.)
- **openssf-scorecard.yml** — security posture scanning
- **coverity.yml** — weekly Coverity Scan static analysis of the C/Cython extensions (scan.coverity.com)

## Actions
- **actions/conda-python-matrix/** — composite action that reads the `python:` list of a recipe's `conda_build_config.yaml` and outputs the build/test matrix. `action.yml` and `conda_python_matrix.py` (standard library only) refer to nothing outside the directory, so it can move unchanged to a shared repository together with `conda-build-test.yml`. The `variants` job references it as `./.github/actions/conda-python-matrix`, which resolves against the caller's checkout; after the move that line must become `$/.github/actions/conda-python-matrix`, which resolves against the repository of the workflow file itself. It is not `$/` already because actionlint 1.7.12, used by pre-commit, rejects that syntax (rhysd/actionlint#711). Run it locally with `python .github/actions/conda-python-matrix/conda_python_matrix.py conda-recipe-cf/conda_build_config.yaml`

## CI/CD policy
- Platforms are set in the caller workflows. The conda workflows read their Python versions from the `python:` list in the recipe's `conda_build_config.yaml`: the `variants` job of `conda-build-test.yml` turns it into the build/test matrix with the `.github/actions/conda-python-matrix` composite action. The other workflows keep their Python matrix in the workflow file
- Every entry of a recipe's `python:` list is a full spec on its own line, without selectors (`3.12.* *_cpython`, `3.13.* *_cp313`, `3.14.* *_cp314`, `3.14.* *_cp314t`); the `variants` job rejects bare versions, selectors, an ABI that doesn't match the version (`3.13.* *_cp314t`) and a second entry for the same build, whose artifact names would collide
- The `variants` job keeps the check names of the former static matrix: `Build (3.12)` for a version with one build, `Build (3.14, 3.14.* *_cp314t, 3.14t)` for a version with GIL and free-threaded builds. The master ruleset requires the 3.14 `Test` checks by these exact names
- Required checks: conda build + test on supported Python versions/platforms in CI
- In workflow-file matrices (`build_pip.yml`), Python 3.14 is expressed as two `include` rows carrying `python_spec` (`3.14.* *_cp314` and `3.14.* *_cp314t`); a bare `--python 3.14` has been observed to select the free-threaded ABI and must not be relied on
- Python 3.15 follows the same pattern as 3.14: two `include` rows with `python_spec` `3.15.* *_cp315` and `3.15.* *_cp315t`
- Artifact naming: `$PACKAGE_NAME $OS Python $VERSION`, where `$VERSION` is `python_tag`: the Python version, with a `t` suffix for free-threaded builds (`3.12`, `3.14`, `3.14t`)
- Channels: `conda-forge`, Intel channel
- Build jobs run `conda build --no-test`; test jobs run `conda build --test` on the built package on a fresh runner, so CI runs the test section of the recipe, as the feedstock does
- `conda-package-cf.yml` and `conda-recipe-cf/` follow `conda-forge/mkl-service-feedstock`. The feedstock's pins are kept only in `conda-recipe-cf/conda_build_config.yaml` (compiler versions, `mkl_devel`, and Python versions in its `python:` list): when the feedstock is re-rendered with new pins, update them there, and don't restate the numbers in the `AGENTS.md` files

## Security
- OpenSSF Scorecard runs automatically
- Coverity Scan runs weekly via `coverity.yml` (project `IntelPython/mkl-service` on scan.coverity.com; needs the `COVERITY_SCAN_TOKEN`/`COVERITY_SCAN_EMAIL` secrets)
- CODEOWNERS enforces review policy
- Dependabot monitors dependencies (`.github/dependabot.yml`)

## Platform specifics
- **Linux:** RTLD_GLOBAL handling for MKL library loading
- **Windows:** DLL search path configuration for venv/runtime loading

## Notes
- Workflow/job renames are breaking for downstream tooling
- Conda jobs do not cache the conda package directory: the channel downloads were faster than restoring the ~1 GB `actions/cache` entries, which were also evicted before the next run
