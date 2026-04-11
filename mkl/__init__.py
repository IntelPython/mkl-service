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

from . import _init_helper


class RTLD_for_MKL:
    def __init__(self):
        self.saved_rtld = None

    def __enter__(self):
        import ctypes
        import sys

        try:
            self.saved_rtld = sys.getdlopenflags()
            # python loads libraries with RTLD_LOCAL, but MKL requires
            # RTLD_GLOBAL pre-load MKL with RTLD_GLOBAL before loading
            # the native extension
            sys.setdlopenflags(self.saved_rtld | ctypes.RTLD_GLOBAL)
        except AttributeError:
            pass
        del ctypes

    def __exit__(self, *args):
        import sys

        if self.saved_rtld:
            sys.setdlopenflags(self.saved_rtld)
            self.saved_rtld = None


with RTLD_for_MKL():
    from . import _mklinit

del RTLD_for_MKL

from ._py_mkl_service import (
    cbwr_get,
    cbwr_get_auto_branch,
    cbwr_set,
    disable_fast_mm,
    domain_get_max_threads,
    domain_set_num_threads,
    dsecnd,
    enable_instructions,
    free_buffers,
    get_clocks_frequency,
    get_cpu_clocks,
    get_cpu_frequency,
    get_dynamic,
    get_env_mode,
    get_max_cpu_frequency,
    get_max_threads,
    get_num_stripes,
    get_version,
    get_version_string,
    mem_stat,
    peak_mem_usage,
    second,
    set_dynamic,
    set_env_mode,
    set_memory_limit,
    set_mpi,
    set_num_stripes,
    set_num_threads,
    set_num_threads_local,
    thread_free_buffers,
    verbose,
    vml_clear_err_status,
    vml_get_err_status,
    vml_get_mode,
    vml_set_err_status,
    vml_set_mode,
)
from ._version import __version__

__all__ = [
    "get_version",
    "get_version_string",
    "set_num_threads",
    "domain_set_num_threads",
    "set_num_threads_local",
    "set_dynamic",
    "get_max_threads",
    "domain_get_max_threads",
    "get_dynamic",
    "set_num_stripes",
    "get_num_stripes",
    "second",
    "dsecnd",
    "get_cpu_clocks",
    "get_cpu_frequency",
    "get_max_cpu_frequency",
    "get_clocks_frequency",
    "free_buffers",
    "thread_free_buffers",
    "disable_fast_mm",
    "mem_stat",
    "peak_mem_usage",
    "set_memory_limit",
    "cbwr_set",
    "cbwr_get",
    "cbwr_get_auto_branch",
    "enable_instructions",
    "set_env_mode",
    "get_env_mode",
    "verbose",
    "set_mpi",
    "vml_set_mode",
    "vml_get_mode",
    "vml_set_err_status",
    "vml_get_err_status",
    "vml_clear_err_status",
]

del _init_helper
