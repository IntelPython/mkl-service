# AGENTS.md — .github/

CI/CD workflows, automation, security scanning, and package distribution.

## Workflows
All build/test workflows cover Python 3.10-3.15 plus free-threaded 3.14t and 3.15t, except `conda-package-cf.yml`, which takes the versions below 3.14 from the feedstock (its `python-versions` input).

- **conda-package.yml** — main build/test pipeline (Linux/Windows)
- **conda-package-cf.yml** — build/test using only conda-forge channel (Linux/Windows/macOS), set up like `conda-forge/mkl-service-feedstock`: Windows uses `windows-2022` (Visual Studio 2022)
- **build-with-clang.yml** — Linux Clang compiler compatibility validation
- **build-with-standard-clang.yml** — standard Clang compiler compatibility validation
- **build_pip.yml** — validates editable build
- **pre-commit.yml** — code quality checks (flake8, etc.)
- **openssf-scorecard.yml** — security posture scanning
- **coverity.yml** — weekly Coverity Scan static analysis of the C/Cython extensions (scan.coverity.com)

## CI/CD policy
- Keep build matrix (Python versions, platforms) in workflow files only
- Required checks: conda build + test on supported Python versions/platforms in CI
- Python 3.14 is expressed as two `include` rows carrying `python_spec` (`3.14.* *_cp314` and `3.14.* *_cp314t`); a bare `--python 3.14` has been observed to select the free-threaded ABI and must not be relied on
- Python 3.15 follows the same pattern as 3.14: two `include` rows with `python_spec` `3.15.* *_cp315` and `3.15.* *_cp315t`
- `include` rows create new matrix combinations and inherit nothing, so `experimental` must be repeated wherever the job reads them
- Artifact naming: `$PACKAGE_NAME $OS Python $VERSION`, where `$VERSION` is `python_tag` (`3.14`, `3.14t`, `3.15`, or `3.15t`) when set, otherwise `python`
- Channels: `conda-forge`, Intel channel
- Build jobs run `conda build --no-test`; test jobs run `conda build --test` on the built package on a fresh runner, so CI runs the test section of the recipe, as the feedstock does
- `conda-package-cf.yml` and `conda-recipe-cf/` follow `conda-forge/mkl-service-feedstock`. The feedstock's pins are kept only in `conda-recipe-cf/conda_build_config.yaml` (compiler versions, `mkl_devel`) and in the `python-versions` input of `conda-package-cf.yml` (Python versions below 3.14): when the feedstock is re-rendered with new pins, update them there, and don't restate the numbers in the `AGENTS.md` files

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
