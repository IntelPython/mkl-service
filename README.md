# `mkl-service` - Python package for run-time control of Intel® oneAPI Math Kernel Library (oneMKL).
[![Conda package](https://github.com/IntelPython/mkl-service/actions/workflows/conda-package.yml/badge.svg)](https://github.com/IntelPython/mkl-service/actions/workflows/conda-package.yml)
[![Build mkl-service with clang](https://github.com/IntelPython/mkl-service/actions/workflows/build-with-clang.yml/badge.svg)](https://github.com/IntelPython/mkl-service/actions/workflows/build-with-clang.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/IntelPython/mkl-service/badge)](https://securityscorecards.dev/viewer/?uri=github.com/IntelPython/mkl-service)


---

To install conda package, use `conda install -c https://software.repos.intel.com/python/conda/ mkl-service`, or `conda install -c conda-forge mkl-service`.

To install PyPI package, use `python -m pip install mkl-service`.

---

Intel® oneAPI Math Kernel Library (oneMKL) supports functions are subdivided into the following groups according to their purpose:
 - Version Information
 - Threading Control
 - Timing
 - Memory Management
 - Conditional Numerical Reproducibility Control
 - Miscellaneous

A short example, illustrating its use:

```python
>>> import mkl
>>> mkl.domain_set_num_threads(1, domain="fft") # oneMKL FFT functions to run sequentially
# 'success'
```

For more information about the usage of support functions see [Developer Reference for Intel® oneAPI Math Kernel Library for C](https://www.intel.com/content/www/us/en/docs/onemkl/developer-reference-c/2025-2/support-functions.html).

---

## Building

A C compiler and Intel(R) oneAPI Math Kernel Library (oneMKL) are required to build mkl-service from source.

Executing
```sh
python -m pip install .
```

will pull in the required build dependencies, including `mkl`, and build `mkl-service`.

If you already have `mkl` installed (from your system or a Conda environment) and
want to reuse it instead of pulling a fresh copy into an isolated build, first
install the build dependencies:
```sh
python -m pip install mkl-devel meson-python cmake ninja "cython>=3.1.0"
```

then build against the existing installation with:
```sh
python -m pip install --no-build-isolation --no-deps .
```

### Build options

| Option  | Type    | Default | Description                           |
| ------- | ------- | ------- | ------------------------------------- |
| `ilp64` | boolean | `false` | Build with the oneMKL ILP64 interface |

Options are passed using `-Csetup-args`:
```sh
python -m pip install . -Csetup-args=-Dilp64=true
```

By default `mkl-service` is built against the LP64 interface, in which oneMKL's
integer type `MKL_INT` is 32-bit. Enabling `ilp64` makes `MKL_INT` 64-bit
and requests the ILP64 interface layer from `libmkl_rt` on import.
Use it when the oneMKL libraries you link against provide the ILP64 interface.

The Python API is identical in both configurations — no function signature or
return value changes.

> **Warning:** the oneMKL interface layer is process-global and can only be
> selected before the first oneMKL call. `mkl-service` requests it on import,
> so an ILP64 build is order-dependent and unsafe to mix with LP64
> consumers:
>
> * If imported before another oneMKL consumer initializes oneMKL, that
>   consumer's LP64 calls get reinterpreted as ILP64. LAPACK routines in
>   particular may crash.
> * If the other consumer initializes oneMKL first, the ILP64 request is ignored
>   and the process stays LP64.
>
> Only enable `ilp64` when every consumer uses the ILP64 interface or
> `mkl-service` is the sole oneMKL consumer in the process.
