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
    MKL_CBWR_BRANCH_OFF = mkl.MKL_CBWR_BRANCH_OFF
    MKL_CBWR_ERR_INVALID_INPUT = mkl.MKL_CBWR_ERR_INVALID_INPUT
    MKL_CBWR_ERR_UNSUPPORTED_BRANCH = mkl.MKL_CBWR_ERR_UNSUPPORTED_BRANCH
    MKL_CBWR_ERR_MODE_CHANGE_FAILURE = mkl.MKL_CBWR_ERR_MODE_CHANGE_FAILURE

    # ISA Constants
    MKL_ENABLE_AVX512_MIC_E1 = mkl.MKL_ENABLE_AVX512_MIC_E1
    MKL_ENABLE_AVX512 = mkl.MKL_ENABLE_AVX512
    MKL_ENABLE_AVX512_MIC = mkl.MKL_ENABLE_AVX512_MIC
    MKL_ENABLE_AVX2 = mkl.MKL_ENABLE_AVX2
    MKL_ENABLE_AVX = mkl.MKL_ENABLE_AVX
    MKL_ENABLE_SSE4_2 = mkl.MKL_ENABLE_SSE4_2

    # MPI Implementation Constants
    MKL_BLACS_CUSTOM = mkl.MKL_BLACS_CUSTOM
    MKL_BLACS_MSMPI = mkl.MKL_BLACS_MSMPI
    MKL_BLACS_INTELMPI = mkl.MKL_BLACS_INTELMPI
    MKL_BLACS_MPICH2 = mkl.MKL_BLACS_MPICH2

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


def __str_or_enum_to_mkl_int(variable, possible_variables_dict):
    assert(variable is not None)
    assert(possible_variables_dict is not None)

    variable_type = type(variable)

    if variable_type is str:
        assert(variable in possible_variables_dict.keys()), 'Variable: <' + str(variable) + '> not in ' + str(possible_variables_dict)
        mkl_variable = possible_variables_dict[variable]
    else:
        assert(issubclass(variable_type, IntEnum))
        assert(type(variable.value) is int)
        assert(variable.value in possible_variables_dict.values()), 'Variable: <' + str(variable) + '> not in ' + str(possible_variables_dict)
        mkl_variable = variable.value

    return mkl_variable


def __mkl_int_to_str(mkl_int_variable, possible_variables_dict):
    assert(mkl_int_variable is not None)
    assert(type(mkl_int_variable) is int)
    assert(possible_variables_dict is not None)
    assert(mkl_int_variable in possible_variables_dict.keys()), 'Variable: <' + str(mkl_int_variable) + '> not in ' + str(possible_variables_dict)

    return possible_variables_dict[mkl_int_variable]


# Version Information
def get_version():
    """
    Returns the Intel MKL version.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version
    """
    cdef mkl.MKLVersion c_mkl_version
    mkl.mkl_get_version(&c_mkl_version)
    return c_mkl_version


def get_version_string():
    """
    Returns the Intel MKL version in a character string.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version-string
    """
    cdef int c_string_len = 198
    cdef char[198] c_string
    mkl.mkl_get_version_string(c_string, c_string_len)
    return c_string.decode()


# Threading
def set_num_threads(num_threads):
    """
    Specifies the number of OpenMP* threads to use.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads
    """
    assert(type(num_threads) is int)
    assert(num_threads > 0)

    prev_num_threads = get_max_threads()
    assert(type(prev_num_threads) is int)
    assert(prev_num_threads > 0)

    mkl.mkl_set_num_threads(num_threads)

    return prev_num_threads


def domain_set_num_threads(num_threads, domain='all'):
    """
    Specifies the number of OpenMP* threads for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-set-num-threads
    """
    __variables = {
        'input': {
            'blas': mkl.MKL_DOMAIN_BLAS,
            'fft': mkl.MKL_DOMAIN_FFT,
            'vml': mkl.MKL_DOMAIN_VML,
            'pardiso': mkl.MKL_DOMAIN_PARDISO,
            'all': mkl.MKL_DOMAIN_ALL,
        },
        'output': {
            0: 'error',
            1: 'success',
        },
    }
    assert(type(num_threads) is int)
    assert(num_threads >= 0)
    mkl_domain = __str_or_enum_to_mkl_int(domain, __variables['input'])

    mkl_status = mkl.mkl_domain_set_num_threads(num_threads, mkl_domain)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


def set_num_threads_local(num_threads):
    """
    Specifies the number of OpenMP* threads for all Intel MKL functions on the current execution thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads-local
    """
    assert(type(num_threads) is int)
    assert(num_threads >= 0)
    status = mkl.mkl_set_num_threads_local(num_threads)

    assert(status >= 0)
    if (status == 0):
        status = 'global_num_threads'
    return status


def set_dynamic(enable):
    """
    Enables Intel MKL to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-dynamic
    """
    assert(type(enable) is bool)
    if enable:
        enable = 1
    else:
        enable = 0

    mkl.mkl_set_dynamic(enable)

    return get_max_threads()


def get_max_threads():
    """
    Gets the number of OpenMP* threads targeted for parallelism.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-threads
    """
    num_threads = mkl.mkl_get_max_threads()

    assert(type(num_threads) is int)
    assert(num_threads >= 1)
    return num_threads


def domain_get_max_threads(domain='all'):
    """
    Gets the number of OpenMP* threads targeted for parallelism for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-get-max-threads
    """
    __variables = {
        'input': {
            'blas': mkl.MKL_DOMAIN_BLAS,
            'fft': mkl.MKL_DOMAIN_FFT,
            'vml': mkl.MKL_DOMAIN_VML,
            'pardiso': mkl.MKL_DOMAIN_PARDISO,
            'all': mkl.MKL_DOMAIN_ALL,
        },
        'output': None,
    }
    mkl_domain = __str_or_enum_to_mkl_int(domain, __variables['input'])

    num_threads = mkl.mkl_domain_get_max_threads(mkl_domain)

    assert(type(num_threads) is int)
    assert(num_threads >= 1)
    return num_threads


def get_dynamic():
    """
    Determines whether Intel MKL is enabled to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-dynamic
    """
    dynamic_enabled = mkl.mkl_get_dynamic()

    assert((dynamic_enabled == 0) or (dynamic_enabled == 1))
    return mkl.mkl_get_dynamic()


# Timing
def second():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return mkl.second()


def dsecnd():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return mkl.dsecnd()


def get_cpu_clocks():
    """
    Returns elapsed CPU clocks.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-clocks
    """
    cdef mkl.MKL_UINT64 clocks
    mkl.mkl_get_cpu_clocks(&clocks)
    return clocks


def get_cpu_frequency():
    """
    Returns the current CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-frequency
    """
    return mkl.mkl_get_cpu_frequency()


def get_max_cpu_frequency():
    """
    Returns the maximum CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-cpu-frequency
    """
    return mkl.mkl_get_max_cpu_frequency()


def get_clocks_frequency():
    """
    Returns the frequency value in GHz based on constant-rate Time Stamp Counter.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-clocks-frequency
    """
    return mkl.mkl_get_clocks_frequency()


# Memory Management. See the Intel MKL Developer Guide for more memory usage information.
def free_buffers():
    """
    Frees unused memory allocated by the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-free-buffers
    """
    mkl.mkl_free_buffers()
    return


def thread_free_buffers():
    """
    Frees unused memory allocated by the Intel MKL Memory Allocator in the current thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-thread-free-buffers
    """
    mkl.mkl_thread_free_buffers()
    return


def disable_fast_mm():
    """
    Turns off the Intel MKL Memory Allocator for Intel MKL functions to directly use the system malloc/free functions.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-disable-fast-mm
    """
    return mkl.mkl_disable_fast_mm()


def mem_stat():
    """
    Reports the status of the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-mem-stat
    """
    cdef int AllocatedBuffers
    cdef mkl.MKL_INT64 AllocatedBytes
    AllocatedBytes = mkl.mkl_mem_stat(&AllocatedBuffers)
    return AllocatedBytes, AllocatedBuffers


def peak_mem_usage(mem_const):
    """
    Reports the peak memory allocated by the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-peak-mem-usage
    """
    __variables = {
        'input': {
            'enable': mkl.MKL_PEAK_MEM_ENABLE,
            'disable': mkl.MKL_PEAK_MEM_DISABLE,
            'peak_mem': mkl.MKL_PEAK_MEM,
            'peak_mem_reset': mkl.MKL_PEAK_MEM_RESET,
        },
        'output': None,
    }
    mkl_mem_const = __str_or_enum_to_mkl_int(mem_const, __variables['input'])

    memory_allocator = mkl.mkl_peak_mem_usage(mkl_mem_const)

    assert(type(memory_allocator) is int)
    assert(memory_allocator >= -1)
    if memory_allocator == -1:
        memory_allocator = 'error'
    return memory_allocator


def set_memory_limit(limit):
    """
    On Linux, sets the limit of memory that Intel MKL can allocate for a specified type of memory.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-memory-limit
    """
    __variables = {
        'input': None,
        'output': {
            0: 'error',
            1: 'success',
        },
    }
    assert(limit >= 0)

    mkl_status = mkl.mkl_set_memory_limit(mkl.MKL_MEM_MCDRAM, limit)

    status =  __mkl_int_to_str(mkl_status, __variables['output'])
    return status


# Conditional Numerical Reproducibility

# Named Constants for CNR Control
# https://software.intel.com/en-us/mkl-developer-reference-c-named-constants-for-cnr-control
__mkl_cbwr_const = {
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


def cbwr_set(branch=None):
    """
    Configures the CNR mode of Intel MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-set
    """
    __variables = {
        'input': __mkl_cbwr_const,
        'output': {
            mkl.MKL_CBWR_SUCCESS: 'success',
            mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
            mkl.MKL_CBWR_ERR_UNSUPPORTED_BRANCH: 'err_unsupported_branch',
            mkl.MKL_CBWR_ERR_MODE_CHANGE_FAILURE: 'err_mode_change_failure',
        },
    }
    mkl_branch = __str_or_enum_to_mkl_int(branch, __variables['input'])

    mkl_status = mkl.mkl_cbwr_set(mkl_branch)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


def cbwr_get(cnr_const=None):
    """
    Returns the current CNR settings.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get
    """
    __variables = {
        'input': {
            'branch': mkl.MKL_CBWR_BRANCH,
            'all': mkl.MKL_CBWR_ALL,
        },
        'output': {
            mkl.MKL_CBWR_SUCCESS: 'success',
            mkl.MKL_CBWR_BRANCH_OFF: 'branch_off',
            mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
        },
    }
    __variables['output'].update({value: key for key, value in __mkl_cbwr_const.items()})
    mkl_cnr_const = __str_or_enum_to_mkl_int(cnr_const, __variables['input'])

    mkl_status = mkl.mkl_cbwr_get(mkl_cnr_const)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


def cbwr_get_auto_branch():
    """
    Automatically detects the CNR code branch for your platform.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get-auto-branch
    """
    __variables = {
        'input': None,
        'output': {},
    }
    __variables['output'].update({value: key for key, value in __mkl_cbwr_const.items()})

    mkl_status = mkl.mkl_cbwr_get_auto_branch()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


# Miscellaneous
def enable_instructions(isa=None):
    """
    Enables dispatching for new Intel architectures or restricts the set of Intel instruction sets available for dispatching.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-enable-instructions
    """
    __variables = {
        'input': {
            'avx512_mic_e1': mkl.MKL_ENABLE_AVX512_MIC_E1,
            'avx512': mkl.MKL_ENABLE_AVX512,
            'avx512_mic': mkl.MKL_ENABLE_AVX512_MIC,
            'avx2': mkl.MKL_ENABLE_AVX2,
            'avx': mkl.MKL_ENABLE_AVX,
            'sse4_2': mkl.MKL_ENABLE_SSE4_2,
        },
        'output': {
            0: 'error',
            1: 'success',
        },
    }
    mkl_isa = __str_or_enum_to_mkl_int(isa, __variables['input'])

    mkl_status = mkl.mkl_enable_instructions(mkl_isa)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


def set_env_mode():
    """
    Sets up the mode that ignores environment settings specific to Intel MKL. See mkl_set_env_mode(1).
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-env-mode
    """
    __variables = {
        'input': None,
        'output': {
            0: 'default',
            1: 'ignore',
        },
    }
    mkl_status = mkl.mkl_set_env_mode(1)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


def get_env_mode():
    """
    Query the current environment mode. See mkl_set_env_mode(0).
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-env-mode
    """
    __variables = {
        'input': None,
        'output': {
            0: 'default',
            1: 'ignore',
        },
    }
    mkl_status = mkl.mkl_set_env_mode(0)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


def verbose(enable):
    """
    Enables or disables Intel MKL Verbose mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-verbose
    """
    assert(type(enable) is bool)
    return bool(mkl.mkl_verbose(enable))


def set_mpi(vendor, custom_library_name):
    """
    Sets the implementation of the message-passing interface to be used by Intel MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-mpi
    """
    __variables = {
        'input': {
            'custom': mkl.MKL_BLACS_CUSTOM,
            'msmpi': mkl.MKL_BLACS_MSMPI,
            'intelmpi': mkl.MKL_BLACS_INTELMPI,
            #'mpich': mkl.MKL_BLACS_MPICH,
        },
        'output': {
            0: 'success',
            -1: 'vendor_invalid',
            -2: 'custom_library_name_invalid',
            -3: 'MPI library cannot be set at this point',
        },
    }
    mkl_vendor = __str_or_enum_to_mkl_int(vendor, __variables['input'])

    cdef bytes c_bytes = custom_library_name.encode()
    cdef char* c_string = c_bytes
    mkl_status = mkl.mkl_set_mpi(mkl_vendor, c_string)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


# VM Service Functions
__mkl_vml_mode = {
    'accuracy': {
        'ha': mkl.VML_HA,
        'la': mkl.VML_LA,
        'ep': mkl.VML_EP,
    },
    'ftzdaz': {
        'on': mkl.VML_FTZDAZ_ON,
        'off': mkl.VML_FTZDAZ_OFF,
    },
    'errmode': {
        'ignore': mkl.VML_ERRMODE_IGNORE,
        'errno': mkl.VML_ERRMODE_ERRNO,
        'stderr': mkl.VML_ERRMODE_STDERR,
        'except': mkl.VML_ERRMODE_EXCEPT,
        'callback': mkl.VML_ERRMODE_CALLBACK,
        'default': mkl.VML_ERRMODE_DEFAULT,
    },
}


def vml_set_mode(accuracy, ftzdaz, errmode):
    """
    Sets a new mode for VM functions according to the mode parameter and stores the previous VM mode to oldmode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlsetmode
    """
    __variables = {
        'input': __mkl_vml_mode,
        'output': {
            'accuracy': {},
            'ftzdaz': {},
            'errmode': {},
        },
    }
    __variables['output']['accuracy'].update({value: key for key, value in __mkl_vml_mode['accuracy'].items()})
    __variables['output']['ftzdaz'].update({value: key for key, value in __mkl_vml_mode['ftzdaz'].items()})
    __variables['output']['errmode'].update({value: key for key, value in __mkl_vml_mode['errmode'].items()})
    mkl_accuracy = __str_or_enum_to_mkl_int(accuracy, __variables['input']['accuracy'])
    mkl_ftzdaz = __str_or_enum_to_mkl_int(ftzdaz, __variables['input']['ftzdaz'])
    mkl_errmode = __str_or_enum_to_mkl_int(errmode, __variables['input']['errmode'])

    status = mkl.vmlSetMode(mkl_accuracy | mkl_ftzdaz | mkl_errmode)

    accuracy = __mkl_int_to_str(status & mkl.VML_ACCURACY_MASK, __variables['output']['accuracy'])
    ftzdaz = __mkl_int_to_str(status & mkl.VML_FTZDAZ_MASK, __variables['output']['ftzdaz'])
    errmode = __mkl_int_to_str(status & mkl.VML_ERRMODE_MASK, __variables['output']['errmode'])
    return accuracy, ftzdaz, errmode


def vml_get_mode():
    """
    Gets the VM mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgetmode
    """
    __variables = {
        'input': None,
        'output': {
            'accuracy': {},
            'ftzdaz': {},
            'errmode': {},
        },
    }
    __variables['output']['accuracy'].update({value: key for key, value in __mkl_vml_mode['accuracy'].items()})
    __variables['output']['ftzdaz'].update({value: key for key, value in __mkl_vml_mode['ftzdaz'].items()})
    __variables['output']['errmode'].update({value: key for key, value in __mkl_vml_mode['errmode'].items()})

    status = mkl.vmlGetMode()

    accuracy = __mkl_int_to_str(status & mkl.VML_ACCURACY_MASK, __variables['output']['accuracy'])
    ftzdaz = __mkl_int_to_str(status & mkl.VML_FTZDAZ_MASK, __variables['output']['ftzdaz'])
    errmode = __mkl_int_to_str(status & mkl.VML_ERRMODE_MASK, __variables['output']['errmode'])
    return accuracy, ftzdaz, errmode


__mkl_vml_status = {
    'ok': mkl.VML_STATUS_OK,
    'accuracywarning': mkl.VML_STATUS_ACCURACYWARNING,
    'badsize': mkl.VML_STATUS_BADSIZE,
    'badmem': mkl.VML_STATUS_BADMEM,
    'errdom': mkl.VML_STATUS_ERRDOM,
    'sing': mkl.VML_STATUS_SING,
    'overflow': mkl.VML_STATUS_OVERFLOW,
    'underflow': mkl.VML_STATUS_UNDERFLOW,
}


def vml_set_err_status(status):
    """
    Sets the new VM Error Status according to err and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlseterrstatus
    """
    __variables = {
        'input': __mkl_vml_status,
        'output': {},
    }
    __variables['output'].update({value: key for key, value in __mkl_vml_status.items()})
    mkl_status_in = __str_or_enum_to_mkl_int(status, __variables['input'])

    mkl_status_out = mkl.vmlSetErrStatus(mkl_status_in)

    status = __mkl_int_to_str(mkl_status_out, __variables['output'])
    return status


def vml_get_err_status():
    """
    Gets the VM Error Status.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgeterrstatus
    """
    __variables = {
        'input': None,
        'output': {},
    }
    __variables['output'].update({value: key for key, value in __mkl_vml_status.items()})

    mkl_status = mkl.vmlGetErrStatus()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


def vml_clear_err_status():
    """
    Sets the VM Error Status to VML_STATUS_OK and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlclearerrstatus
    """
    __variables = {
        'input': None,
        'output': {},
    }
    __variables['output'].update({value: key for key, value in __mkl_vml_status.items()})

    mkl_status = mkl.vmlClearErrStatus()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status
