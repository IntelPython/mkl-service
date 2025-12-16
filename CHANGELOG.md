# changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [dev] (MM/DD/YYYY)

### Removed
* Dropped support for Python 3.9 [gh-118](https://github.com/IntelPython/mkl-service/pull/118)

## [2.6.1] (11/25/2025)

### Fixed
* Fixed the run-time dependencies of `mkl-service` package to explicitly depend on a non–free-threaded (GIL-enabled) Python [gh-111](github.com/IntelPython/mkl-service/pull/111)

## [2.6.0] (10/06/2025)

### Added
* Enabled support of Python 3.14 [gh-100](https://github.com/IntelPython/mkl-service/pull/100)

### Changed
* Used `GIT_DESCRIBE_TAG` and `GIT_DESCRIBE_NUMBER` in `meta.yaml` instead of manual stepping the numbers [gh-98](github.com/IntelPython/mkl-service/pull/98)

## [2.5.2] (07/01/2025)

### Fixed
* Updated `meta.yaml` with proper license description to pass the validation rules [gh-87](github.com/IntelPython/mkl-service/pull/87)

## [2.5.1] (06/27/2025)

### Fixed
* Resolved import issue in the virtual environment which broke loading of MKL libs [gh-85](github.com/IntelPython/mkl-service/pull/85)

## [2.5.0] (06/03/2025)

### Added
* Added support for python 3.13 [gh-72](github.com/IntelPython/mkl-service/pull/72)
* Added support in virtual environment out of the box [gh-79](github.com/IntelPython/mkl-service/pull/79)

### Changed
* Migrated from `setup.py` to `pyproject.toml` [gh-66](github.com/IntelPython/mkl-service/pull/66)

## [2.4.2] (10/12/2024)

Tests checking library version moved to the end of the test suite, as after it is run, the state of the library is finalized, and tests that modify that state may fail.

Updated installation instructions.

## [2.4.1]

Transition from `nose` to `unittest` and then to `pytest` to enable support for Python 3.12.

Added Github Actions CI.

Removed `six` as a dependency.

## [2.4.0.post1]

Update description for PyPI package installation

## [2.4.0]

Fixed issue [#14](https://github.com/IntelPython/mkl-service/issues/14).

Added [`mkl.set_num_stripes`](https://software.intel.com/content/www/us/en/develop/documentation/onemkl-developer-reference-c/top/support-functions/threading-control/mkl-set-num-stripes.html) and [`mkl.get_num_stripes`](https://software.intel.com/content/www/us/en/develop/documentation/onemkl-developer-reference-c/top/support-functions/threading-control/mkl-get-num-stripes.html)

Also expanded support `isa` keyword argument values in `mkl.enable_instructions(isa=isa)` function per recent [Intel® oneAPI Math Kernel Library (oneMKL)](https://www.intel.com/content/www/us/en/docs/onemkl/developer-guide-linux/2025-2/instruction-set-specific-dispatch-on-intel-archs.html) support.

## [2.3.0]

Fixed CI to actually execute tests. Populated CBWR constants to match MKL headers.

Added tests checking that `cbwr_set` and `cbwr_get` round-trip.

## [2.2.0]

Closed issues #8, #7 and #5.

Extended `mkl.cbwr_set` to recognize `'avx512_e1'`, `'avx512_mic_e1'`, as as strict conditional numerical reproducibility, supported via `'avx2,strict'`, `'avx512,strict'` (see [issue/8](http://github.com/IntelPython/mkl-service/issues/8)).

Extended `mkl.cbwrt_get()` to mean `mkl.cbwr('all')`.

## [2.1.0]

Change in setup script to not use `numpy.distutils` thus removing numpy as build-time dependency.

Change in conda-recipe to allow conda build to build the recipe, but ignoring run export on mkl-service coming from mkl-devel metadata.

## [2.0.2]

Correction to `setup.py` to not require Cython at the installation time.

## [2.0.1]

Re-release, with some changes necessary for public CI builds to work.

## [2.0.0]

Work-around for VS 9.0 not having `inline` keyword, allowing the package to build on Windows for Python 2.7

## [2.0.0]

Rerelease of `mkl-service` package with version bumped to 2.0.0 to avoid version clash with `mkl-service` package from Anaconda.

Improved argument checking, which raises an informative error.

Loading the package with `import mkl` initializes Intel(R) MKL library to use LP64 interface (i.e. use of environment variable `MKL_INTERFACE` will not have effect).

The choice of threading layer can be controlled with environment variable `MKL_THREADING_LAYER`. However the unset variable is interpreted differently that in Intel(R) MKL itself. If `mkl-service` detects that Gnu OpenMP has been loaded in Python space, the threading layer of Intle(R) MKL will be set to Gnu OpenMP, instead of Intel(R) OpenMP.

## [1.0.0]

Initial release of `mkl-service` package.
