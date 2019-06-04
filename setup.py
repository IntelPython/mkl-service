#!/usr/bin/env python
# Copyright (c) 2018-2019, Intel Corporation
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#     * Redistributions of source code must retain the above copyright notice,
#       this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of Intel Corporation nor the names of its contributors
#       may be used to endorse or promote products derived from this software
#       without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.


from __future__ import division, print_function, absolute_import
import io
import re
import os
from os.path import join, exists, dirname
import setuptools
import setuptools.extension

with io.open('mkl/__init__.py', 'rt', encoding='utf8') as file:
    VERSION = re.search(r'__version__ = \'(.*?)\'', file.read()).group(1)

CLASSIFIERS = """\
Development Status :: 5 - Production/Stable
Intended Audience :: Science/Research
Intended Audience :: Developers
License :: OSI Approved
Programming Language :: C
Programming Language :: Python
Programming Language :: Python :: 2
Programming Language :: Python :: 2.7
Programming Language :: Python :: 3
Programming Language :: Python :: 3.5
Programming Language :: Python :: 3.6
Programming Language :: Python :: 3.7
Programming Language :: Python :: Implementation :: CPython
Topic :: Software Development
Topic :: Utilities
Operating System :: Microsoft :: Windows
Operating System :: POSIX
Operating System :: Unix
Operating System :: MacOS
"""


def get_extensions():
    try:
        from numpy.distutils.system_info import get_info
        mkl_info = get_info('mkl')
    except ImportError:
        mkl_root = os.environ['MKLROOT']
        mkl_info = {
            'include_dirs': [join(mkl_root, 'include')],
            'library_dirs': [join(mkl_root, 'lib'), join(mkl_root, 'lib', 'intel64')],
            'libraries': ['mkl_rt']
        }

    mkl_include_dirs = mkl_info.get('include_dirs', [])
    mkl_library_dirs = mkl_info.get('library_dirs', [])
    mkl_libraries = mkl_info.get('libraries', ['mkl_rt'])

    defs = []
    if any(['mkl_rt' in li for li in mkl_libraries]):
        #libs += ['dl'] - by default on Linux
        defs += [('USING_MKL_RT', None)]

    pdir = 'mkl'
    try:
        from Cython.Build import cythonize
        sources = [join(pdir, '_mkl_service.pyx')]
        have_cython = True
    except ImportError as e:
        have_cython = False
        sources = [join(pdir, '_mkl_service.c')]
        if not exists(sources[0]):
            raise ValueError(str(e) + '. ' +
                             'Cython is required to build the initial .c file.')

    extensions = []
    extensions.append(
        setuptools.extension.Extension(
            'mkl._mklinit',
            sources=['mkl/_mklinitmodule.c'],
            define_macros=defs,
            include_dirs=mkl_include_dirs,
            libraries=mkl_libraries,
            library_dirs=mkl_library_dirs,
            extra_compile_args=[
                '-DNDEBUG'
                # '-g', '-O2', '-Wall',
            ]
        )
    )

    extensions.append(
        setuptools.extension.Extension(
            'mkl._py_mkl_service',
            sources=sources,
            include_dirs=mkl_include_dirs,
            library_dirs=mkl_library_dirs,
            libraries=mkl_libraries,
            extra_compile_args=[
                '-DNDEBUG'
                # '-g', '-O2', '-Wall',
            ]
        )
    )

    if have_cython:
        extensions = cythonize(extensions, include_path=[join(__file__, pdir)])

    return extensions


def setup_package():
    from setuptools import setup
    metadata = dict(
        name='mkl-service',
        version=VERSION,
        maintainer="Intel",
        maintainer_email="scripting@intel.com",
        description="MKL Support Functions",
        long_description="""
            Intel(R) Math Kernel Library (Intel(R) MKL) support functions are
            subdivided into the following groups according to their purpose:
                Version Information
                Threading Control
                Timing
                Memory Management
                Conditional Numerical Reproducibility Control
                Miscellaneous
        """,
        url="https://github.com/IntelPython/mkl-service",
        author="Intel",
        download_url="https://github.com/IntelPython/mkl-service",
        license='BSD',
        classifiers=[_f for _f in CLASSIFIERS.split('\n') if _f],
        platforms=["Windows", "Linux", "Mac OS-X"],
        test_suite='nose.collector',
        python_requires='>=2.7,!=3.0.*,!=3.1.*,!=3.2.*,!=3.3.*',
        setup_requires=['setuptools', 'cython'],
        install_requires=['six'],
        packages=setuptools.find_packages(),
        ext_modules=get_extensions()
    )
    setup(**metadata)

    return None


if __name__ == '__main__':
    setup_package()
