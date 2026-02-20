# AGENTS.md — examples/

Usage examples for mkl-service runtime control API.

## Files
- **example.py** — basic usage: threading control, version info, timing

## Examples cover
- Setting global thread count with `mkl.set_num_threads()`
- Domain-specific threading (FFT, BLAS, etc.)
- Querying MKL version and build info
- Memory usage statistics
- Timing functions for benchmarking

## Running examples
```bash
python examples/example.py
```

## Notes
- Examples assume MKL is installed (conda: `mkl` package)
- Threading changes affect all MKL-backed libraries in the process
- Useful for verifying mkl-service installation and MKL availability
