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


cimport _mkl_service as mkl
from enum import IntEnum


class enums(IntEnum):
    # MKL Function Domains Constants
    MKL_DOMAIN_BLAS = mkl.MKL_DOMAIN_BLAS
    MKL_DOMAIN_FFT = mkl.MKL_DOMAIN_FFT
    MKL_DOMAIN_VML = mkl.MKL_DOMAIN_VML
    MKL_DOMAIN_PARDISO = mkl.MKL_DOMAIN_PARDISO
    MKL_DOMAIN_ALL = mkl.MKL_DOMAIN_ALL

    # MKL Peak Memory Usage Constants
    MKL_PEAK_MEM_ENABLE = mkl.MKL_PEAK_MEM_ENABLE
    MKL_PEAK_MEM_DISABLE = mkl.MKL_PEAK_MEM_DISABLE
    MKL_PEAK_MEM = mkl.MKL_PEAK_MEM
    MKL_PEAK_MEM_RESET = mkl.MKL_PEAK_MEM_RESET

    # CNR Control Constants
    MKL_CBWR_AUTO = mkl.MKL_CBWR_AUTO
    MKL_CBWR_COMPATIBLE = mkl.MKL_CBWR_COMPATIBLE
    MKL_CBWR_SSE2 = mkl.MKL_CBWR_SSE2
    MKL_CBWR_SSE3 = mkl.MKL_CBWR_SSE3
    MKL_CBWR_SSSE3 = mkl.MKL_CBWR_SSSE3
    MKL_CBWR_SSE4_1 = mkl.MKL_CBWR_SSE4_1
    MKL_CBWR_SSE4_2 = mkl.MKL_CBWR_SSE4_2
    MKL_CBWR_AVX = mkl.MKL_CBWR_AVX
    MKL_CBWR_AVX2 = mkl.MKL_CBWR_AVX2
    MKL_CBWR_AVX512_MIC = mkl.MKL_CBWR_AVX512_MIC
    MKL_CBWR_AVX512 = mkl.MKL_CBWR_AVX512_MIC
    MKL_CBWR_BRANCH = mkl.MKL_CBWR_BRANCH
    MKL_CBWR_ALL = mkl.MKL_CBWR_ALL
    MKL_CBWR_SUCCESS = mkl.MKL_CBWR_SUCCESS
    MKL_CBWR_ERR_INVALID_INPUT = mkl.MKL_CBWR_ERR_INVALID_INPUT
    MKL_CBWR_ERR_UNSUPPORTED_BRANCH = mkl.MKL_CBWR_ERR_UNSUPPORTED_BRANCH
    MKL_CBWR_ERR_MODE_CHANGE_FAILURE = mkl.MKL_CBWR_ERR_MODE_CHANGE_FAILURE

    # ISA Constants
    MKL_ENABLE_AVX512 = mkl.MKL_ENABLE_AVX512
    MKL_ENABLE_AVX512_MIC = mkl.MKL_ENABLE_AVX512_MIC
    MKL_ENABLE_AVX2 = mkl.MKL_ENABLE_AVX2
    MKL_ENABLE_AVX = mkl.MKL_ENABLE_AVX
    MKL_ENABLE_SSE4_2 = mkl.MKL_ENABLE_SSE4_2

    # MPI Implementation Constants
    MKL_BLACS_CUSTOM = mkl.MKL_BLACS_CUSTOM
    MKL_BLACS_MSMPI = mkl.MKL_BLACS_MSMPI
    MKL_BLACS_INTELMPI = mkl.MKL_BLACS_INTELMPI
    #MKL_BLACS_MPICH = mkl.MKL_BLACS_MPICH

    # unsigned int vmlSetMode(unsigned int mode)
    # In
    VML_HA = mkl.VML_HA
    VML_LA = mkl.VML_LA
    VML_EP = mkl.VML_EP
    VML_FTZDAZ_ON = mkl.VML_FTZDAZ_ON
    VML_FTZDAZ_OFF = mkl.VML_FTZDAZ_OFF
    VML_ERRMODE_IGNORE = mkl.VML_ERRMODE_IGNORE
    VML_ERRMODE_ERRNO = mkl.VML_ERRMODE_ERRNO
    VML_ERRMODE_STDERR = mkl.VML_ERRMODE_STDERR
    VML_ERRMODE_EXCEPT = mkl.VML_ERRMODE_EXCEPT
    VML_ERRMODE_CALLBACK = mkl.VML_ERRMODE_CALLBACK
    VML_ERRMODE_DEFAULT = mkl.VML_ERRMODE_DEFAULT

    # int vmlSetErrStatus(const MKL_INT status)
    # In
    VML_STATUS_OK = mkl.VML_STATUS_OK
    VML_STATUS_ACCURACYWARNING = mkl.VML_STATUS_ACCURACYWARNING
    VML_STATUS_BADSIZE = mkl.VML_STATUS_BADSIZE
    VML_STATUS_BADMEM = mkl.VML_STATUS_BADMEM
    VML_STATUS_ERRDOM = mkl.VML_STATUS_ERRDOM
    VML_STATUS_SING = mkl.VML_STATUS_SING
    VML_STATUS_OVERFLOW = mkl.VML_STATUS_OVERFLOW
    VML_STATUS_UNDERFLOW = mkl.VML_STATUS_UNDERFLOW


# MKL Function Domains Constants
__mkl_domain_enums = {
    'blas': mkl.MKL_DOMAIN_BLAS,
    'fft': mkl.MKL_DOMAIN_FFT,
    'vml': mkl.MKL_DOMAIN_VML,
    'pardiso': mkl.MKL_DOMAIN_PARDISO,
    'all': mkl.MKL_DOMAIN_ALL,
}

# MKL Peak Memory Usage Constants
__mkl_peak_mem_usage_enums = {
    'enable': mkl.MKL_PEAK_MEM_ENABLE,
    'disable': mkl.MKL_PEAK_MEM_DISABLE,
    'peak_mem': mkl.MKL_PEAK_MEM,
    'peak_mem_reset': mkl.MKL_PEAK_MEM_RESET,
}

# CNR Control Constants Constants
__mkl_cbwr_set_in_enums = {
    'auto': mkl.MKL_CBWR_AUTO,
    'compatible': mkl.MKL_CBWR_COMPATIBLE,
    'sse2': mkl.MKL_CBWR_SSE2,
    'sse3': mkl.MKL_CBWR_SSE3,
    'ssse3': mkl.MKL_CBWR_SSSE3,
    'sse4_1': mkl.MKL_CBWR_SSE4_1,
    'sse4_2': mkl.MKL_CBWR_SSE4_2,
    'avx': mkl.MKL_CBWR_AVX,
    'avx2': mkl.MKL_CBWR_AVX2,
    'avx512_mic': mkl.MKL_CBWR_AVX512_MIC,
    'avx512': mkl.MKL_CBWR_AVX512,
}

__mkl_cbwr_set_out_enums = {
    mkl.MKL_CBWR_SUCCESS: 'success',
    mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
    mkl.MKL_CBWR_ERR_UNSUPPORTED_BRANCH: 'err_unsupported_branch',
    mkl.MKL_CBWR_ERR_MODE_CHANGE_FAILURE: 'err_mode_change_failure',
}

__mkl_cbwr_get_in_enums = {
    'branch': mkl.MKL_CBWR_BRANCH,
    'all': mkl.MKL_CBWR_ALL,
}

__mkl_cbwr_get_out_enums = {
    mkl.MKL_CBWR_SUCCESS: 'success',
    mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
}
__mkl_cbwr_get_out_enums.update({value: key for key, value in __mkl_cbwr_set_in_enums.items()})

__mkl_cbwr_get_auto_branch_out_enums = {}
__mkl_cbwr_get_auto_branch_out_enums.update({value: key for key, value in __mkl_cbwr_set_in_enums.items()})

# ISA Constants
__mkl_isa_enums = {
    'avx512': mkl.MKL_ENABLE_AVX512,
    'avx512_mic': mkl.MKL_ENABLE_AVX512_MIC,
    'avx2': mkl.MKL_ENABLE_AVX2,
    'avx': mkl.MKL_ENABLE_AVX,
    'sse4_2': mkl.MKL_ENABLE_SSE4_2,
}

# MPI Implementation Constants
__mkl_blacs_enums = {
    'custom': mkl.MKL_BLACS_CUSTOM,
    'msmpi': mkl.MKL_BLACS_MSMPI,
    'intelmpi': mkl.MKL_BLACS_INTELMPI,
    #'mpich': mkl.MKL_BLACS_MPICH,}
}


# MKL support functions
def mkl_get_version():
    cdef mkl.MKLVersion c_mkl_version
    mkl.mkl_get_version(&c_mkl_version)
    return c_mkl_version


def mkl_get_version_string():
    cdef int c_string_len = 198
    cdef char[198] c_string
    mkl.mkl_get_version_string(c_string, c_string_len)
    return c_string.decode()


# Threading
def mkl_set_num_threads(num_threads):
    assert(type(num_threads) is int)
    assert(num_threads > 0)

    prev_num_threads = mkl_get_max_threads()
    assert(type(prev_num_threads) is int)
    assert(prev_num_threads > 0)

    mkl.mkl_set_num_threads(num_threads)

    return prev_num_threads


def mkl_domain_set_num_threads(num_threads, domain='all'):
    assert(type(num_threads) is int)
    assert(num_threads >= 0)
    domain_type = type(domain)
    if domain_type is str:
        assert(domain in __mkl_domain_enums.keys())
        domain = __mkl_domain_enums[domain]
    else:
        assert((domain_type is int) and (domain in __mkl_domain_enums.values()))

    status = mkl.mkl_domain_set_num_threads(num_threads, domain)
    assert((status == 0) or (status == 1))

    if (status == 1):
        status = 'success'
    else:
        status = 'error'

    return status


def mkl_set_num_threads_local(num_threads):
    assert(type(num_threads) is int)
    assert(num_threads >= 0)
    status = mkl.mkl_set_num_threads_local(num_threads)
    assert(status >= 0)

    if (status == 0):
        status = 'global_num_threads'

    return status


def mkl_set_dynamic(enable):
    assert(type(enable) is bool)
    if enable:
        enable = 1
    else:
        enable = 0

    mkl.mkl_set_dynamic(enable)

    return mkl_get_max_threads()


def mkl_get_max_threads():
    num_threads = mkl.mkl_get_max_threads()
    assert(type(num_threads) is int)
    assert(num_threads >= 1)

    return num_threads


def mkl_domain_get_max_threads(domain='all'):
    domain_type = type(domain)
    if domain_type is str:
        assert(domain in __mkl_domain_enums.keys())
        domain = __mkl_domain_enums[domain]
    else:
        assert((domain_type is int) and (domain in __mkl_domain_enums.values()))

    num_threads = mkl.mkl_domain_get_max_threads(domain)
    assert(type(num_threads) is int)
    assert(num_threads >= 1)

    return num_threads


def mkl_get_dynamic():
    dynamic_enabled = mkl.mkl_get_dynamic()
    assert((dynamic_enabled == 0) or (dynamic_enabled == 1))
    return mkl.mkl_get_dynamic()


# Timing
def second():
    return mkl.second()


def dsecnd():
    return mkl.dsecnd()


def mkl_get_cpu_clocks():
    cdef mkl.MKL_UINT64 clocks
    mkl.mkl_get_cpu_clocks(&clocks)
    return clocks


def mkl_get_cpu_frequency():
    return mkl.mkl_get_cpu_frequency()


def mkl_get_max_cpu_frequency():
    return mkl.mkl_get_max_cpu_frequency()


def mkl_get_clocks_frequency():
    return mkl.mkl_get_clocks_frequency()


# Memory
def mkl_free_buffers():
    mkl.mkl_free_buffers()


def mkl_thread_free_buffers():
    mkl.mkl_thread_free_buffers()


def mkl_disable_fast_mm():
    return mkl.mkl_disable_fast_mm()


def mkl_mem_stat():
    cdef int AllocatedBuffers
    cdef mkl.MKL_INT64 AllocatedBytes
    AllocatedBytes = mkl.mkl_mem_stat(&AllocatedBuffers)
    return AllocatedBytes, AllocatedBuffers


def mkl_peak_mem_usage(mem_const):
    mem_const_type = type(mem_const)
    if mem_const_type is str:
        assert(mem_const in __mkl_peak_mem_usage_enums.keys())
        mem_const = __mkl_peak_mem_usage_enums[mem_const]
    else:
        assert((mem_const_type is int) and (mem_const in __mkl_peak_mem_usage_enums.values()))

    memory_allocator = mkl.mkl_peak_mem_usage(mem_const)
    assert(type(memory_allocator) is int)
    assert(memory_allocator >= -1)

    if memory_allocator == -1:
        memory_allocator = 'error'

    return memory_allocator


def mkl_set_memory_limit(limit):
    assert(limit >= 0)
    status = mkl.mkl_set_memory_limit(mkl.MKL_MEM_MCDRAM, limit)
    assert((status == 0) or (status == 1))

    if status == 1:
        status = 'success'
    else:
        status = 'error'

    return status


# Conditional Numerical Reproducibility
def mkl_cbwr_set(branch=None):
    branch_type = type(branch)
    if branch_type is str:
        assert(branch in __mkl_cbwr_set_in_enums.keys())
        branch = __mkl_cbwr_set_in_enums[branch]
    else:
        assert((branch_type is int) and (branch in __mkl_cbwr_set_in_enums.values()))

    status = mkl.mkl_cbwr_set(branch)
    assert(status in __mkl_cbwr_set_out_enums.keys())

    return __mkl_cbwr_set_out_enums[status]


def mkl_cbwr_get(cnr_const=None):
    cnr_const_type = type(cnr_const)
    if cnr_const_type is str:
        assert(cnr_const in __mkl_cbwr_get_in_enums)
        cnr_const = __mkl_cbwr_get_in_enums[cnr_const]
    else:
        assert(issubclass(cnr_const_type, IntEnum))
        assert(type(cnr_const.value) is int)
        assert(cnr_const.value in __mkl_cbwr_get_in_enums.values())
        cnr_const = cnr_const.value

    status = mkl.mkl_cbwr_get(cnr_const)
    assert(status in __mkl_cbwr_get_out_enums)

    return __mkl_cbwr_get_out_enums[status]


def mkl_cbwr_get_auto_branch():
    status = mkl.mkl_cbwr_get_auto_branch()
    assert(status in __mkl_cbwr_get_auto_branch_out_enums)

    return __mkl_cbwr_get_auto_branch_out_enums[status]


# Miscellaneous
def mkl_enable_instructions(isa=None):
    isa_type = type(isa)
    if isa_type is str:
        assert(isa in __mkl_isa_enums)
        isa = __mkl_isa_enums[isa]
    else:
        assert(issubclass(isa_type, IntEnum))
        assert(type(isa.value) is int)
        assert(isa.value in __mkl_isa_enums.values())
        isa = isa.value

    status = mkl.mkl_enable_instructions(isa)
    assert((status == 0) or (status == 1))

    if (status == 1):
        status = 'success'
    else:
        status = 'error'

    return status


def mkl_set_env_mode(mode):
    assert((mode == 0) or (mode == 1))
    return mkl.mkl_set_env_mode(mode)


def mkl_verbose(enable):
    assert(type(enable) is bool)
    return mkl.mkl_verbose(enable)


def mkl_set_mpi(vendor, custom_library_name):
    vendor_type = type(vendor)
    if vendor_type is str:
        assert(vendor in __mkl_blacs_enums)
        vendor = __mkl_blacs_enums[vendor]
    else:
        assert(issubclass(vendor_type, IntEnum))
        assert(type(vendor.value) is int)
        assert(vendor.value in __mkl_blacs_enums.values())
        vendor = vendor.value

    cdef bytes c_bytes = custom_library_name.encode()
    cdef char* c_string = c_bytes
    status = mkl.mkl_set_mpi(vendor, c_string)
    assert(status in range(-3, 1))

    if status == 0:
        status = 'success'
    elif status == -1:
        status = 'vendor_invalid'
    elif status == '-2':
        status = 'custom_library_name_invalid'
    else:
        status = 'the MPI library cannot be set at this point'

    return status


# VM Service Functions
def vmlSetMode(mode):
    return mkl.vmlSetMode(mode)


def vmlGetMode():
    return mkl.vmlGetMode()


def vmlSetErrStatus(status):
    return mkl.vmlSetErrStatus(status)


def vmlGetErrStatus():
    return mkl.vmlGetErrStatus()


def vmlClearErrStatus():
    return mkl.vmlClearErrStatus()
