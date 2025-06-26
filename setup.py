# Copyright (c) 2018, Intel Corporation
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


import os
from os.path import join

import Cython.Build
from setuptools import Extension, setup


def extensions():
    mkl_root = os.environ.get("MKLROOT", None)
    if mkl_root:
        mkl_info = {
            "include_dirs": [join(mkl_root, "include")],
            "library_dirs": [join(mkl_root, "lib"), join(mkl_root, "lib", "intel64")],
            "libraries": ["mkl_rt"],
        }
    else:
        raise ValueError("MKLROOT environment variable not set.")

    mkl_include_dirs = mkl_info.get("include_dirs", [])
    mkl_library_dirs = mkl_info.get("library_dirs", [])
    mkl_libraries = mkl_info.get("libraries", ["mkl_rt"])

    defs = []
    if any(["mkl_rt" in li for li in mkl_libraries]):
        # libs += ["dl"] - by default on Linux
        defs += [("USING_MKL_RT", None)]

    extensions = []
    extensions.append(
        Extension(
            "mkl._mklinit",
            sources=[join("mkl", "_mklinitmodule.c")],
            include_dirs=mkl_include_dirs,
            libraries=mkl_libraries + (["pthread"] if os.name == "posix" else []),
            library_dirs=mkl_library_dirs,
            runtime_library_dirs=["$ORIGIN/../..", "$ORIGIN/../../.."],
            extra_compile_args=[
                "-DNDEBUG"
                # "-g", "-O2", "-Wall",
            ],
            define_macros=defs,
        )
    )

    extensions.append(
        Extension(
            "mkl._py_mkl_service",
            sources=[join("mkl", "_mkl_service.pyx")],
            include_dirs=mkl_include_dirs,
            library_dirs=mkl_library_dirs,
            libraries=mkl_libraries,
            extra_compile_args=[
                "-DNDEBUG"
                # "-g", "-O2", "-Wall",
            ],
        )
    )

    return extensions


setup(
    cmdclass={"build_ext": Cython.Build.build_ext},
    ext_modules=extensions(),
    zip_safe=False,
)
