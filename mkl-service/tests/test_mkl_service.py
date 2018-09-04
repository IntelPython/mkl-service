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


import mkl_service as mkl


class test_version_information():
    # https://software.intel.com/en-us/mkl-developer-reference-c-version-information
    def test_get_version(self):
        mkl.get_version()

    def test_get_version_string(self):
        mkl.get_version_string()


class test_threading_control():
    # https://software.intel.com/en-us/mkl-developer-reference-c-threading-control
    def test_set_num_threads(self):
        mkl.set_num_threads(8)

    def test_domain_set_num_threads_str_blas(self):
        status = mkl.domain_set_num_threads(4, domain='blas')
        assert(status == 'success')

    def test_domain_set_num_threads_str_fft(self):
        status = mkl.domain_set_num_threads(4, domain='fft')
        assert(status == 'success')

    def test_domain_set_num_threads_str_vml(self):
        status = mkl.domain_set_num_threads(4, domain='vml')
        assert(status == 'success')

    def test_domain_set_num_threads_str_pardiso(self):
        status = mkl.domain_set_num_threads(4, domain='pardiso')
        assert(status == 'success')

    def test_domain_set_num_threads_str_all(self):
        status = mkl.domain_set_num_threads(4, domain='all')
        assert(status == 'success')

    def test_domain_set_num_threads_enum_blas(self):
        status = mkl.domain_set_num_threads(4, domain=mkl.enums.MKL_DOMAIN_BLAS)
        assert(status == 'success')

    def test_domain_set_num_threads_enum_fft(self):
        status = mkl.domain_set_num_threads(4, domain=mkl.enums.MKL_DOMAIN_FFT)
        assert(status == 'success')

    def test_domain_set_num_threads_enum_vml(self):
        status = mkl.domain_set_num_threads(4, domain=mkl.enums.MKL_DOMAIN_VML)
        assert(status == 'success')

    def test_domain_set_num_threads_enum_pardiso(self):
        status = mkl.domain_set_num_threads(4, domain=mkl.enums.MKL_DOMAIN_PARDISO)
        assert(status == 'success')

    def test_domain_set_num_threads_enum_all(self):
        status = mkl.domain_set_num_threads(4, domain=mkl.enums.MKL_DOMAIN_ALL)
        assert(status == 'success')

    def test_set_num_threads_local(self):
        mkl.set_num_threads(1)
        status = mkl.set_num_threads_local(2)
        assert(status == 'global_num_threads')
        status = mkl.set_num_threads_local(4)
        assert(status == 2)
        status = mkl.set_num_threads_local(0)
        assert(status == 4)
        status = mkl.set_num_threads_local(8)
        assert(status == 'global_num_threads')

    def test_set_dynamic(self):
        mkl.set_dynamic(True)

    def test_get_max_threads(self):
        mkl.get_max_threads()

    def test_domain_get_max_threads_str_blas(self):
        mkl.domain_get_max_threads(domain='blas')

    def test_domain_get_max_threads_str_fft(self):
        mkl.domain_get_max_threads(domain='fft')

    def test_domain_get_max_threads_str_vml(self):
        mkl.domain_get_max_threads(domain='vml')

    def test_domain_get_max_threads_str_pardiso(self):
        mkl.domain_get_max_threads(domain='pardiso')

    def test_domain_get_max_threads_str_all(self):
        mkl.domain_get_max_threads(domain='all')

    def test_domain_get_max_threads_enum_blas(self):
        mkl.domain_get_max_threads(domain=mkl.enums.MKL_DOMAIN_BLAS)

    def test_domain_get_max_threads_enum_fft(self):
        mkl.domain_get_max_threads(domain=mkl.enums.MKL_DOMAIN_FFT)

    def test_domain_get_max_threads_enum_vml(self):
        mkl.domain_get_max_threads(domain=mkl.enums.MKL_DOMAIN_VML)

    def test_domain_get_max_threads_enum_pardiso(self):
        mkl.domain_get_max_threads(domain=mkl.enums.MKL_DOMAIN_PARDISO)

    def test_domain_get_max_threads_enum_all(self):
        mkl.domain_get_max_threads(domain=mkl.enums.MKL_DOMAIN_ALL)

    def test_get_dynamic(self):
        mkl.get_dynamic()


class test_timing:
    # https://software.intel.com/en-us/mkl-developer-reference-c-timing
    def test_second(self):
        s1 = mkl.second()
        s2 = mkl.second()
        delta = s2 - s1
        assert(delta >= 0)

    def test_dsecnd(self):
        d1 = mkl.dsecnd()
        d2 = mkl.dsecnd()
        delta = d2 - d1
        assert(delta >= 0)

    def test_get_cpu_clocks(self):
        c1 = mkl.get_cpu_clocks()
        c2 = mkl.get_cpu_clocks()
        delta = c2 - c1
        assert(delta >= 0)

    def test_get_cpu_frequency(self):
        assert(mkl.get_cpu_frequency() > 0)

    def test_get_max_cpu_frequency(self):
        assert(mkl.get_max_cpu_frequency() > 0)

    def test_get_clocks_frequency(self):
        assert(mkl.get_clocks_frequency() > 0)


class test_memory_management():
    # https://software.intel.com/en-us/mkl-developer-reference-c-memory-management
    def test_free_buffers(self):
        mkl.free_buffers()

    def test_thread_free_buffers(self):
        mkl.thread_free_buffers()

    def test_disable_fast_mm(self):
        mkl.disable_fast_mm()

    def test_mem_stat(self):
        mkl.mem_stat()

    def test_peak_mem_usage_str_enable(self):
        mkl.peak_mem_usage('enable')

    def test_peak_mem_usage_str_disable(self):
        mkl.peak_mem_usage('disable')

    def test_peak_mem_usage_str_peak_mem(self):
        mkl.peak_mem_usage('peak_mem')

    def test_peak_mem_usage_str_peak_mem_reset(self):
        mkl.peak_mem_usage('peak_mem_reset')

    def test_peak_mem_usage_enum_enable(self):
        mkl.peak_mem_usage(mkl.enums.MKL_PEAK_MEM_ENABLE)

    def test_peak_mem_usage_enum_disable(self):
        mkl.peak_mem_usage(mkl.enums.MKL_PEAK_MEM_DISABLE)

    def test_peak_mem_usage_enum_peak_mem(self):
        mkl.peak_mem_usage(mkl.enums.MKL_PEAK_MEM)

    def test_peak_mem_usage_enum_peak_mem_reset(self):
        mkl.peak_mem_usage(mkl.enums.MKL_PEAK_MEM_RESET)

    def test_set_memory_limit(self):
        mkl.set_memory_limit(128)


class test_conditional_numerical_reproducibility_control:
    # https://software.intel.com/en-us/mkl-developer-reference-c-conditional-numerical-reproducibility-control
    def test_cbwr_set_str_auto(self):
        mkl.cbwr_set(branch='auto')

    def test_cbwr_set_str_compatible(self):
        mkl.cbwr_set(branch='compatible')

    def test_cbwr_set_str_sse2(self):
        mkl.cbwr_set(branch='sse2')

    def test_cbwr_set_str_sse3(self):
        mkl.cbwr_set(branch='sse3')

    def test_cbwr_set_str_ssse3(self):
        mkl.cbwr_set(branch='ssse3')

    def test_cbwr_set_str_sse4_1(self):
        mkl.cbwr_set(branch='sse4_1')

    def test_cbwr_set_str_sse4_2(self):
        mkl.cbwr_set(branch='sse4_2')

    def test_cbwr_set_str_avx(self):
        mkl.cbwr_set(branch='avx')

    def test_cbwr_set_str_avx2(self):
        mkl.cbwr_set(branch='avx2')

    def test_cbwr_set_str_avx512_mic(self):
        mkl.cbwr_set(branch='avx512_mic')

    def test_cbwr_set_str_avx512(self):
        mkl.cbwr_set(branch='avx512')

    def test_cbwr_set_enum_auto(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_AUTO)

    def test_cbwr_set_enum_compatible(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_COMPATIBLE)

    def test_cbwr_set_enum_sse2(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_SSE2)

    def test_cbwr_set_enum_sse3(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_SSE3)

    def test_cbwr_set_enum_ssse3(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_SSSE3)

    def test_cbwr_set_enum_sse4_1(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_SSE4_1)

    def test_cbwr_set_enum_sse4_2(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_SSE4_2)

    def test_cbwr_set_enum_avx(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_AVX)

    def test_cbwr_set_enum_avx2(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_AVX2)

    def test_cbwr_set_enum_avx512_mic(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_AVX512_MIC)

    def test_cbwr_set_enum_avx512(self):
        mkl.cbwr_set(branch=mkl.enums.MKL_CBWR_AVX512)

    def test_cbwr_get(self):
        mkl.cbwr_get(cnr_const=mkl.enums.MKL_CBWR_ALL)

    def test_cbwr_get_auto_branch(self):
        mkl.cbwr_get_auto_branch()


class test_miscellaneous():
    # https://software.intel.com/en-us/mkl-developer-reference-c-miscellaneous
    def test_enable_instructions(self):
        mkl.enable_instructions(mkl.enums.MKL_ENABLE_AVX)

    def test_set_env_mode(self):
        mkl.set_env_mode()

    def test_get_env_mode(self):
        mkl.get_env_mode()

    def test_verbose(self):
        mkl.verbose(False)

    def test_set_mpi(self):
        mkl.set_mpi('intelmpi', 'test')

class test_vm_service_functions():
    # https://software.intel.com/en-us/mkl-developer-reference-c-vm-service-functions
    def test_vmlSetMode(self):
        mkl.vml_set_mode('la', 'on', 'stderr')

    def test_vmlGetMode(self):
        mkl.vml_get_mode()

    def test_vmlSetErrStatus(self):
        mkl.vml_set_err_status(mkl.enums.VML_STATUS_OK)

    def test_vmlGetErrStatus(self):
        mkl.vml_get_err_status()

    def test_vmlClearErrStatus(self):
        mkl.vml_clear_err_status()

