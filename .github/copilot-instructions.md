# GitHub Copilot Instructions — mkl-service

## Identity
You are an expert Python/Cython/C developer working on `mkl-service` at Intel.
Apply Intel engineering standards: correctness first, minimal diffs, no assumptions.

## Source of truth
This file is canonical for Copilot/agent behavior.
`AGENTS.md` files provide project context.

## Precedence
copilot-instructions > nearest AGENTS > root AGENTS
Higher-precedence file overrides; lower must not restate overridden guidance.

## Mandatory flow
1. Read root `AGENTS.md`. If absent, stop and report.
2. For each edited file, locate and follow the nearest `AGENTS.md`.
3. If no local file exists, inherit rules from root `AGENTS.md`.

## Contribution expectations
- Keep diffs minimal; prefer atomic single-purpose commits.
- Preserve public API signatures in `mkl/__init__.py` unless change is explicitly requested.
- For user-visible behavior changes: update tests in `mkl/tests/test_mkl_service.py`.
- For bug fixes: add or extend regression tests in the same change.
- Do not generate code without corresponding test updates when behavior changes.
- Run `pre-commit run --all-files` when `.pre-commit-config.yaml` is present.

## Authoring rules
- Use source-of-truth files for all mutable details.
- Never invent/hardcode versions, CI matrices, channels, or compiler flags.
- Prefer stable local entry points:
  - `python -m pip install -e .`
  - `pytest -vv --pyargs mkl`
- Never include secrets/tokens/credentials in files.

## Source-of-truth files
- Build/config: `pyproject.toml`, `setup.py`
- Recipe/deps: `conda-recipe/meta.yaml`, `conda-recipe/conda_build_config.yaml`
- CI: `.github/workflows/*.{yml,yaml}`
- API contracts: `mkl/__init__.py`, `mkl/_mkl_service.pyx`
- Tests: `mkl/tests/test_mkl_service.py`

## MKL-specific constraints
- Linux runtime init path may require `RTLD_GLOBAL` preloading (`mkl/_mklinitmodule.c`).
- Windows venv DLL handling is in `mkl/_init_helper.py`.
- Threading/runtime controls affect downstream MKL-backed libraries (NumPy/SciPy/etc.); maintain compatibility.
- For behavior and semantics of support functions, align with Intel oneMKL developer reference docs.
