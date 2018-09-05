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


ctypedef long long MKL_INT64
ctypedef unsigned long long MKL_UINT64
ctypedef int MKL_INT


cdef extern from "mkl.h":
    # MKL Function Domains Constants
    int MKL_DOMAIN_BLAS
    int MKL_DOMAIN_FFT
    int MKL_DOMAIN_VML
    int MKL_DOMAIN_PARDISO
    int MKL_DOMAIN_ALL

    # MKL Peak Memory Usage Constants
    int MKL_PEAK_MEM_ENABLE
    int MKL_PEAK_MEM_DISABLE
    int MKL_PEAK_MEM
    int MKL_PEAK_MEM_RESET
    int MKL_MEM_MCDRAM

    # CNR Control Constants
    int MKL_CBWR_AUTO
    int MKL_CBWR_COMPATIBLE
    int MKL_CBWR_SSE2
    int MKL_CBWR_SSE3
    int MKL_CBWR_SSSE3
    int MKL_CBWR_SSE4_1
    int MKL_CBWR_SSE4_2
    int MKL_CBWR_AVX
    int MKL_CBWR_AVX2
    int MKL_CBWR_AVX512_MIC
    int MKL_CBWR_AVX512
    int MKL_CBWR_BRANCH
    int MKL_CBWR_ALL
    int MKL_CBWR_SUCCESS
    int MKL_CBWR_BRANCH_OFF
    int MKL_CBWR_ERR_INVALID_INPUT
    int MKL_CBWR_ERR_UNSUPPORTED_BRANCH
    int MKL_CBWR_ERR_MODE_CHANGE_FAILURE

    # ISA Constants
    int MKL_ENABLE_AVX512_MIC_E1
    int MKL_ENABLE_AVX512
    int MKL_ENABLE_AVX512_MIC
    int MKL_ENABLE_AVX2
    int MKL_ENABLE_AVX
    int MKL_ENABLE_SSE4_2

    # MPI Implementation Constants
    int MKL_BLACS_CUSTOM
    int MKL_BLACS_MSMPI
    int MKL_BLACS_INTELMPI
    int MKL_BLACS_MPICH2

    # VML Constants
    int VML_HA
    int VML_LA
    int VML_EP
    int VML_FTZDAZ_ON
    int VML_FTZDAZ_OFF
    int VML_ERRMODE_IGNORE
    int VML_ERRMODE_ERRNO
    int VML_ERRMODE_STDERR
    int VML_ERRMODE_EXCEPT
    int VML_ERRMODE_CALLBACK
    int VML_ERRMODE_DEFAULT
    int VML_STATUS_OK
    int VML_STATUS_ACCURACYWARNING
    int VML_STATUS_BADSIZE
    int VML_STATUS_BADMEM
    int VML_STATUS_ERRDOM
    int VML_STATUS_SING
    int VML_STATUS_OVERFLOW
    int VML_STATUS_UNDERFLOW
    int VML_ACCURACY_MASK
    int VML_FTZDAZ_MASK
    int VML_ERRMODE_MASK

    ctypedef struct MKLVersion:
        int MajorVersion
        int MinorVersion
        int UpdateVersion
        char* ProductStatus
        char* Build
        char* Processor
        char* Platform

    # MKL support functions
    void mkl_get_version(MKLVersion* pv)
    void mkl_get_version_string(char* buf, int len)

    # Threading
    void mkl_set_num_threads(int nth)
    int mkl_domain_set_num_threads(int nt, int domain)
    int mkl_set_num_threads_local(int nth)
    void mkl_set_dynamic(int flag)
    int mkl_get_max_threads()
    int mkl_domain_get_max_threads(int domain)
    int mkl_get_dynamic()

    # Timing
    float second()
    double dsecnd()
    void mkl_get_cpu_clocks(MKL_UINT64* clocks)
    double mkl_get_cpu_frequency()
    double mkl_get_max_cpu_frequency()
    double mkl_get_clocks_frequency()

    # Memory
    void mkl_free_buffers()
    void mkl_thread_free_buffers()
    int mkl_disable_fast_mm()
    MKL_INT64 mkl_mem_stat(int* buf)
    MKL_INT64 mkl_peak_mem_usage(int mode)
    int mkl_set_memory_limit(int mem_type, size_t limit)

    # Conditional Numerical Reproducibility
    int mkl_cbwr_set(int settings)
    int mkl_cbwr_get(int option)
    int mkl_cbwr_get_auto_branch()

    # Miscellaneous
    int mkl_enable_instructions(int isa)
    int mkl_set_env_mode(int mode)
    int mkl_verbose(int enable)
    int mkl_set_mpi(int vendor, const char* custom_library_name)

    # VM Service Functions
    unsigned int vmlSetMode(unsigned int mode)
    unsigned int vmlGetMode()
    int vmlSetErrStatus(const MKL_INT status)
    int vmlGetErrStatus()
    int vmlClearErrStatus()


cdef inline __mkl_str_to_int(variable, possible_variables_dict):
    assert(variable is not None)
    assert(possible_variables_dict is not None)

    variable_type = type(variable)

    if variable_type is str:
        assert(variable in possible_variables_dict.keys()), 'Variable: <' + str(variable) + '> not in ' + str(possible_variables_dict)
        mkl_variable = possible_variables_dict[variable]

    return mkl_variable


cdef inline __mkl_int_to_str(mkl_int_variable, possible_variables_dict):
    assert(mkl_int_variable is not None)
    assert(type(mkl_int_variable) is int)
    assert(possible_variables_dict is not None)
    assert(mkl_int_variable in possible_variables_dict.keys()), 'Variable: <' + str(mkl_int_variable) + '> not in ' + str(possible_variables_dict)

    return possible_variables_dict[mkl_int_variable]


# Version Information
cdef inline __get_version():
    """
    Returns the Intel MKL version.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version
    """
    cdef MKLVersion c_mkl_version
    mkl_get_version(&c_mkl_version)
    return c_mkl_version


cdef inline __get_version_string():
    """
    Returns the Intel MKL version in a character string.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version-string
    """
    cdef int c_string_len = 198
    cdef char[198] c_string
    mkl_get_version_string(c_string, c_string_len)
    return c_string.decode()


# Threading
cdef inline __set_num_threads(num_threads):
    """
    Specifies the number of OpenMP* threads to use.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads
    """
    assert(type(num_threads) is int)
    assert(num_threads > 0)

    prev_num_threads = __get_max_threads()
    assert(type(prev_num_threads) is int)
    assert(prev_num_threads > 0)

    mkl_set_num_threads(num_threads)

    return prev_num_threads


cdef inline __domain_set_num_threads(num_threads, domain):
    """
    Specifies the number of OpenMP* threads for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-set-num-threads
    """
    __variables = {
        'input': {
            'blas': MKL_DOMAIN_BLAS,
            'fft': MKL_DOMAIN_FFT,
            'vml': MKL_DOMAIN_VML,
            'pardiso': MKL_DOMAIN_PARDISO,
            'all': MKL_DOMAIN_ALL,
        },
        'output': {
            0: 'error',
            1: 'success',
        },
    }
    assert(type(num_threads) is int)
    assert(num_threads >= 0)
    mkl_domain = __mkl_str_to_int(domain, __variables['input'])

    mkl_status = mkl_domain_set_num_threads(num_threads, mkl_domain)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef inline __set_num_threads_local(num_threads):
    """
    Specifies the number of OpenMP* threads for all Intel MKL functions on the current execution thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads-local
    """
    assert(type(num_threads) is int)
    assert(num_threads >= 0)
    status = mkl_set_num_threads_local(num_threads)

    assert(status >= 0)
    if (status == 0):
        status = 'global_num_threads'
    return status


cdef inline __set_dynamic(enable):
    """
    Enables Intel MKL to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-dynamic
    """
    assert(type(enable) is bool)
    if enable:
        enable = 1
    else:
        enable = 0

    mkl_set_dynamic(enable)

    return __get_max_threads()


cdef inline __get_max_threads():
    """
    Gets the number of OpenMP* threads targeted for parallelism.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-threads
    """
    num_threads = mkl_get_max_threads()

    assert(type(num_threads) is int)
    assert(num_threads >= 1)
    return num_threads


cdef inline __domain_get_max_threads(domain='all'):
    """
    Gets the number of OpenMP* threads targeted for parallelism for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-get-max-threads
    """
    __variables = {
        'input': {
            'blas': MKL_DOMAIN_BLAS,
            'fft': MKL_DOMAIN_FFT,
            'vml': MKL_DOMAIN_VML,
            'pardiso': MKL_DOMAIN_PARDISO,
            'all': MKL_DOMAIN_ALL,
        },
        'output': None,
    }
    mkl_domain = __mkl_str_to_int(domain, __variables['input'])

    num_threads = mkl_domain_get_max_threads(mkl_domain)

    assert(type(num_threads) is int)
    assert(num_threads >= 1)
    return num_threads


cdef inline __get_dynamic():
    """
    Determines whether Intel MKL is enabled to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-dynamic
    """
    dynamic_enabled = mkl_get_dynamic()

    assert((dynamic_enabled == 0) or (dynamic_enabled == 1))
    return mkl_get_dynamic()


# Timing
cdef inline __second():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return second()


cdef inline __dsecnd():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return dsecnd()


cdef inline __get_cpu_clocks():
    """
    Returns elapsed CPU clocks.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-clocks
    """
    cdef MKL_UINT64 clocks
    mkl_get_cpu_clocks(&clocks)
    return clocks


cdef inline __get_cpu_frequency():
    """
    Returns the current CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-frequency
    """
    return mkl_get_cpu_frequency()


cdef inline __get_max_cpu_frequency():
    """
    Returns the maximum CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-cpu-frequency
    """
    return mkl_get_max_cpu_frequency()


cdef inline __get_clocks_frequency():
    """
    Returns the frequency value in GHz based on constant-rate Time Stamp Counter.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-clocks-frequency
    """
    return mkl_get_clocks_frequency()


# Memory Management. See the Intel MKL Developer Guide for more memory usage information.
cdef inline __free_buffers():
    """
    Frees unused memory allocated by the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-free-buffers
    """
    mkl_free_buffers()
    return


cdef inline __thread_free_buffers():
    """
    Frees unused memory allocated by the Intel MKL Memory Allocator in the current thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-thread-free-buffers
    """
    mkl_thread_free_buffers()
    return


cdef inline __disable_fast_mm():
    """
    Turns off the Intel MKL Memory Allocator for Intel MKL functions to directly use the system malloc/free functions.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-disable-fast-mm
    """
    return mkl_disable_fast_mm()


cdef inline __mem_stat():
    """
    Reports the status of the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-mem-stat
    """
    cdef int AllocatedBuffers
    cdef MKL_INT64 AllocatedBytes
    AllocatedBytes = mkl_mem_stat(&AllocatedBuffers)
    return AllocatedBytes, AllocatedBuffers


cdef inline __peak_mem_usage(mem_const):
    """
    Reports the peak memory allocated by the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-peak-mem-usage
    """
    __variables = {
        'input': {
            'enable': MKL_PEAK_MEM_ENABLE,
            'disable': MKL_PEAK_MEM_DISABLE,
            'peak_mem': MKL_PEAK_MEM,
            'peak_mem_reset': MKL_PEAK_MEM_RESET,
        },
        'output': None,
    }
    mkl_mem_const = __mkl_str_to_int(mem_const, __variables['input'])

    memory_allocator = mkl_peak_mem_usage(mkl_mem_const)

    assert(type(memory_allocator) is int)
    assert(memory_allocator >= -1)
    if memory_allocator == -1:
        memory_allocator = 'error'
    return memory_allocator


cdef inline __set_memory_limit(limit):
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

    mkl_status = mkl_set_memory_limit(MKL_MEM_MCDRAM, limit)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


# Conditional Numerical Reproducibility
cdef inline __cbwr_set(branch=None):
    """
    Configures the CNR mode of Intel MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-set
    """
    __variables = {
        'input': {
            'auto': MKL_CBWR_AUTO,
            'compatible': MKL_CBWR_COMPATIBLE,
            'sse2': MKL_CBWR_SSE2,
            'sse3': MKL_CBWR_SSE3,
            'ssse3': MKL_CBWR_SSSE3,
            'sse4_1': MKL_CBWR_SSE4_1,
            'sse4_2': MKL_CBWR_SSE4_2,
            'avx': MKL_CBWR_AVX,
            'avx2': MKL_CBWR_AVX2,
            'avx512_mic': MKL_CBWR_AVX512_MIC,
            'avx512': MKL_CBWR_AVX512,
        },
        'output': {
            MKL_CBWR_SUCCESS: 'success',
            MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
            MKL_CBWR_ERR_UNSUPPORTED_BRANCH: 'err_unsupported_branch',
            MKL_CBWR_ERR_MODE_CHANGE_FAILURE: 'err_mode_change_failure',
        },
    }
    mkl_branch = __mkl_str_to_int(branch, __variables['input'])

    mkl_status = mkl_cbwr_set(mkl_branch)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef inline __cbwr_get(cnr_const=None):
    """
    Returns the current CNR settings.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get
    """
    __variables = {
        'input': {
            'branch': MKL_CBWR_BRANCH,
            'all': MKL_CBWR_ALL,
        },
        'output': {
            MKL_CBWR_AUTO: 'auto',
            MKL_CBWR_COMPATIBLE: 'compatible',
            MKL_CBWR_SSE2: 'sse2',
            MKL_CBWR_SSE3: 'sse3',
            MKL_CBWR_SSSE3: 'ssse3',
            MKL_CBWR_SSE4_1: 'sse4_1',
            MKL_CBWR_SSE4_2: 'sse4_2',
            MKL_CBWR_AVX: 'avx',
            MKL_CBWR_AVX2: 'avx2',
            MKL_CBWR_AVX512_MIC: 'avx512_mic',
            MKL_CBWR_AVX512: 'avx512',
            MKL_CBWR_SUCCESS: 'success',
            MKL_CBWR_BRANCH_OFF: 'branch_off',
            MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
        },
    }
    mkl_cnr_const = __mkl_str_to_int(cnr_const, __variables['input'])

    mkl_status = mkl_cbwr_get(mkl_cnr_const)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef inline __cbwr_get_auto_branch():
    """
    Automatically detects the CNR code branch for your platform.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get-auto-branch
    """
    __variables = {
        'input': None,
        'output': {
            MKL_CBWR_AUTO: 'auto',
            MKL_CBWR_COMPATIBLE: 'compatible',
            MKL_CBWR_SSE2: 'sse2',
            MKL_CBWR_SSE3: 'sse3',
            MKL_CBWR_SSSE3: 'ssse3',
            MKL_CBWR_SSE4_1: 'sse4_1',
            MKL_CBWR_SSE4_2: 'sse4_2',
            MKL_CBWR_AVX: 'avx',
            MKL_CBWR_AVX2: 'avx2',
            MKL_CBWR_AVX512_MIC: 'avx512_mic',
            MKL_CBWR_AVX512: 'avx512',
        },
    }

    mkl_status = mkl_cbwr_get_auto_branch()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


# Miscellaneous
cdef inline __enable_instructions(isa=None):
    """
    Enables dispatching for new Intel architectures or restricts the set of Intel instruction sets available for dispatching.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-enable-instructions
    """
    __variables = {
        'input': {
            'avx512_mic_e1': MKL_ENABLE_AVX512_MIC_E1,
            'avx512': MKL_ENABLE_AVX512,
            'avx512_mic': MKL_ENABLE_AVX512_MIC,
            'avx2': MKL_ENABLE_AVX2,
            'avx': MKL_ENABLE_AVX,
            'sse4_2': MKL_ENABLE_SSE4_2,
        },
        'output': {
            0: 'error',
            1: 'success',
        },
    }
    mkl_isa = __mkl_str_to_int(isa, __variables['input'])

    mkl_status = mkl_enable_instructions(mkl_isa)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef inline __set_env_mode():
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
    mkl_status = mkl_set_env_mode(1)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef inline __get_env_mode():
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
    mkl_status = mkl_set_env_mode(0)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef inline __verbose(enable):
    """
    Enables or disables Intel MKL Verbose mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-verbose
    """
    assert(type(enable) is bool)
    return bool(mkl_verbose(enable))


cdef inline __set_mpi(vendor, custom_library_name):
    """
    Sets the implementation of the message-passing interface to be used by Intel MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-mpi
    """
    __variables = {
        'input': {
            'custom': MKL_BLACS_CUSTOM,
            'msmpi': MKL_BLACS_MSMPI,
            'intelmpi': MKL_BLACS_INTELMPI,
            'mpich2': MKL_BLACS_MPICH2,
        },
        'output': {
            0: 'success',
            -1: 'vendor_invalid',
            -2: 'custom_library_name_invalid',
            -3: 'MPI library cannot be set at this point',
        },
    }
    mkl_vendor = __mkl_str_to_int(vendor, __variables['input'])

    cdef bytes c_bytes = custom_library_name.encode()
    cdef char* c_string = c_bytes
    mkl_status = mkl_set_mpi(mkl_vendor, c_string)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


# VM Service Functions
__mkl_vml_mode = {
    'accuracy': {
        'ha': VML_HA,
        'la': VML_LA,
        'ep': VML_EP,
    },
    'ftzdaz': {
        'on': VML_FTZDAZ_ON,
        'off': VML_FTZDAZ_OFF,
    },
    'errmode': {
        'ignore': VML_ERRMODE_IGNORE,
        'errno': VML_ERRMODE_ERRNO,
        'stderr': VML_ERRMODE_STDERR,
        'except': VML_ERRMODE_EXCEPT,
        'callback': VML_ERRMODE_CALLBACK,
        'default': VML_ERRMODE_DEFAULT,
    },
}


cdef inline __vml_set_mode(accuracy, ftzdaz, errmode):
    """
    Sets a new mode for VM functions according to the mode parameter and stores the previous VM mode to oldmode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlsetmode
    """
    __variables = {
        'input': {
            'accuracy': {
                'ha': VML_HA,
                'la': VML_LA,
                'ep': VML_EP,
            },
            'ftzdaz': {
                'on': VML_FTZDAZ_ON,
                'off': VML_FTZDAZ_OFF,
            },
            'errmode': {
                'ignore': VML_ERRMODE_IGNORE,
                'errno': VML_ERRMODE_ERRNO,
                'stderr': VML_ERRMODE_STDERR,
                'except': VML_ERRMODE_EXCEPT,
                'callback': VML_ERRMODE_CALLBACK,
                'default': VML_ERRMODE_DEFAULT,
            },
        },
        'output': {
            'accuracy': {
                VML_HA: 'ha',
                VML_LA: 'la',
                VML_EP: 'ep',
            },
            'ftzdaz': {
                VML_FTZDAZ_ON: 'on',
                VML_FTZDAZ_OFF: 'off',
            },
            'errmode': {
                VML_ERRMODE_IGNORE: 'ignore',
                VML_ERRMODE_ERRNO: 'errno',
                VML_ERRMODE_STDERR: 'stderr',
                VML_ERRMODE_EXCEPT: 'except',
                VML_ERRMODE_CALLBACK: 'callback',
                VML_ERRMODE_DEFAULT: 'default',
            },
        },
    }
    mkl_accuracy = __mkl_str_to_int(accuracy, __variables['input']['accuracy'])
    mkl_ftzdaz = __mkl_str_to_int(ftzdaz, __variables['input']['ftzdaz'])
    mkl_errmode = __mkl_str_to_int(errmode, __variables['input']['errmode'])

    status = vmlSetMode(mkl_accuracy | mkl_ftzdaz | mkl_errmode)

    accuracy = __mkl_int_to_str(status & VML_ACCURACY_MASK, __variables['output']['accuracy'])
    ftzdaz = __mkl_int_to_str(status & VML_FTZDAZ_MASK, __variables['output']['ftzdaz'])
    errmode = __mkl_int_to_str(status & VML_ERRMODE_MASK, __variables['output']['errmode'])
    return accuracy, ftzdaz, errmode


cdef inline __vml_get_mode():
    """
    Gets the VM mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgetmode
    """
    __variables = {
        'input': None,
        'output': {
            'accuracy': {
                VML_HA: 'ha',
                VML_LA: 'la',
                VML_EP: 'ep',
            },
            'ftzdaz': {
                VML_FTZDAZ_ON: 'on',
                VML_FTZDAZ_OFF: 'off',
            },
            'errmode': {
                VML_ERRMODE_IGNORE: 'ignore',
                VML_ERRMODE_ERRNO: 'errno',
                VML_ERRMODE_STDERR: 'stderr',
                VML_ERRMODE_EXCEPT: 'except',
                VML_ERRMODE_CALLBACK: 'callback',
                VML_ERRMODE_DEFAULT: 'default',
            },
        },
    }

    status = vmlGetMode()

    accuracy = __mkl_int_to_str(status & VML_ACCURACY_MASK, __variables['output']['accuracy'])
    ftzdaz = __mkl_int_to_str(status & VML_FTZDAZ_MASK, __variables['output']['ftzdaz'])
    errmode = __mkl_int_to_str(status & VML_ERRMODE_MASK, __variables['output']['errmode'])
    return accuracy, ftzdaz, errmode


__mkl_vml_status = {
    'ok': VML_STATUS_OK,
    'accuracywarning': VML_STATUS_ACCURACYWARNING,
    'badsize': VML_STATUS_BADSIZE,
    'badmem': VML_STATUS_BADMEM,
    'errdom': VML_STATUS_ERRDOM,
    'sing': VML_STATUS_SING,
    'overflow': VML_STATUS_OVERFLOW,
    'underflow': VML_STATUS_UNDERFLOW,
}


cdef inline __vml_set_err_status(status):
    """
    Sets the new VM Error Status according to err and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlseterrstatus
    """
    __variables = {
        'input': {
            'ok': VML_STATUS_OK,
            'accuracywarning': VML_STATUS_ACCURACYWARNING,
            'badsize': VML_STATUS_BADSIZE,
            'badmem': VML_STATUS_BADMEM,
            'errdom': VML_STATUS_ERRDOM,
            'sing': VML_STATUS_SING,
            'overflow': VML_STATUS_OVERFLOW,
            'underflow': VML_STATUS_UNDERFLOW,
        },
        'output': {
            VML_STATUS_OK: 'ok',
            VML_STATUS_ACCURACYWARNING: 'accuracywarning',
            VML_STATUS_BADSIZE: 'badsize',
            VML_STATUS_BADMEM: 'badmem',
            VML_STATUS_ERRDOM: 'errdom',
            VML_STATUS_SING: 'sing',
            VML_STATUS_OVERFLOW: 'overflow',
            VML_STATUS_UNDERFLOW: 'underflow',
        },
    }
    mkl_status_in = __mkl_str_to_int(status, __variables['input'])

    mkl_status_out = vmlSetErrStatus(mkl_status_in)

    status = __mkl_int_to_str(mkl_status_out, __variables['output'])
    return status


cdef inline __vml_get_err_status():
    """
    Gets the VM Error Status.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgeterrstatus
    """
    __variables = {
        'input': None,
        'output': {
            VML_STATUS_OK: 'ok',
            VML_STATUS_ACCURACYWARNING: 'accuracywarning',
            VML_STATUS_BADSIZE: 'badsize',
            VML_STATUS_BADMEM: 'badmem',
            VML_STATUS_ERRDOM: 'errdom',
            VML_STATUS_SING: 'sing',
            VML_STATUS_OVERFLOW: 'overflow',
            VML_STATUS_UNDERFLOW: 'underflow',
        },
    }

    mkl_status = vmlGetErrStatus()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef inline __vml_clear_err_status():
    """
    Sets the VM Error Status to VML_STATUS_OK and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlclearerrstatus
    """
    __variables = {
        'input': None,
        'output': {
            VML_STATUS_OK: 'ok',
            VML_STATUS_ACCURACYWARNING: 'accuracywarning',
            VML_STATUS_BADSIZE: 'badsize',
            VML_STATUS_BADMEM: 'badmem',
            VML_STATUS_ERRDOM: 'errdom',
            VML_STATUS_SING: 'sing',
            VML_STATUS_OVERFLOW: 'overflow',
            VML_STATUS_UNDERFLOW: 'underflow',
        },
    }

    mkl_status = vmlClearErrStatus()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status
