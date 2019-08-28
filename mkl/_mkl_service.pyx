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


import six
import warnings
cimport _mkl_service as mkl


ctypedef struct MemStatData:
    #  DataAllocatedBytes, AllocatedBuffers
    mkl.MKL_INT64 allocated_bytes
    int allocated_buffers


# Version Information
cpdef get_version():
    """
    Returns the Intel(R) MKL version as a dictionary.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version
    """
    return __get_version()


cpdef get_version_string():
    """
    Returns the Intel(R) MKL version as a string.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version-string
    """
    return __get_version_string()


# Threading
cpdef set_num_threads(num_threads):
    """
    Specifies the number of OpenMP* threads to use.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads
    """
    cdef int c_num_threads = __python_obj_to_int(num_threads, 'set_num_threads')
    __check_positive_num_threads(c_num_threads, 'set_num_threads')

    return __set_num_threads(c_num_threads)


cdef int __warn_and_fallback_on_default_domain(domain):
    warnings.warn("domain={} is expected to be an integer, a string ('blas', 'fft', "
                  "'vml', 'pardiso', 'all'). "
		  "Using domain='all' instead.".format(domain))
    return mkl.MKL_DOMAIN_ALL


cdef int __domain_to_mkl_domain(domain):
    cdef int c_mkl_domain = mkl.MKL_DOMAIN_ALL
    _mapping = {
            'blas': mkl.MKL_DOMAIN_BLAS,
            'fft': mkl.MKL_DOMAIN_FFT,
            'vml': mkl.MKL_DOMAIN_VML,
            'pardiso': mkl.MKL_DOMAIN_PARDISO,
            'all': mkl.MKL_DOMAIN_ALL }

    if isinstance(domain, six.integer_types):
        c_mkl_domain = domain
    elif isinstance(domain, six.string_types):
        if domain not in _mapping:
            c_mkl_domain = __warn_and_fallback_on_default_domain(domain)
        else:
            c_mkl_domain = _mapping[domain]
    else:
        c_mkl_domain = __warn_and_fallback_on_default_domain(domain)

    return c_mkl_domain


cpdef domain_set_num_threads(num_threads, domain='all'):
    """
    Specifies the number of OpenMP* threads for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-set-num-threads
    """
    cdef c_num_threads = __python_obj_to_int(num_threads, 'domain_set_num_threads')
    __check_positive_num_threads(c_num_threads, 'domain_set_num_threads')

    cdef int c_mkl_domain = __domain_to_mkl_domain(domain)
    cdef int c_mkl_status = __domain_set_num_threads(c_num_threads, c_mkl_domain)

    return __mkl_status_to_string(c_mkl_status)


cpdef set_num_threads_local(num_threads):
    """
    Specifies the number of OpenMP* threads for all Intel(R) MKL functions on the current execution thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads-local
    """
    cdef c_num_threads = 0
    if isinstance(num_threads, six.string_types):
        if num_threads is not 'global_num_threads':
            raise ValueError("The argument of set_num_threads_local is expected "
                             "to be a non-negative integer or a string 'global_num_threads'")
    else:
        c_num_threads = __python_obj_to_int(num_threads, 'set_num_threads_local')

    __check_non_negative_num_threads(c_num_threads, 'set_num_threads_local')

    cdef c_prev_num_threads = __set_num_threads_local(c_num_threads)
    if (c_prev_num_threads == 0):
        ret_value = 'global_num_threads'
    else:
        ret_value = c_prev_num_threads

    return ret_value


cpdef set_dynamic(enable):
    """
    Enables Intel(R) MKL to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-dynamic
    """
    cdef int c_enable = int(enable)
    # return the number of threads used
    return __set_dynamic(c_enable)


cpdef get_max_threads():
    """
    Gets the number of OpenMP* threads targeted for parallelism.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-threads
    """
    return __get_max_threads()


cpdef domain_get_max_threads(domain='all'):
    """
    Gets the number of OpenMP* threads targeted for parallelism for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-get-max-threads
    """
    cdef int c_mkl_domain = __domain_to_mkl_domain(domain)
    return __domain_get_max_threads(c_mkl_domain)


cpdef get_dynamic():
    """
    Determines whether Intel(R) MKL is enabled to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-dynamic
    """
    return bool(__get_dynamic())


# Timing
cpdef second():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return __second()


cpdef dsecnd():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return __dsecnd()


cpdef get_cpu_clocks():
    """
    Returns elapsed CPU clocks.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-clocks
    """
    return __get_cpu_clocks()


cpdef get_cpu_frequency():
    """
    Returns the current CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-frequency
    """
    return __get_cpu_frequency()


cpdef get_max_cpu_frequency():
    """
    Returns the maximum CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-cpu-frequency
    """
    return __get_max_cpu_frequency()


cpdef get_clocks_frequency():
    """
    Returns the frequency value in GHz based on constant-rate Time Stamp Counter.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-clocks-frequency
    """
    return __get_clocks_frequency()


# Memory Management. See the Intel(R) MKL Developer Guide for more memory usage information.
cpdef free_buffers():
    """
    Frees unused memory allocated by the Intel(R) MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-free-buffers
    """
    __free_buffers()


cpdef thread_free_buffers():
    """
    Frees unused memory allocated by the Intel(R) MKL Memory Allocator in the current thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-thread-free-buffers
    """
    __thread_free_buffers()


cpdef disable_fast_mm():
    """
    Turns off the Intel(R) MKL Memory Allocator for Intel(R) MKL functions to directly use the system malloc/free functions.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-disable-fast-mm
    """
    return __disable_fast_mm()


cpdef mem_stat():
    """
    Reports the status of the Intel(R) MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-mem-stat
    """
    return __mem_stat()


cpdef peak_mem_usage(mem_const):
    """
    Reports the peak memory allocated by the Intel(R) MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-peak-mem-usage
    """
    return __peak_mem_usage(mem_const)


cpdef set_memory_limit(limit):
    """
    On Linux, sets the limit of memory that Intel(R) MKL can allocate for a specified type of memory.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-memory-limit
    """
    return __set_memory_limit(limit)


# Conditional Numerical Reproducibility
cpdef cbwr_set(branch=None):
    """
    Configures the CNR mode of Intel(R) MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-set
    """
    return __cbwr_set(branch)


cpdef cbwr_get(cnr_const='all'):
    """
    Returns the current CNR settings.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get
    """
    return __cbwr_get(cnr_const)


cpdef cbwr_get_auto_branch():
    """
    Automatically detects the CNR code branch for your platform.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get-auto-branch
    """
    return __cbwr_get_auto_branch()


# Miscellaneous
cpdef enable_instructions(isa=None):
    """
    Enables dispatching for new Intel architectures or restricts the set of Intel instruction sets available for dispatching.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-enable-instructions
    """
    return __enable_instructions(isa)


cpdef set_env_mode():
    """
    Sets up the mode that ignores environment settings specific to Intel(R) MKL. See mkl_set_env_mode(1).
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-env-mode
    """
    return __set_env_mode()


cpdef get_env_mode():
    """
    Query the current environment mode. See mkl_set_env_mode(0).
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-env-mode
    """
    return __get_env_mode()


cpdef verbose(enable):
    """
    Enables or disables Intel(R) MKL Verbose mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-verbose
    """
    cdef int c_enable = int(enable)
    return bool(__verbose(c_enable))


cpdef set_mpi(vendor, custom_library_name=None):
    """
    Sets the implementation of the message-passing interface to be used by Intel(R) MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-mpi
    """
    return __set_mpi(vendor, custom_library_name)


# VM Service Functions
cpdef vml_set_mode(accuracy, ftzdaz, errmode):
    """
    Sets a new mode for VM functions according to the mode parameter and stores the previous VM mode to oldmode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlsetmode
    """
    return __vml_set_mode(accuracy, ftzdaz, errmode)


cpdef vml_get_mode():
    """
    Gets the VM mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgetmode
    """
    return __vml_get_mode()


cpdef vml_set_err_status(status):
    """
    Sets the new VM Error Status according to err and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlseterrstatus
    """
    return __vml_set_err_status(status)


cpdef vml_get_err_status():
    """
    Gets the VM Error Status.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgeterrstatus
    """
    return __vml_get_err_status()


cpdef vml_clear_err_status():
    """
    Sets the VM Error Status to VML_STATUS_OK and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlclearerrstatus
    """
    return __vml_clear_err_status()


cdef __mkl_status_to_string(int mkl_status):
    if mkl_status == 1:
        return 'success'
    else:
        return 'error'


cdef int __python_obj_to_int(obj, func_name):
    if not isinstance(obj, six.integer_types):
        raise ValueError("The argument of " + func_name + " is expected to be a positive integer")
    cdef c_int = obj
    return c_int


cdef void __check_positive_num_threads(int p, func_name):
    if p <= 0:
        warnings.warn("Non-positive argument of " + func_name +
                      " is being ignored, number of threads will not be changed")


cdef void __check_non_negative_num_threads(int p, func_name):
    if p < 0:
        warnings.warn("Non-positive argument of " + func_name +
                      " is being ignored, number of threads will not be changed")


cdef inline int __mkl_str_to_int(variable, possible_variables_dict):
    if variable is None:
        raise ValueError("Variable can not be None")
    if possible_variables_dict is None:
        raise RuntimeError("Dictionary mapping possible variable value to internal code is missing")
    if variable not in possible_variables_dict:
        raise ValueError('Variable: <' + str(variable) + '> not in ' +
                         str(possible_variables_dict.keys()))

    return possible_variables_dict[variable]


cdef  __mkl_int_to_str(int mkl_int_variable, possible_variables_dict):
    if possible_variables_dict is None:
        raise RuntimeError("Dictionary mapping possible internal code to output string is missing")

    if mkl_int_variable not in possible_variables_dict:
        raise ValueError('Variable: <' + str(mkl_int_variable) + '> not in ' +
                         str(possible_variables_dict.keys()))

    return possible_variables_dict[mkl_int_variable]


# Version Information
cdef inline mkl.MKLVersion __get_version():
    """
    Returns the Intel(R) MKL version.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version
    """
    cdef mkl.MKLVersion c_mkl_version
    mkl.mkl_get_version(&c_mkl_version)
    return c_mkl_version


cdef __get_version_string():
    """
    Returns the Intel(R) MKL version in a character string.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version-string
    """
    cdef int c_string_len = 198
    cdef char[198] c_string
    mkl.mkl_get_version_string(c_string, c_string_len)
    return c_string.decode()


# Threading
cdef inline int __set_num_threads(int num_threads):
    """
    Specifies the number of OpenMP* threads to use.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads
    """

    cdef int prev_num_threads = __get_max_threads()
    mkl.mkl_set_num_threads(num_threads)
    return prev_num_threads


cdef inline int __domain_set_num_threads(int c_num_threads, int mkl_domain):
    """
    Specifies the number of OpenMP* threads for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-set-num-threads
    """
    cdef int mkl_status = mkl.mkl_domain_set_num_threads(c_num_threads, mkl_domain)
    return mkl_status


cdef inline int __set_num_threads_local(int c_num_threads):
    """
    Specifies the number of OpenMP* threads for all Intel(R) MKL functions on the current execution thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads-local
    """

    cdef int c_mkl_status = mkl.mkl_set_num_threads_local(c_num_threads)
    return c_mkl_status


cdef inline int __set_dynamic(int c_enable):
    """
    Enables Intel(R) MKL to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-dynamic
    """

    mkl.mkl_set_dynamic(c_enable)
    return __get_max_threads()


cdef inline int __get_max_threads():
    """
    Gets the number of OpenMP* threads targeted for parallelism.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-threads
    """
    return mkl.mkl_get_max_threads()


cdef inline int __domain_get_max_threads(int c_mkl_domain):
    """
    Gets the number of OpenMP* threads targeted for parallelism for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-get-max-threads
    """
    cdef int c_num_threads = mkl.mkl_domain_get_max_threads(c_mkl_domain)

    return c_num_threads


cdef inline int __get_dynamic():
    """
    Determines whether Intel(R) MKL is enabled to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-dynamic
    """
    return mkl.mkl_get_dynamic()


# Timing
cdef inline float __second():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return mkl.second()


cdef inline double __dsecnd():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return mkl.dsecnd()


cdef inline mkl.MKL_UINT64 __get_cpu_clocks():
    """
    Returns elapsed CPU clocks.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-clocks
    """
    cdef mkl.MKL_UINT64 clocks
    mkl.mkl_get_cpu_clocks(&clocks)
    return clocks


cdef inline double __get_cpu_frequency():
    """
    Returns the current CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-frequency
    """
    return mkl.mkl_get_cpu_frequency()


cdef inline double __get_max_cpu_frequency():
    """
    Returns the maximum CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-cpu-frequency
    """
    return mkl.mkl_get_max_cpu_frequency()


cdef inline double __get_clocks_frequency():
    """
    Returns the frequency value in GHz based on constant-rate Time Stamp Counter.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-clocks-frequency
    """
    return mkl.mkl_get_clocks_frequency()


# Memory Management. See the Intel(R) MKL Developer Guide for more memory usage information.
cdef inline void __free_buffers():
    """
    Frees unused memory allocated by the Intel(R) MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-free-buffers
    """
    mkl.mkl_free_buffers()
    return


cdef inline void __thread_free_buffers():
    """
    Frees unused memory allocated by the Intel(R) MKL Memory Allocator in the current thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-thread-free-buffers
    """
    mkl.mkl_thread_free_buffers()
    return


cdef inline int __disable_fast_mm():
    """
    Turns off the Intel(R) MKL Memory Allocator for Intel(R) MKL functions to directly use the system malloc/free functions.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-disable-fast-mm
    """
    return mkl.mkl_disable_fast_mm()


cdef inline MemStatData __mem_stat():
    """
    Reports the status of the Intel(R) MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-mem-stat
    """
    cdef MemStatData mem_stat_data
    mem_stat_data.allocated_bytes = mkl.mkl_mem_stat(&mem_stat_data.allocated_buffers)
    return mem_stat_data


cdef object __peak_mem_usage(mem_const):
    """
    Reports the peak memory allocated by the Intel(R) MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-peak-mem-usage
    """
    __variables = {
        'input': {
            'enable': mkl.MKL_PEAK_MEM_ENABLE,
            'disable': mkl.MKL_PEAK_MEM_DISABLE,
            'peak_mem': mkl.MKL_PEAK_MEM,
            'peak_mem_reset': mkl.MKL_PEAK_MEM_RESET,
        }
    }
    cdef int c_mkl_mem_const = __mkl_str_to_int(mem_const, __variables['input'])

    cdef mkl.MKL_INT64 c_memory_allocator = mkl.mkl_peak_mem_usage(c_mkl_mem_const)

    if c_memory_allocator == -1:
        memory_allocator = 'error'
    else:
        memory_allocator = c_memory_allocator
    return memory_allocator


cdef inline object __set_memory_limit(limit):
    """
    On Linux, sets the limit of memory that Intel(R) MKL can allocate for a specified type of memory.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-memory-limit
    """
    cdef size_t c_limit = limit

    cdef int c_mkl_status = mkl.mkl_set_memory_limit(mkl.MKL_MEM_MCDRAM, c_limit)
    return __mkl_status_to_string(c_mkl_status)


# Conditional Numerical Reproducibility
cdef object __cbwr_set(branch=None):
    """
    Configures the CNR mode of Intel(R) MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-set
    """
    __variables = {
        'input': {
            'off': mkl.MKL_CBWR_OFF,
            'branch_off': mkl.MKL_CBWR_BRANCH_OFF,
            'auto': mkl.MKL_CBWR_AUTO,
            'compatible': mkl.MKL_CBWR_COMPATIBLE,
            'sse2': mkl.MKL_CBWR_SSE2,
            'ssse3': mkl.MKL_CBWR_SSSE3,
            'sse4_1': mkl.MKL_CBWR_SSE4_1,
            'sse4_2': mkl.MKL_CBWR_SSE4_2,
            'avx': mkl.MKL_CBWR_AVX,
            'avx2': mkl.MKL_CBWR_AVX2,
            'avx2,strict': mkl.MKL_CBWR_AVX2 | mkl.MKL_CBWR_STRICT,
            'avx512_mic': mkl.MKL_CBWR_AVX512_MIC,
            'avx512_mic,strict': mkl.MKL_CBWR_AVX512_MIC | mkl.MKL_CBWR_STRICT,
            'avx512': mkl.MKL_CBWR_AVX512,
            'avx512,strict': mkl.MKL_CBWR_AVX512 | mkl.MKL_CBWR_STRICT,
            'avx512_mic_e1': mkl.MKL_CBWR_AVX512_MIC_E1,
            'avx512_e1': mkl.MKL_CBWR_AVX512_E1,
            'avx512_e1,strict': mkl.MKL_CBWR_AVX512_E1 | mkl.MKL_CBWR_STRICT,
        },
        'output': {
            mkl.MKL_CBWR_SUCCESS: 'success',
            mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
            mkl.MKL_CBWR_ERR_UNSUPPORTED_BRANCH: 'err_unsupported_branch',
            mkl.MKL_CBWR_ERR_MODE_CHANGE_FAILURE: 'err_mode_change_failure',
        },
    }
    mkl_branch = __mkl_str_to_int(branch, __variables['input'])

    mkl_status = mkl.mkl_cbwr_set(mkl_branch)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef inline __cbwr_get(cnr_const=None):
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
            mkl.MKL_CBWR_BRANCH_OFF: 'branch_off',
            mkl.MKL_CBWR_AUTO: 'auto',
            mkl.MKL_CBWR_COMPATIBLE: 'compatible',
            mkl.MKL_CBWR_SSE2: 'sse2',
            mkl.MKL_CBWR_SSSE3: 'ssse3',
            mkl.MKL_CBWR_SSE4_1: 'sse4_1',
            mkl.MKL_CBWR_SSE4_2: 'sse4_2',
            mkl.MKL_CBWR_AVX: 'avx',
            mkl.MKL_CBWR_AVX2: 'avx2',
            mkl.MKL_CBWR_AVX2 | mkl.MKL_CBWR_STRICT: 'avx2,strict',
            mkl.MKL_CBWR_AVX512_MIC: 'avx512_mic',
            mkl.MKL_CBWR_AVX512_MIC | mkl.MKL_CBWR_STRICT: 'avx512_mic,strict',
            mkl.MKL_CBWR_AVX512: 'avx512',
            mkl.MKL_CBWR_AVX512 | mkl.MKL_CBWR_STRICT: 'avx512,strict',
            mkl.MKL_CBWR_AVX512_MIC_E1: 'avx512_mic_e1',
            mkl.MKL_CBWR_AVX512_E1: 'avx512_e1',
            mkl.MKL_CBWR_AVX512_E1 | mkl.MKL_CBWR_STRICT: 'avx512_e1,strict',
            mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
        },
    }
    mkl_cnr_const = __mkl_str_to_int(cnr_const, __variables['input'])

    mkl_status = mkl.mkl_cbwr_get(mkl_cnr_const)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef object __cbwr_get_auto_branch():
    """
    Automatically detects the CNR code branch for your platform.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get-auto-branch
    """
    __variables = {
        'output': {
            mkl.MKL_CBWR_BRANCH_OFF: 'branch_off',
            mkl.MKL_CBWR_AUTO: 'auto',
            mkl.MKL_CBWR_COMPATIBLE: 'compatible',
            mkl.MKL_CBWR_SSE2: 'sse2',
            mkl.MKL_CBWR_SSSE3: 'ssse3',
            mkl.MKL_CBWR_SSE4_1: 'sse4_1',
            mkl.MKL_CBWR_SSE4_2: 'sse4_2',
            mkl.MKL_CBWR_AVX: 'avx',
            mkl.MKL_CBWR_AVX2: 'avx2',
            mkl.MKL_CBWR_AVX2 | mkl.MKL_CBWR_STRICT: 'avx2,strict',
            mkl.MKL_CBWR_AVX512_MIC: 'avx512_mic',
            mkl.MKL_CBWR_AVX512_MIC | mkl.MKL_CBWR_STRICT: 'avx512_mic,strict',
            mkl.MKL_CBWR_AVX512: 'avx512',
            mkl.MKL_CBWR_AVX512 | mkl.MKL_CBWR_STRICT: 'avx512,strict',
            mkl.MKL_CBWR_AVX512_MIC_E1: 'avx512_mic_e1',
            mkl.MKL_CBWR_AVX512_E1: 'avx512_e1',
            mkl.MKL_CBWR_AVX512_E1 | mkl.MKL_CBWR_STRICT: 'avx512_e1,strict',
            mkl.MKL_CBWR_SUCCESS: 'success',
            mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
        },
    }

    mkl_status = mkl.mkl_cbwr_get_auto_branch()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


# Miscellaneous
cdef object __enable_instructions(isa=None):
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
    }
    cdef int c_mkl_isa = __mkl_str_to_int(isa, __variables['input'])

    cdef int c_mkl_status = mkl.mkl_enable_instructions(c_mkl_isa)
    
    return __mkl_status_to_string(c_mkl_status)


cdef object __set_env_mode():
    """
    Sets up the mode that ignores environment settings specific to Intel(R) MKL. See mkl_set_env_mode(1).
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-env-mode
    """
    __variables = {
        'input': None,
        'output': {
            0: 'default',
            1: 'ignore',
        },
    }
    cdef int c_mkl_status = mkl.mkl_set_env_mode(1)

    status = __mkl_int_to_str(c_mkl_status, __variables['output'])
    return status


cdef object __get_env_mode():
    """
    Query the current environment mode. See mkl_set_env_mode(0).
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-env-mode
    """
    __variables = {
        'output': {
            0: 'default',
            1: 'ignore',
        },
    }
    cdef int c_mkl_status = mkl.mkl_set_env_mode(0)

    status = __mkl_int_to_str(c_mkl_status, __variables['output'])
    return status


cdef inline int __verbose(int c_enable):
    """
    Enables or disables Intel(R) MKL Verbose mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-verbose
    """
    return mkl.mkl_verbose(c_enable)


cdef __set_mpi(vendor, custom_library_name=None):
    """
    Sets the implementation of the message-passing interface to be used by Intel(R) MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-mpi
    """
    __variables = {
        'input': {
            'custom': mkl.MKL_BLACS_CUSTOM,
            'msmpi': mkl.MKL_BLACS_MSMPI,
            'intelmpi': mkl.MKL_BLACS_INTELMPI,
            'mpich2': mkl.MKL_BLACS_MPICH2,
        },
        'output': {
            0: 'success',
            -1: 'vendor_invalid',
            -2: 'custom_library_name_invalid',
            -3: 'MPI library cannot be set at this point',
        },
    }
    if ((vendor is 'custom' or custom_library_name is not None) and
        (vendor is not 'custom' or custom_library_name is None)):
        raise ValueError("Selecting custom MPI for BLACS requires specifying "
                         "the custom library, and specifying custom library "
                         "necessitates selecting a custom MPI for BLACS library")
    mkl_vendor = __mkl_str_to_int(vendor, __variables['input'])

    cdef bytes c_bytes
    cdef char* c_string = ''
    if custom_library_name is not None:
        c_bytes = custom_library_name.encode()
        c_string = c_bytes
    mkl_status = mkl.mkl_set_mpi(mkl_vendor, c_string)

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


# VM Service Functions
cdef object __vml_set_mode(accuracy, ftzdaz, errmode):
    """
    Sets a new mode for VM functions according to the mode parameter and stores the previous VM mode to oldmode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlsetmode
    """
    __variables = {
        'input': {
            'accuracy': {
                'ha': mkl.VML_HA,
                'la': mkl.VML_LA,
                'ep': mkl.VML_EP,
            },
            'ftzdaz': {
                'on': mkl.VML_FTZDAZ_ON,
                'off': mkl.VML_FTZDAZ_OFF,
		'default': 0,
            },
            'errmode': {
                'ignore': mkl.VML_ERRMODE_IGNORE,
                'errno': mkl.VML_ERRMODE_ERRNO,
                'stderr': mkl.VML_ERRMODE_STDERR,
                'except': mkl.VML_ERRMODE_EXCEPT,
                'callback': mkl.VML_ERRMODE_CALLBACK,
                'default': mkl.VML_ERRMODE_DEFAULT,
            },
        },
        'output': {
            'accuracy': {
                mkl.VML_HA: 'ha',
                mkl.VML_LA: 'la',
                mkl.VML_EP: 'ep',
            },
            'ftzdaz': {
                mkl.VML_FTZDAZ_ON: 'on',
                mkl.VML_FTZDAZ_OFF: 'off',
                0: 'default',
            },
            'errmode': {
                mkl.VML_ERRMODE_IGNORE: 'ignore',
                mkl.VML_ERRMODE_ERRNO: 'errno',
                mkl.VML_ERRMODE_STDERR: 'stderr',
                mkl.VML_ERRMODE_EXCEPT: 'except',
                mkl.VML_ERRMODE_CALLBACK: 'callback',
                mkl.VML_ERRMODE_DEFAULT: 'default',
            },
        },
    }
    cdef int c_mkl_accuracy = __mkl_str_to_int(accuracy, __variables['input']['accuracy'])
    cdef int c_mkl_ftzdaz = __mkl_str_to_int(ftzdaz, __variables['input']['ftzdaz'])
    cdef int c_mkl_errmode = __mkl_str_to_int(errmode, __variables['input']['errmode'])

    cdef int c_mkl_status = mkl.vmlSetMode(c_mkl_accuracy | c_mkl_ftzdaz | c_mkl_errmode)

    accuracy = __mkl_int_to_str(
        c_mkl_status & mkl.VML_ACCURACY_MASK,
        __variables['output']['accuracy'])
    ftzdaz = __mkl_int_to_str(
        c_mkl_status & mkl.VML_FTZDAZ_MASK,
        __variables['output']['ftzdaz'])
    errmode = __mkl_int_to_str(
        c_mkl_status & mkl.VML_ERRMODE_MASK,
        __variables['output']['errmode'])

    return (accuracy, ftzdaz, errmode)


cdef object __vml_get_mode():
    """
    Gets the VM mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgetmode
    """
    __variables = {
        'output': {
            'accuracy': {
                mkl.VML_HA: 'ha',
                mkl.VML_LA: 'la',
                mkl.VML_EP: 'ep',
            },
            'ftzdaz': {
                mkl.VML_FTZDAZ_ON: 'on',
                mkl.VML_FTZDAZ_OFF: 'off',
                0: 'default',
            },
            'errmode': {
                mkl.VML_ERRMODE_IGNORE: 'ignore',
                mkl.VML_ERRMODE_ERRNO: 'errno',
                mkl.VML_ERRMODE_STDERR: 'stderr',
                mkl.VML_ERRMODE_EXCEPT: 'except',
                mkl.VML_ERRMODE_CALLBACK: 'callback',
                mkl.VML_ERRMODE_DEFAULT: 'default',
            },
        },
    }

    cdef int c_mkl_status = mkl.vmlGetMode()

    accuracy = __mkl_int_to_str(
        c_mkl_status & mkl.VML_ACCURACY_MASK,
        __variables['output']['accuracy'])
    ftzdaz = __mkl_int_to_str(
        c_mkl_status & mkl.VML_FTZDAZ_MASK,
        __variables['output']['ftzdaz'])
    errmode = __mkl_int_to_str(
        c_mkl_status & mkl.VML_ERRMODE_MASK,
        __variables['output']['errmode'])
    return (accuracy, ftzdaz, errmode)


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


cdef object __vml_set_err_status(status):
    """
    Sets the new VM Error Status according to err and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlseterrstatus
    """
    __variables = {
        'input': {
            'ok': mkl.VML_STATUS_OK,
            'accuracywarning': mkl.VML_STATUS_ACCURACYWARNING,
            'badsize': mkl.VML_STATUS_BADSIZE,
            'badmem': mkl.VML_STATUS_BADMEM,
            'errdom': mkl.VML_STATUS_ERRDOM,
            'sing': mkl.VML_STATUS_SING,
            'overflow': mkl.VML_STATUS_OVERFLOW,
            'underflow': mkl.VML_STATUS_UNDERFLOW,
        },
        'output': {
            mkl.VML_STATUS_OK: 'ok',
            mkl.VML_STATUS_ACCURACYWARNING: 'accuracywarning',
            mkl.VML_STATUS_BADSIZE: 'badsize',
            mkl.VML_STATUS_BADMEM: 'badmem',
            mkl.VML_STATUS_ERRDOM: 'errdom',
            mkl.VML_STATUS_SING: 'sing',
            mkl.VML_STATUS_OVERFLOW: 'overflow',
            mkl.VML_STATUS_UNDERFLOW: 'underflow',
        },
    }
    cdef int mkl_status_in = __mkl_str_to_int(status, __variables['input'])

    cdef int mkl_status_out = mkl.vmlSetErrStatus(mkl_status_in)

    status = __mkl_int_to_str(mkl_status_out, __variables['output'])
    return status


cdef object __vml_get_err_status():
    """
    Gets the VM Error Status.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgeterrstatus
    """
    __variables = {
        'input': None,
        'output': {
            mkl.VML_STATUS_OK: 'ok',
            mkl.VML_STATUS_ACCURACYWARNING: 'accuracywarning',
            mkl.VML_STATUS_BADSIZE: 'badsize',
            mkl.VML_STATUS_BADMEM: 'badmem',
            mkl.VML_STATUS_ERRDOM: 'errdom',
            mkl.VML_STATUS_SING: 'sing',
            mkl.VML_STATUS_OVERFLOW: 'overflow',
            mkl.VML_STATUS_UNDERFLOW: 'underflow',
        },
    }

    cdef int mkl_status = mkl.vmlGetErrStatus()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status


cdef object __vml_clear_err_status():
    """
    Sets the VM Error Status to VML_STATUS_OK and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlclearerrstatus
    """
    __variables = {
        'input': None,
        'output': {
            mkl.VML_STATUS_OK: 'ok',
            mkl.VML_STATUS_ACCURACYWARNING: 'accuracywarning',
            mkl.VML_STATUS_BADSIZE: 'badsize',
            mkl.VML_STATUS_BADMEM: 'badmem',
            mkl.VML_STATUS_ERRDOM: 'errdom',
            mkl.VML_STATUS_SING: 'sing',
            mkl.VML_STATUS_OVERFLOW: 'overflow',
            mkl.VML_STATUS_UNDERFLOW: 'underflow',
        },
    }

    cdef int mkl_status = mkl.vmlClearErrStatus()

    status = __mkl_int_to_str(mkl_status, __variables['output'])
    return status
