# ``mkl-service`` - Python package for run-time control of Intel(R) Math Kernel Library.
[![Build Status](https://travis-ci.com/IntelPython/mkl-service.svg?branch=master)](https://travis-ci.com/IntelPython/mkl-service)

See the [blog](https://software.intel.com/en-us/blogs/2018/10/18/mkl-service-package-controlling-mkl-behavior-through-python-interfaces) announcing the release.

To install the package, use `conda install -c intel mkl-service`, or `conda install -c conda-forge mkl-service`.

A short example, illustrating it use:

```python
import tomopy
import mkl
mkl.domain_set_num_threads(1, domain='fft') # Intel(R) MKL FFT functions to run sequentially
```