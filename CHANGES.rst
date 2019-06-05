=====================
mkl-service changelog
=====================


1.0.0
=====

Initial release of `mkl-service` package.

2.0.0
====

Rerelease of `mkl-service` package with version bumped to 2.0.0 to avoid version clash with `mkl-service` package from Anaconda.

Improved argument checking, which raises an informative error.

Loading the package with `import mkl` initializes Intel(R) MKL library to use LP64 interface (i.e. use of environment variable `MKL_INTERFACE` will not have effect).

The choice of threading layer can be controlled with environment variable `MKL_THREADING_LAYER`. However the unset variable is interpreted differently that in Intel(R) MKL itself. If `mkl-service` detects that Gnu OpenMP has been loaded in Python space, the threading layer of Intle(R) MKL will be set to Gnu OpenMP, instead of Intel(R) OpenMP.

2.0.0
====

Work-around for VS 9.0 not having `inline` keyword, allowing the package to build on Windows for Python 2.7

2.0.1
=====

Re-release, with some changes necessary for public CI builds to work.

2.0.2
=====

Correction to `setup.py` to not require Cython at the installation time.

2.1,9
=====

Change in setup script to not use `numpy.distutils` thus removing numpy as build-time dependency.

Change in conda-recipe to allow conda build to build the recipe, but ignoring run export on mkl-service coming from mkl-devel metadata. 
