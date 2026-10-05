# AGENTS.md — mkl/tests/

Unit tests for MKL runtime control API.

## Test files
- **test_mkl_service.py** — API functionality, threading control, version info
- **test_mkl_memory.py** — `MKLMemory` allocation, buffer protocol, `realloc`, concurrency

## Test coverage
- Threading: `set_num_threads`, `get_max_threads`, domain-specific threading
- Version: `get_version`, `get_version_string` format validation
- Memory: `peak_mem_usage`, `mem_stat` (if supported by MKL build)
- CNR: Conditional Numerical Reproducibility flags
- Edge cases currently covered: thread-local settings and API round-trips
- `MKLMemory` construction: all three forms, argument count/type errors, non-positive sizes, `num * elem_size` overflow, alignment bounds and types, non-power-of-two alignments refused in all three forms, unexpected keywords, `mkl_calloc` actually zeroing, and the copy form copying the content into an allocation of its own
- `MKLMemory` buffers: two simultaneous views alias one block and each counts as an export of its own, the exported view's own fields (exporter, format, itemsize, ndim, shape, strides, suboffsets, writability, contiguity), no reference left behind per export/release cycle, `tobytes`, pickle round-trip, actual address alignment — every accepted alignment is checked against the delivered pointer, so a value MKL would ignore cannot pass unnoticed
- `MKLMemory` pickling: a subclass comes back as itself with its attributes, and the reconstructor refuses a class that is not a `MKLMemory` subclass
- `MKLMemory.realloc`: grow/shrink with data preservation, alignment preserved across a resize, refusal while a buffer is exported or the object looks shared, `refcheck=False`, non-positive sizes, and every refusal being a no-op — pointer, size, alignment and content unchanged, whatever the reason
- `MKLMemory` copy construction: the source's buffer is claimed for the duration, which is observed by resizing the source from an alignment object's `__int__` (called inside the copy), and released on both the success and the failure path
- `MKLMemory` concurrency: concurrent reads, two threads resizing at once (the CAS latch's losing side is only reachable on a free-threaded build — `realloc` holds the GIL otherwise), and readers hammering the object across resizes taken while they are parked, asserting the resizes were not quietly refused

## Running tests
```bash
pytest mkl/tests/
```

## CI integration
- Tests run in `conda-package.yml` workflow
- Separate test jobs per Python version and CI platform
- CI coverage: Linux + Windows

## Adding tests
- New API functions → add to `test_mkl_service.py` with validation
- `MKLMemory` behavior → add to `test_mkl_memory.py`
- Threading behavior → test thread count changes take effect
- Use `mkl.get_version()` to check MKL availability before tests
- Concurrency tests must be checked for vacuity by counting outcomes, not by reading the code: a `realloc` refused by every thread satisfies loose assertions without ever reaching `mkl_realloc`. The predecessor of `test_concurrent_reads_across_reallocs` swallowed `(ValueError, BufferError)` around a `refcheck=True` resize and completed 0 of 200 resizes on every build where it ran — an object reachable from both the test frame and a closure cell has a reference count the check calls shared — and it still passed with `__releasebuffer__` gutted to a no-op
- Prefer a deterministic test over threads where the window can be entered on purpose: a callback from an argument the implementation converts inside the window (see `_AlignmentProbe`) tests the same guard without depending on the scheduler
- Tests must pass on free-threaded builds, and a test must not resize an allocation that other threads can reach — not on any version. `refcheck` is not a guard against other threads, and `tobytes` re-reads the pointer with nothing claimed, so a reallocer that retries until it slips between two reads is a use-after-free, not a test (ASan confirms it on 3.13t *and* 3.14t, in `tobytes`; a GIL build completes 200/200 resizes clean, which is why this looks fine locally). Park the readers on a `threading.Barrier` instead, resize while they are parked, and assert the resizes happened
- `numpy` is not a dependency of this package and CI does not install it for the test job, so any test that needs it must call `pytest.importorskip("numpy")` in the body — not import it at module level, which would break collection. Note that `pytest.importorskip` skips on `ModuleNotFoundError` only, so a probe that blocks the module by raising plain `ImportError` reports failures rather than skips and says nothing about the real behavior
- Content comparison alone does not prove a copy: a fresh allocation can be handed recycled heap memory that already holds the pattern, so `assert copy.tobytes() == source.tobytes()` has been observed to pass with the `memcpy` removed. Write the pattern a byte at a time so no freed `bytes` copy of it is left on the heap, and assert `_pointer` differs
