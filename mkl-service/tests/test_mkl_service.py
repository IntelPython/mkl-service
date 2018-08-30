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
        mkl_service.mkl_domain_set_num_threads(1, domain='fft')

    def test_mkl_set_num_threads_local(self):
        mkl_service.mkl_set_num_threads_local(1)

    def test_mkl_set_dynamic(self):
        mkl_service.mkl_set_dynamic(True)

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
        mkl_service.mkl_set_memory_limit(128)


class test_conditional_numerical_reproducibility_control:
    # https://software.intel.com/en-us/mkl-developer-reference-c-conditional-numerical-reproducibility-control
    def test_mkl_cbwr_set(self):
        #mkl_service.mkl_cbwr_set(mkl_service.MKL_CBWR_AUTO)
        mkl_service.mkl_cbwr_set(branch='auto')

    def test_mkl_cbwr_get(self):
        mkl_service.mkl_cbwr_get(cnr_const=mkl_service.enums.MKL_CBWR_ALL)

    def test_mkl_cbwr_get_auto_branch(self):
        mkl_service.mkl_cbwr_get_auto_branch()


class test_miscellaneous():
    # https://software.intel.com/en-us/mkl-developer-reference-c-miscellaneous
    def test_mkl_enable_instructions(self):
        mkl_service.mkl_enable_instructions(mkl_service.enums.MKL_ENABLE_AVX)

    def test_mkl_set_env_mode(self):
        mkl_service.mkl_set_env_mode(0)

    def test_mkl_verbose(self):
        mkl_service.mkl_verbose(False)

    def test_mkl_set_mpi(self):
        mkl_service.mkl_set_mpi('intelmpi', 'test')

class test_vm_service_functions():
    # https://software.intel.com/en-us/mkl-developer-reference-c-vm-service-functions
    def test_vmlSetMode(self):
        mkl_service.vmlSetMode(mkl_service.enums.VML_HA)

    def test_vmlGetMode(self):
        mkl_service.vmlGetMode()

    def test_vmlSetErrStatus(self):
        mkl_service.vmlSetErrStatus(mkl_service.enums.VML_STATUS_OK)

    def test_vmlGetErrStatus(self):
        mkl_service.vmlGetErrStatus()

    def test_vmlClearErrStatus(self):
        mkl_service.vmlClearErrStatus()

