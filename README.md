# mkl-service

Python hooks for Intel(R) Math Kernel Library runtime control settings.

See the [blog](https://software.intel.com/en-us/blogs/2018/10/18/mkl-service-package-controlling-mkl-behavior-through-python-interfaces) announcing the release.

To install the package, use `conda install -c intel mkl-service`.

A short example, illustrating it use:

```python
import tomopy
import mkl
mkl.domain_set_num_threads(1, domain='fft') # Intel (R) MKL FFT functions to run sequentially
```