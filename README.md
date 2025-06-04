# `mkl-service` - Python package for run-time control of Intel® OneAPI Math Kernel Library (OneMKL).
[![Conda package](https://github.com/IntelPython/mkl-service/actions/workflows/conda-package.yml/badge.svg)](https://github.com/IntelPython/mkl-service/actions/workflows/conda-package.yml)
[![Build mkl-service with clang](https://github.com/IntelPython/mkl-service/actions/workflows/build-with-clang.yml/badge.svg)](https://github.com/IntelPython/mkl-service/actions/workflows/build-with-clang.yml)
[![OpenSSF Scorecard](https://api.securityscorecards.dev/projects/github.com/IntelPython/mkl-service/badge)](https://securityscorecards.dev/viewer/?uri=github.com/IntelPython/mkl-service)


---

To install conda package, use `conda install -c https://software.repos.intel.com/python/conda/ mkl-service`, or `conda install -c conda-forge mkl-service`.

To install PyPI package, use `python -m pip install mkl-service`.

---

Intel® OneMKL support functions are subdivided into the following groups according to their purpose:
 - Version Information
 - Threading Control
 - Timing
 - Memory Management
 - Conditional Numerical Reproducibility Control
 - Miscellaneous

A short example, illustrating its use:

```python
>>> import mkl
>>> mkl.domain_set_num_threads(1, domain="fft") # OneMKL FFT functions to run sequentially
# 'success'
```

For more information about the usage of support functions see [Developer Reference for Intel® oneAPI Math Kernel Library for C](https://www.intel.com/content/www/us/en/docs/onemkl/developer-reference-c/2025-1/support-functions.html).
