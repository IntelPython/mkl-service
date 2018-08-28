cimport _mkl_service as mkl
from enum import IntEnum


class enums(IntEnum):
    # MKL Function Domains
    MKL_DOMAIN_BLAS = mkl.MKL_DOMAIN_BLAS
    MKL_DOMAIN_FFT = mkl.MKL_DOMAIN_FFT
    MKL_DOMAIN_VML = mkl.MKL_DOMAIN_VML
    MKL_DOMAIN_PARDISO = mkl.MKL_DOMAIN_PARDISO
    MKL_DOMAIN_ALL = mkl.MKL_DOMAIN_ALL

    # MKL_INT64 mkl_peak_mem_usage(int mode)
    # In
    MKL_PEAK_MEM_ENABLE = mkl.MKL_PEAK_MEM_ENABLE
    MKL_PEAK_MEM_DISABLE = mkl.MKL_PEAK_MEM_DISABLE
    MKL_PEAK_MEM = mkl.MKL_PEAK_MEM
    MKL_PEAK_MEM_RESET = mkl.MKL_PEAK_MEM_RESET

    # int mkl_set_memory_limit(int mem_type, size_t limit)
    # In
    MKL_MEM_MCDRAM = mkl.MKL_MEM_MCDRAM

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

    # int mkl_enable_instructions(int isa)
    # In
    MKL_ENABLE_AVX512 = mkl.MKL_ENABLE_AVX512
    MKL_ENABLE_AVX512_MIC = mkl.MKL_ENABLE_AVX512_MIC
    MKL_ENABLE_AVX2 = mkl.MKL_ENABLE_AVX2
    MKL_ENABLE_AVX = mkl.MKL_ENABLE_AVX
    MKL_ENABLE_SSE4_2 = mkl.MKL_ENABLE_SSE4_2

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

# MKL Function Domains
__mkl_domain_enums = {'blas': mkl.MKL_DOMAIN_BLAS,
                      'fft': mkl.MKL_DOMAIN_FFT,
                      'vml': mkl.MKL_DOMAIN_VML,
                      'pardiso': mkl.MKL_DOMAIN_PARDISO,
                      'all': mkl.MKL_DOMAIN_ALL}

# CNR Control Constants
__mkl_cbwr_set_in_enums = {'auto': mkl.MKL_CBWR_AUTO,
                           'compatible': mkl.MKL_CBWR_COMPATIBLE,
                           'sse2': mkl.MKL_CBWR_SSE2,
                           'sse3': mkl.MKL_CBWR_SSE3,
                           'ssse3': mkl.MKL_CBWR_SSSE3,
                           'sse4_1': mkl.MKL_CBWR_SSE4_1,
                           'sse4_2': mkl.MKL_CBWR_SSE4_2,
                           'avx': mkl.MKL_CBWR_AVX,
                           'avx2': mkl.MKL_CBWR_AVX2,
                           'avx512_mic': mkl.MKL_CBWR_AVX512_MIC,
                           'avx512': mkl.MKL_CBWR_AVX512}

__mkl_cbwr_set_out_enums = {mkl.MKL_CBWR_SUCCESS: 'success',
                            mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input',
                            mkl.MKL_CBWR_ERR_UNSUPPORTED_BRANCH: 'err_unsupported_branch',
                            mkl.MKL_CBWR_ERR_MODE_CHANGE_FAILURE: 'err_mode_change_failure'}

__mkl_cbwr_get_in_enums = {'branch': mkl.MKL_CBWR_BRANCH,
                           'all': mkl.MKL_CBWR_ALL}

__mkl_cbwr_get_out_enums = {mkl.MKL_CBWR_SUCCESS: 'success',
                            mkl.MKL_CBWR_ERR_INVALID_INPUT: 'err_invalid_input'}
__mkl_cbwr_get_out_enums.update({value: key for key, value in __mkl_cbwr_set_in_enums.items()})

__mkl_cbwr_get_auto_branch_out_enums = {}
__mkl_cbwr_get_auto_branch_out_enums.update({value: key for key, value in __mkl_cbwr_set_in_enums.items()})


'''
    # MKL support functions
    void mkl_get_version(MKLVersion * pv)
    void mkl_get_version_string(char *buf, int len)
'''
def mkl_get_version():
    cdef mkl.MKLVersion c_mkl_version
    mkl.mkl_get_version(&c_mkl_version)
    return c_mkl_version


def mkl_get_version_string():
    cdef int c_string_len = 198
    cdef char[198] c_string
    mkl.mkl_get_version_string(c_string, c_string_len)
    return c_string.decode()


'''
    # Threading
    void mkl_set_num_threads(int nth)
    int mkl_domain_set_num_threads(int nt, int domain)
    int mkl_set_num_threads_local(int nth)
    void mkl_set_dynamic(int flag)
    int mkl_get_max_threads()
    int mkl_domain_get_max_threads(int domain)
    int mkl_get_dynamic()
'''
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


'''
    # Timing
    float second()
    double dsecnd()
    void mkl_get_cpu_clocks(MKL_UINT64* cl)
    double mkl_get_cpu_frequency()
    double mkl_get_cpu_max_frequency()
    double mkl_get_clocks_frequency()
'''
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


'''
    # Memory
    void mkl_free_buffers()
    void mkl_thread_free_buffers()
    int mkl_disable_fast_mm()
    MKL_INT64 mkl_mem_stat(int *buf)
    MKL_INT64 mkl_peak_mem_usage(int mode)
    int mkl_set_memory_limit(int mem_type, size_t limit)
    
'''
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


def mkl_peak_mem_usage(mode):
    return mkl.mkl_peak_mem_usage(mode)


def mkl_set_memory_limit(mem_type, limit):
    return mkl.mkl_set_memory_limit(mem_type, limit)


'''
    # Conditional Numerical Reproducibility
    int mkl_cbwr_set(int settings)
    int mkl_cbwr_get(int option)
    int mkl_cbwr_get_auto_branch()
'''
def mkl_cbwr_set(branch=''):
    branch_type = type(branch)
    if branch_type is str:
        assert(branch in __mkl_cbwr_set_in_enums.keys())
        branch = __mkl_cbwr_set_in_enums[branch]
    else:
        assert((branch_type is int) and (branch in __mkl_cbwr_set_in_enums.values()))

    status = mkl.mkl_cbwr_set(branch)
    assert(status in __mkl_cbwr_set_out_enums.keys())

    return __mkl_cbwr_set_out_enums[status]


def mkl_cbwr_get(cnr_const=''):
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


'''
    #Miscellaneous
    int mkl_enable_instructions(int isa)
    int mkl_set_env_mode(int mode)
    int mkl_verbose(int enable)
    int mkl_set_mpi (int vendor, const char *custom_library_name)
'''
def mkl_enable_instructions(isa):
    return mkl.mkl_enable_instructions(isa)


def mkl_set_env_mode(mode):
    return mkl.mkl_set_env_mode(mode)


def mkl_verbose(enable):
    assert(type(enable) is bool)
    return mkl.mkl_verbose(enable)


def mkl_set_mpi(vendor, custom_library_name):
    cdef bytes c_bytes = custom_library_name.encode()
    cdef char* c_string = c_bytes
    return mkl.mkl_set_mpi(vendor, c_string)


'''
    #VM Service Functions
    unsigned int vmlSetMode(unsigned int mode)
    unsigned int vmlGetMode()
    int vmlSetErrStatus(const MKL_INT status)
    int vmlGetErrStatus()
    int vmlClearErrStatus()
'''
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
