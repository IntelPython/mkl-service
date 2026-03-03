# AGENTS.md

Entry point for agent context in this repo.

## What this repository is
`mkl-service` provides a Python API for runtime control of Intel® oneMKL (Math Kernel Library). It exposes support functions for:
- Threading control (set/get number of threads, domain-specific threading)
- Version information (MKL version, build info)
- Memory management (peak memory usage, memory statistics)
- Conditional Numerical Reproducibility (CNR)
- Timing functions (get CPU/wall clock time)
- Miscellaneous utilities (MKL_VERBOSE control, etc.)

Originally part of Intel® Distribution for Python*, now a standalone package available via conda-forge and Intel channels.

## Key components
- **Python interface:** `mkl/__init__.py` — public API surface
- **Cython wrapper:** `mkl/_mkl_service.pyx` — wraps MKL support functions
- **C init module:** `mkl/_mklinitmodule.c` — Linux-side MKL runtime preloading / initialization
- **Helper:** `mkl/_init_helper.py` — Windows venv DLL loading helper
- **Build system:** setuptools + Cython

## Build dependencies
**Required:**
- Intel® oneMKL
- Cython
- Python 3.10+

**Conda environment:**
```bash
conda install -c conda-forge mkl-devel cython
python setup.py install
```

## CI/CD
- **Platforms in CI workflows:** Linux, Windows
- **Python versions:** 3.10, 3.11, 3.12, 3.13, 3.14
- **Workflows:** `.github/workflows/`
  - `conda-package.yml` — main conda build/test pipeline
  - `build-with-clang.yml` — Linux Clang compatibility
  - `pre-commit.yml` — code quality checks
  - `openssf-scorecard.yml` — security scanning

## Distribution
- **Conda:** `conda-forge` and `https://software.repos.intel.com/python/conda`
- **PyPI:** `python -m pip install mkl-service`

## Usage
```python
import mkl
mkl.set_num_threads(4)               # Set global thread count
mkl.domain_set_num_threads(1, "fft")  # FFT functions run sequentially
mkl.get_version_string()             # MKL version info
```

## How to work in this repo
- **API stability:** Preserve existing function signatures (widely used in ecosystem)
- **Threading:** Changes to threading control must be thread-safe
- **CNR:** Conditional Numerical Reproducibility flags require careful documentation
- **Testing:** Add tests to `mkl/tests/test_mkl_service.py`
- **Docs:** MKL support functions documented in [Intel oneMKL Developer Reference](https://www.intel.com/content/www/us/en/docs/onemkl/developer-reference-c/2025-2/support-functions.html)

## Code structure
- **Cython layer:** `_mkl_service.pyx` + `_mkl_service.pxd` (C declarations)
- **C init:** `_mklinitmodule.c` handles Linux preloading (`dlopen(..., RTLD_GLOBAL)`) for MKL runtime
- **Windows loading helper:** `_init_helper.py` handles DLL path setup in Windows venv
- **Python wrapper:** `__init__.py` imports `_py_mkl_service` (generated from `.pyx`)
- **Version:** `_version.py` (dynamic via setuptools)

## Notes
- RTLD_GLOBAL preloading is required on Linux (handled by `RTLD_for_MKL` context manager)
- MKL must be available at runtime (conda: mkl, pip: relies on system MKL)
- Threading functions affect NumPy, SciPy, and other MKL-backed libraries

## Directory map
Below directories have local `AGENTS.md` for deeper context:
- `.github/AGENTS.md` — CI/CD workflows and automation
- `mkl/AGENTS.md` — Python/Cython implementation
- `mkl/tests/AGENTS.md` — unit tests
- `conda-recipe/AGENTS.md` — conda packaging
- `examples/AGENTS.md` — usage examples

---

For broader IntelPython ecosystem context, see:
- `mkl_umath` (MKL-backed NumPy ufuncs)
- `mkl_random` (MKL-based random number generation)
- `dpnp` (Data Parallel NumPy)
