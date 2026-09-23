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
- `MKLMemory(nbytes, alignment=64)` — aligned allocation via `mkl_malloc`; `alignment` must be a power of two
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
- **`MKLMemory` alignment:** `mkl_malloc`/`mkl_calloc` honor only power-of-two alignments and silently fall back to their own (64 bytes, measured) for anything else, so `_check_alignment` rejects non-powers of two — otherwise `.alignment` would report a value the allocation does not have. Powers of two are delivered exactly, up to at least 1 GiB.
- **`MKLMemory` pickling:** `__reduce__` must rebuild `type(self)`, not `MKLMemory`, and carry the instance `__dict__` so a subclass survives a round trip. `_mkl_memory_from_bytes` takes the class as an optional third argument — optional so that older pickles still load, and omitted for `MKLMemory` itself so that its pickles stay loadable by older versions — and must reject anything that is not a `MKLMemory` subclass, since every pickle names that function.
- **`MKLMemory` buffer export:** `__getbuffer__` hands the view to `PyBuffer_FillInfo`, which describes a flat block of unsigned bytes and answers `flags` — `format` only under `PyBUF_FORMAT`, `shape` under `PyBUF_ND`, `strides` under `PyBUF_STRIDES` — instead of filling in fields the consumer did not request. It also takes the reference on the exporter, so `__releasebuffer__` must stay a bare decrement of `exported_buffers`.
- **Claim before fill:** the `atomic_fetch_add(&self.exported_buffers, 1)` comes *before* the fill, with the claim given back in an `except` clause if the fill raises (`PyBuffer_FillInfo` is declared `except -1`). Claiming afterwards leaves a window in which a concurrent `realloc` frees the block the view was already handed, and the consumer keeps that view — every array over the allocation holds it for as long as the array lives, so the cost is a durably dangling array rather than one bad read. Reproduced with the window widened by a 5 ms sleep on 3.13t: the resize went through and ASan reported `heap-use-after-free` in `array_tobytes`; with the claim first the same resize is refused. No test can observe the ordering, so it has to be kept on purpose. It narrows rather than closes the race — a `realloc` already past its own count check can still free under a fill — which only mutual exclusion would fix.
- **Backing a NumPy array:** `np.asarray(mem)` and `np.frombuffer(mem, dtype=...)` keep a `memoryview` as `.base` and hold the export for the array's whole lifetime, so `realloc` is refused with `BufferError` until the array goes away. `np.ndarray(shape, buffer=mem)` releases the `Py_buffer` and keeps only an object reference, so only the reference check stands in the way and `refcheck=False` leaves the array dangling — `bytearray` behaves the same there, so it is NumPy's property, not this object's. The array cannot resize the allocation either: it does not own its data, which `PyArray_Resize` refuses ahead of its own reference check, so neither `ndarray.resize(..., refcheck=False)` nor a C caller invoking `PyArray_Resize` directly gets past it (both measured). What does drop the export a live array depends on is `arr.base.release()`, which is caller error the same way it is for any exporter.
- **Reading another `MKLMemory`'s block:** code that reads someone else's allocation with the GIL released must claim a buffer on it (`atomic_fetch_add(&other.exported_buffers, 1)` in a `try`/`finally`, as the copy constructor does) *before* reading its size, so that a concurrent `realloc` is refused rather than freeing the block mid-read or shrinking it under a size that was already read.

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
