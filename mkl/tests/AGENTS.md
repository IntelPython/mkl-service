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
- `MKLMemory` construction: all three forms, argument count/type errors, non-positive sizes, `num * elem_size` overflow, alignment bounds and types, unexpected keywords
- `MKLMemory` buffers: buffer protocol, `tobytes`, pickle round-trip, actual address alignment
- `MKLMemory.realloc`: grow/shrink with data preservation, alignment preserved across a resize, refusal while a buffer is exported or the object looks shared, `refcheck=False`, non-positive sizes
- `MKLMemory` concurrency: concurrent reads, overlapping `realloc` calls, readers racing a `realloc`

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
- Concurrency tests must be checked for vacuity: a `realloc` refused by every thread satisfies loose assertions without ever reaching `mkl_realloc`
- Tests must pass on free-threaded builds, where `realloc`'s reference-count check does not guard against other threads before 3.14: a test that races a resize against live readers must be gated on `REALLOC_RACE_IS_CONTAINED`, or it reads freed memory there instead of testing a guard
