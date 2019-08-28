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


from nose.tools import assert_equals, nottest
import six
import mkl


class test_version_information():
    # https://software.intel.com/en-us/mkl-developer-reference-c-version-information
    def test_get_version(self):
        v = mkl.get_version()
        assert(isinstance(v, dict))
        assert('MajorVersion' in v)
        assert('MinorVersion' in v)
        assert('UpdateVersion' in v)

    def test_get_version_string(self):
        v = mkl.get_version_string()
        assert(isinstance(v, six.string_types))
        assert('Math Kernel Library' in v)


class test_threading_control():
    # https://software.intel.com/en-us/mkl-developer-reference-c-threading-control
    def test_set_num_threads(self):
        saved = mkl.get_max_threads()
        half_nt = int( (1 + saved) / 2 ) 
        mkl.set_num_threads(half_nt)
        assert(mkl.get_max_threads() == half_nt)
        mkl.set_num_threads(saved)

    def test_domain_set_num_threads_blas(self):
        saved_blas_nt = mkl.domain_get_max_threads(domain='blas')
        saved_fft_nt = mkl.domain_get_max_threads(domain='fft')
        saved_vml_nt = mkl.domain_get_max_threads(domain='vml')
        # set
        blas_nt = int( (3 + saved_blas_nt)/4 )
        fft_nt = int( (3 + 2*saved_fft_nt)/4 )
        vml_nt = int( (3 + 3*saved_vml_nt)/4 )
        status = mkl.domain_set_num_threads(blas_nt, domain='blas')
        assert(status == 'success')
        status = mkl.domain_set_num_threads(fft_nt, domain='fft')
        assert(status == 'success')
        status = mkl.domain_set_num_threads(vml_nt, domain='vml')
        assert(status == 'success')
        # check
        assert(mkl.domain_get_max_threads(domain='blas') == blas_nt)
        assert(mkl.domain_get_max_threads(domain='fft') == fft_nt)
        assert(mkl.domain_get_max_threads(domain='vml') == vml_nt)
        # restore
        status = mkl.domain_set_num_threads(saved_blas_nt, domain='blas')
        assert(status == 'success')
        status = mkl.domain_set_num_threads(saved_fft_nt, domain='fft')
        assert(status == 'success')
        status = mkl.domain_set_num_threads(saved_vml_nt, domain='vml')
        assert(status == 'success')
        
    def test_domain_set_num_threads_fft(self):
        status = mkl.domain_set_num_threads(4, domain='fft')
        assert(status == 'success')

    def test_domain_set_num_threads_vml(self):
        status = mkl.domain_set_num_threads(4, domain='vml')
        assert(status == 'success')

    def test_domain_set_num_threads_pardiso(self):
        status = mkl.domain_set_num_threads(4, domain='pardiso')
        assert(status == 'success')

    def test_domain_set_num_threads_all(self):
        status = mkl.domain_set_num_threads(4, domain='all')
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

    def test_domain_get_max_threads_blas(self):
        mkl.domain_get_max_threads(domain='blas')

    def test_domain_get_max_threads_fft(self):
        mkl.domain_get_max_threads(domain='fft')

    def test_domain_get_max_threads_vml(self):
        mkl.domain_get_max_threads(domain='vml')

    def test_domain_get_max_threads_pardiso(self):
        mkl.domain_get_max_threads(domain='pardiso')

    def test_domain_get_max_threads_all(self):
        mkl.domain_get_max_threads(domain='all')

    def test_get_dynamic(self):
        mkl.get_dynamic()


class test_timing():
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

    def test_peak_mem_usage_enable(self):
        mkl.peak_mem_usage('enable')

    def test_peak_mem_usage_disable(self):
        mkl.peak_mem_usage('disable')

    def test_peak_mem_usage_peak_mem(self):
        mkl.peak_mem_usage('peak_mem')

    def test_peak_mem_usage_peak_mem_reset(self):
        mkl.peak_mem_usage('peak_mem_reset')

    def test_set_memory_limit(self):
        mkl.set_memory_limit(128)


class test_cnr_control():
    # https://software.intel.com/en-us/mkl-developer-reference-c-conditional-numerical-reproducibility-control
    def test_cbwr(self):
        branches = [
            'off',
            'branch_off',
            'auto',
            'compatible',
            'sse2',
            'ssse3',
            'sse4_1',
            'sse4_2',
            'avx',
            'avx2',
            'avx512_mic',
            'avx512',
            'avx512_mic_e1',
            'avx512_e1',
        ]
        strict = [
            'avx2,strict',
            'avx512_mic,strict',
            'avx512,strict',
            'avx512_e1,strict',
        ]
        for branch in branches:
            yield self.check_cbwr, branch, 'branch'
        for branch in branches + strict:
            yield self.check_cbwr, branch, 'all'

    def check_cbwr(self, branch, cnr_const):
        status = mkl.cbwr_set(branch=branch)
        if status == 'success':
            expected_value = 'branch_off' if branch == 'off' else branch
            actual_value = mkl.cbwr_get(cnr_const=cnr_const)
            assert_equals(actual_value,
                          expected_value,
                          msg="Round-trip failure for CNR branch '{}', CNR const '{}'".format(branch, cnr_const))
        elif status != 'err_unsupported_branch':
            raise AssertionError(status)

    def test_cbwr_get_auto_branch(self):
        mkl.cbwr_get_auto_branch()


class test_miscellaneous():
    # https://software.intel.com/en-us/mkl-developer-reference-c-miscellaneous
    def test_enable_instructions_avx512_mic_e1(self):
        mkl.enable_instructions('avx512_mic_e1')

    def test_enable_instructions_avx512(self):
        mkl.enable_instructions('avx512')

    def test_enable_instructions_avx512_mic(self):
        mkl.enable_instructions('avx512_mic')

    def test_enable_instructions_avx2(self):
        mkl.enable_instructions('avx2')

    def test_enable_instructions_avx(self):
        mkl.enable_instructions('avx')

    def test_enable_instructions_sse4_2(self):
        mkl.enable_instructions('sse4_2')

    def test_set_env_mode(self):
        mkl.set_env_mode()

    def test_get_env_mode(self):
        mkl.get_env_mode()

    def test_verbose_false(self):
        mkl.verbose(False)

    def test_verbose_true(self):
        mkl.verbose(True)

    #def test_set_mpi_custom(self):
    #    mkl.set_mpi('custom', 'custom_library_name')

    @nottest
    def test_set_mpi_msmpi(self):
        mkl.set_mpi('msmpi')

    #def test_set_mpi_intelmpi(self):
    #    mkl.set_mpi('intelmpi')

    #def test_set_mpi_mpich2(self):
    #    mkl.set_mpi('mpich2')


class test_vm_service_functions():
    # https://software.intel.com/en-us/mkl-developer-reference-c-vm-service-functions
    def test_vml_set_get_mode_roundtrip(self):
        saved = mkl.vml_get_mode()
        mkl.vml_set_mode(*saved) # should not raise errors

    def test_vml_set_mode_ha_on_ignore(self):
        mkl.vml_set_mode('ha', 'on', 'ignore')

    def test_vml_set_mode_ha_on_errno(self):
        mkl.vml_set_mode('ha', 'on', 'errno')

    def test_vml_set_mode_la_on_stderr(self):
        mkl.vml_set_mode('la', 'on', 'stderr')

    def test_vml_set_mode_la_off_except(self):
        mkl.vml_set_mode('la', 'off', 'except')

    def test_vml_set_mode_op_off_callback(self):
        mkl.vml_set_mode('ep', 'off', 'callback')

    def test_vml_set_mode_ep_off_default(self):
        mkl.vml_set_mode('ep', 'off', 'default')

    def test_vml_get_mode(self):
        mkl.vml_get_mode()

    def test_vml_set_err_status_ok(self):
        mkl.vml_set_err_status('ok')

    def test_vml_set_err_status_accuracywarning(self):
        mkl.vml_set_err_status('accuracywarning')

    def test_vml_set_err_status_badsize(self):
        mkl.vml_set_err_status('badsize')

    def test_vml_set_err_status_badmem(self):
        mkl.vml_set_err_status('badmem')

    def test_vml_set_err_status_errdom(self):
        mkl.vml_set_err_status('errdom')

    def test_vml_set_err_status_sing(self):
        mkl.vml_set_err_status('sing')

    def test_vml_set_err_status_overflow(self):
        mkl.vml_set_err_status('overflow')

    def test_vml_set_err_status_underflow(self):
        mkl.vml_set_err_status('underflow')

    def test_vml_get_err_status(self):
        mkl.vml_get_err_status()

    def test_vml_clear_err_status(self):
        mkl.vml_clear_err_status()
