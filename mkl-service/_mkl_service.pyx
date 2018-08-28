cimport _mkl_service as mkl


# MKL_INT64 mkl_peak_mem_usage(int mode)
# In
MKL_PEAK_MEM_ENABLE = mkl.MKL_PEAK_MEM_ENABLE
MKL_PEAK_MEM_DISABLE = mkl.MKL_PEAK_MEM_DISABLE
MKL_PEAK_MEM = mkl.MKL_PEAK_MEM
MKL_PEAK_MEM_RESET = mkl.MKL_PEAK_MEM_RESET

# int mkl_set_memory_limit(int mem_type, size_t limit)
# In
MKL_MEM_MCDRAM = mkl.MKL_MEM_MCDRAM

# int mkl_cbwr_set(int settings)
# In
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
# Out
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
def mkl_set_num_threads(nt):
    mkl.mkl_set_num_threads(nt)


def mkl_domain_set_num_threads(nth, domain):
    return mkl.mkl_domain_set_num_threads(nth, domain)


def mkl_set_num_threads_local(nth):
    return mkl.mkl_set_num_threads_local(nth)


def mkl_set_dynamic(flag):
    mkl.mkl_set_dynamic(flag)


def mkl_get_max_threads():
    return mkl.mkl_get_max_threads()


def mkl_domain_get_max_threads(domain):
    return mkl.mkl_domain_get_max_threads(domain)


def mkl_get_dynamic():
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
    #Conditional Numerical Reproducibility
    int mkl_cbwr_set(int settings)
    int mkl_cbwr_get_auto_branch()
'''
def mkl_cbwr_set(settings):
    return mkl.mkl_cbwr_set(settings)


def mkl_cbwr_get_auto_branch():
    return mkl.mkl_cbwr_get_auto_branch()


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


def mkl_verbose(isEnabled):
    assert(type(isEnabled) is bool)
    return mkl.mkl_verbose(isEnabled)


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
