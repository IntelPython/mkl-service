# AGENTS.md — mkl/tests/

Unit tests for MKL runtime control API.

## Test files
- **test_mkl_service.py** — API functionality, threading control, version info

## Test coverage
- Threading: `set_num_threads`, `get_max_threads`, domain-specific threading
- Version: `get_version`, `get_version_string` format validation
- Memory: `peak_mem_usage`, `mem_stat` (if supported by MKL build)
- CNR: Conditional Numerical Reproducibility flags
- Edge cases currently covered: thread-local settings and API round-trips

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
- Threading behavior → test thread count changes take effect
- Use `mkl.get_version()` to check MKL availability before tests
