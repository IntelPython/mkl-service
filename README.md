# ``mkl-service`` - Python package for run-time control of Intel(R) Math Kernel Library.
[![Build Status](https://travis-ci.com/IntelPython/mkl-service.svg?branch=master)](https://travis-ci.com/IntelPython/mkl-service)

See the [blog](https://software.intel.com/en-us/blogs/2018/10/18/mkl-service-package-controlling-mkl-behavior-through-python-interfaces) announcing the release.

---

To install conda package, use `conda install -c intel mkl-service`, or `conda install -c conda-forge mkl-service`.

To install pypi package, use `python -m pip install mkl-service`

---

Intel(R) Math Kernel Library support functions are subdivided into the following groups according to their purpose:
 - Version Information
 - Threading Control
 - Timing
 - Memory Management
 - Conditional Numerical Reproducibility Control
 - Miscellaneous

A short example, illustrating it use:

```python
import tomopy
import mkl
mkl.domain_set_num_threads(1, domain='fft') # Intel(R) MKL FFT functions to run sequentially
```