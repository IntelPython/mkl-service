# AGENTS.md — .github/

CI/CD workflows, automation, security scanning, and package distribution.

## Workflows
- **conda-package.yml** — main build/test pipeline (Linux/Windows, Python 3.10-3.14)
- **conda-package-cf.yml** — build/test using only conda-forge channel (Linux/Windows, Python 3.10-3.14)
- **build-with-clang.yml** — Linux Clang compiler compatibility validation
- **build-with-standard-clang.yml** — standard Clang compiler compatibility validation
- **build_pip.yml** — validates editable build
- **pre-commit.yml** — code quality checks (flake8, etc.)
- **openssf-scorecard.yml** — security posture scanning

## CI/CD policy
- Keep build matrix (Python versions, platforms) in workflow files only
- Required checks: conda build + test on supported Python versions/platforms in CI
- Artifact naming: `$PACKAGE_NAME $OS Python $VERSION`
- Channels: `conda-forge`, `conda-forge/label/python_rc`, Intel channel

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
- Python 3.14 uses `conda-forge/label/python_rc` for pre-release support
