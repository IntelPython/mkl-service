# AGENTS.md — mkl/

Core Python/Cython implementation: MKL support function wrappers and runtime control.

## Structure
- `__init__.py` — public API, RTLD_GLOBAL context manager, module initialization
- `_mkl_service.pyx` — Cython wrappers for MKL support functions
- `_mkl_service.pxd` — Cython declarations (C function signatures)
- `_mklinitmodule.c` — C extension for MKL library initialization
- `_init_helper.py` — loading helpers and diagnostics
- `_version.py` — version string (dynamic via setuptools)
- `tests/` — unit tests for API functionality

## API categories
### Threading control
- `set_num_threads(n)` — global thread count
- `get_max_threads()` — max threads available
- `domain_set_num_threads(n, domain)` — per-domain threading (FFT, VML, etc.)
- `domain_get_max_threads(domain)` — domain-specific max threads

### Version information
- `get_version()` — MKL version dict
- `get_version_string()` — formatted version string

### Memory management
- `peak_mem_usage(memtype)` — peak memory usage stats
- `mem_stat()` — memory allocation statistics

### CNR (Conditional Numerical Reproducibility)
- `set_num_threads_local(n)` — thread-local thread count
- CNR mode control functions

### Timing
- `second()` — wall clock time
- `dsecnd()` — high-precision timing

## Development guardrails
- **Thread safety:** All threading functions must be thread-safe
- **API stability:** Preserve function signatures (widely used in ecosystem)
- **MKL dependency:** Assumes MKL is available at runtime (conda: mkl package)
- **RTLD_GLOBAL:** Required on Linux; handled by `RTLD_for_MKL` context manager in `__init__.py`

## Cython details
- `_mkl_service.pyx` → generates `_py_mkl_service` extension module
- `.pxd` file declares external C functions from MKL headers
- Cython build requires MKL headers (mkl-devel)

## C init module
- `_mklinitmodule.c` → `_mklinit` extension
- Ensures MKL library is loaded with correct flags before Cython extension
- Platform-specific: Windows uses `LoadLibrary`, Linux uses `dlopen`

## Notes
- Domain strings: "fft", "vml", "pardiso", "blas", etc. (see MKL docs)
- Threading changes affect all MKL-using libraries (NumPy, SciPy, etc.)
- `MKL_VERBOSE` environment variable controls MKL diagnostic output
