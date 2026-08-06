# AGENTS.md — .github/

CI/CD workflows, automation, security scanning, and package distribution.

## Workflows
All build/test workflows cover Python 3.10-3.14 plus free-threaded 3.14t.

- **conda-package.yml** — main build/test pipeline (Linux/Windows)
- **conda-package-cf.yml** — build/test using only conda-forge channel (Linux/Windows)
- **build-with-clang.yml** — Linux Clang compiler compatibility validation
- **build-with-standard-clang.yml** — standard Clang compiler compatibility validation
- **build_pip.yml** — validates editable build
- **pre-commit.yml** — code quality checks (flake8, etc.)
- **openssf-scorecard.yml** — security posture scanning

## CI/CD policy
- Keep build matrix (Python versions, platforms) in workflow files only
- Required checks: conda build + test on supported Python versions/platforms in CI
- Python 3.14 is expressed as two `include` rows carrying `python_spec` (`3.14.* *_cp314` and `3.14.* *_cp314t`); a bare `--python 3.14` has been observed to select the free-threaded ABI and must not be relied on
- `include` rows create new matrix combinations and inherit nothing, so `experimental` must be repeated wherever the job reads them
- Artifact naming: `$PACKAGE_NAME $OS Python $VERSION`, where `$VERSION` is `python_tag` (`3.14` or `3.14t`) when set, otherwise `python`
- Channels: `conda-forge`, Intel channel

## Security
- OpenSSF Scorecard runs automatically
- CODEOWNERS enforces review policy
- Dependabot monitors dependencies (`.github/dependabot.yml`)

## Platform specifics
- **Linux:** RTLD_GLOBAL handling for MKL library loading
- **Windows:** DLL search path configuration for venv/runtime loading

## Notes
- Workflow/job renames are breaking for downstream tooling
- Cache key includes `meta.yaml` hash for conda packages
