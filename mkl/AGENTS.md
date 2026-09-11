# AGENTS.md — mkl/

Core Python/Cython implementation: MKL support function wrappers and runtime control.

## Structure
- `__init__.py` — public API, RTLD_GLOBAL context manager, module initialization
- `_py_mkl_service.pyx` — Cython wrappers for MKL support functions
- `_mkl_memory.pyx` — `MKLMemory`, a buffer-protocol object over MKL's allocator
- `_mkl_service.pxd` — Cython declarations (C function signatures)
- `_mklinitmodule.c` — C extension for Linux-side MKL runtime preloading/init
- `_init_helper.py` — Windows loading helper (DLL path setup in venv)
- `_version.py` — version string
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

### Memory allocation
- `MKLMemory(nbytes, alignment=64)` — aligned allocation via `mkl_malloc`
- `MKLMemory(num, elem_size, alignment=64)` — zeroed allocation via `mkl_calloc`
- `MKLMemory(other, alignment=other.alignment)` — copy of another allocation
- `realloc(new_nbytes, refcheck=True)` — resize in place via `mkl_realloc`
- `nbytes` / `__len__`, `alignment`, `tobytes()`, buffer protocol, pickling

### CNR (Conditional Numerical Reproducibility)
- `set_num_threads_local(n)` — thread-local thread count
- CNR mode control functions

### Timing
- `second()` — wall clock time
- `dsecnd()` — high-precision timing

## Development guardrails
- **Thread safety:** All threading functions must be thread-safe
- **API stability:** Preserve function signatures (widely used in ecosystem)
- **MKL dependency:** Assumes MKL is available at runtime (conda: mkl package). Do **not** list `mkl` in `pyproject.toml` `[project].dependencies` — its PyPI wheel lacks `.dist-info`, which breaks `pip check`; on conda-forge there is no pip-visible `mkl` distribution.
- **RTLD_GLOBAL preload path:** Linux preload is handled in `_mklinitmodule.c`; Windows DLL setup is in `_init_helper.py`
- **`MKLMemory` mutation:** `realloc` moves the underlying block, so it must refuse while a buffer is exported, while another thread is resizing, or (unless `refcheck=False`) while the object looks referenced elsewhere. The GIL must not be released across those checks and the pointer store, mirroring NumPy's `PyArray_Resize`. The reference-count check stays NumPy's: `PyUnstable_Object_IsUniquelyReferenced` from 3.14, `Py_REFCNT > 2` before it, keyed on `PY_VERSION_HEX` and not on `Py_GIL_DISABLED`. It is a check against dangling references, not against other threads — on a free-threaded build before 3.14 it cannot be either, and resizing an allocation another thread can reach is the caller's responsibility, as it is for `numpy.ndarray.resize`.

## Cython details
- `_py_mkl_service.pyx` → generates `_py_mkl_service` extension module
- `_mkl_memory.pyx` → generates `_mkl_memory` extension module
- `.pxd` file declares external C functions from MKL headers
- Cython build requires MKL headers (`mkl-devel`)
- `_mkl_memory.pyx` uses C11 atomics (`<stdatomic.h>`); `meson.build` scopes MSVC's `/experimental:c11atomics` to that one target

## C init module
- `_mklinitmodule.c` → `_mklinit` extension
- Ensures MKL runtime is initialized with correct flags before Cython extension
- Platform-specific behavior in current code:
  - Linux: `dlopen(..., RTLD_GLOBAL)` preload path (when applicable)
  - Windows: runtime DLL loading support is handled by `_init_helper.py`

## Notes
- Domain strings: "fft", "vml", "pardiso", "blas", etc. (see MKL docs)
- Threading changes affect all MKL-using libraries (NumPy, SciPy, etc.)
- `MKL_VERBOSE` environment variable controls MKL diagnostic output
