import mkl_service


class test_version_information():
    # https://software.intel.com/en-us/mkl-developer-reference-c-version-information
    def test_mkl_get_version(self):
        mkl_service.mkl_get_version()

    def test_mkl_get_version_string(self):
        mkl_service.mkl_get_version_string()


class test_threading_control():
    # https://software.intel.com/en-us/mkl-developer-reference-c-threading-control
    def test_mkl_set_num_threads(self):
        mkl_service.mkl_set_num_threads(1)

    def test_mkl_domain_set_num_threads(self):
        mkl_service.mkl_domain_set_num_threads(1, 1)

    def test_mkl_set_num_threads_local(self):
        mkl_service.mkl_set_num_threads_local(1)

    def test_mkl_set_dynamic(self):
        mkl_service.mkl_set_dynamic(0)

    def test_mkl_get_max_threads(self):
        mkl_service.mkl_get_max_threads()

    def test_mkl_domain_get_max_threads(self):
        mkl_service.mkl_domain_get_max_threads(1)

    def test_mkl_get_dynamic(self):
        mkl_service.mkl_get_dynamic()


class test_timing:
    # https://software.intel.com/en-us/mkl-developer-reference-c-timing
    def test_second(self):
        s1 = mkl_service.second()
        s2 = mkl_service.second()
        delta = s2 - s1
        assert(delta >= 0)

    def test_dsecnd(self):
        d1 = mkl_service.dsecnd()
        d2 = mkl_service.dsecnd()
        delta = d2 - d1
        assert(delta >= 0)

    def test_mkl_get_cpu_clocks(self):
        c1 = mkl_service.mkl_get_cpu_clocks()
        c2 = mkl_service.mkl_get_cpu_clocks()
        delta = c2 - c1
        assert(delta >= 0)

    def test_mkl_get_cpu_frequency(self):
        assert(mkl_service.mkl_get_cpu_frequency() > 0)

    def test_mkl_get_max_cpu_frequency(self):
        assert(mkl_service.mkl_get_max_cpu_frequency() > 0)

    def test_mkl_get_clocks_frequency(self):
        assert(mkl_service.mkl_get_clocks_frequency() > 0)


class test_memory_management():
    # https://software.intel.com/en-us/mkl-developer-reference-c-memory-management
    def test_mkl_free_buffers(self):
        mkl_service.mkl_free_buffers()

    def test_mkl_thread_free_buffers(self):
        mkl_service.mkl_thread_free_buffers()

    def test_mkl_disable_fast_mm(self):
        mkl_service.mkl_disable_fast_mm()

    def test_mkl_mem_stat(self):
        mkl_service.mkl_mem_stat()

    def test_mkl_peak_mem_usage(self):
        mkl_service.mkl_peak_mem_usage(0)

    def test_mkl_set_memory_limit(self):
        mkl_service.mkl_set_memory_limit(0, 128)


class test_conditional_numerical_reproducibility_control:
    # https://software.intel.com/en-us/mkl-developer-reference-c-conditional-numerical-reproducibility-control
    def test_mkl_cbwr_set(self):
        mkl_service.mkl_cbwr_set(mkl_service.MKL_CBWR_AUTO)

    def test_mkl_cbwr_get_auto_branch(self):
        mkl_service.mkl_cbwr_get_auto_branch()


class test_miscellaneous():
    # https://software.intel.com/en-us/mkl-developer-reference-c-miscellaneous
    def test_mkl_enable_instructions(self):
        mkl_service.mkl_enable_instructions(mkl_service.MKL_ENABLE_AVX)

    def test_mkl_set_env_mode(self):
        mkl_service.mkl_set_env_mode(0)

    def test_mkl_verbose(self):
        mkl_service.mkl_verbose(0)

    def test_mkl_set_mpi(self):
        mkl_service.mkl_set_mpi(1, 'test')

class test_vm_service_functions():
    # https://software.intel.com/en-us/mkl-developer-reference-c-vm-service-functions
    def test_vmlSetMode(self):
        mkl_service.vmlSetMode(mkl_service.VML_HA)

    def test_vmlGetMode(self):
        mkl_service.vmlGetMode()

    def test_vmlSetErrStatus(self):
        mkl_service.vmlSetErrStatus(mkl_service.VML_STATUS_OK)

    def test_vmlGetErrStatus(self):
        mkl_service.vmlGetErrStatus()

    def test_vmlClearErrStatus(self):
        mkl_service.vmlClearErrStatus()

