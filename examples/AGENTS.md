# AGENTS.md — examples/

Usage examples for mkl-service runtime control API.

## Files
- **example.py** — basic usage: MKL version query, instruction dispatch control, and timing

## Examples cover
- Querying MKL version/build info (`get_version()`, `get_version_string()`)
- Controlling instruction dispatch with `enable_instructions()`
- Using `dsecnd()` for simple timing

## Running examples
```bash
python examples/example.py
```

## Notes
- Examples assume MKL is installed (conda: `mkl` package)
- Example is intended as a lightweight installation/runtime sanity check
- Threading/domain APIs are available in `mkl-service` but not exercised in this example
