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


# Version Information
def get_version():
    """
    Returns the Intel MKL version.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version
    """
    return mkl.__get_version()


def get_version_string():
    """
    Returns the Intel MKL version in a character string.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-version-string
    """
    return mkl.__get_version_string()


# Threading
def set_num_threads(num_threads):
    """
    Specifies the number of OpenMP* threads to use.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads
    """
    return mkl.__set_num_threads(num_threads)


def domain_set_num_threads(num_threads, domain='all'):
    """
    Specifies the number of OpenMP* threads for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-set-num-threads
    """
    return mkl.__domain_set_num_threads(num_threads, domain)


def set_num_threads_local(num_threads):
    """
    Specifies the number of OpenMP* threads for all Intel MKL functions on the current execution thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-num-threads-local
    """
    return mkl.__set_num_threads_local(num_threads)


def set_dynamic(enable):
    """
    Enables Intel MKL to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-dynamic
    """
    return mkl.__set_dynamic(enable)


def get_max_threads():
    """
    Gets the number of OpenMP* threads targeted for parallelism.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-threads
    """
    return mkl.__get_max_threads()


def domain_get_max_threads(domain='all'):
    """
    Gets the number of OpenMP* threads targeted for parallelism for a particular function domain.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-domain-get-max-threads
    """
    return mkl.__domain_get_max_threads(domain)


def get_dynamic():
    """
    Determines whether Intel MKL is enabled to dynamically change the number of OpenMP* threads.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-dynamic
    """
    return mkl.__get_dynamic()


# Timing
def second():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return mkl.__second()


def dsecnd():
    """
    Returns elapsed time in seconds.
    Use to estimate real time between two calls to this function.
    https://software.intel.com/en-us/mkl-developer-reference-c-second/dsecnd
    """
    return mkl.__dsecnd()


def get_cpu_clocks():
    """
    Returns elapsed CPU clocks.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-clocks
    """
    return mkl.__get_cpu_clocks()


def get_cpu_frequency():
    """
    Returns the current CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-cpu-frequency
    """
    return mkl.__get_cpu_frequency()


def get_max_cpu_frequency():
    """
    Returns the maximum CPU frequency value in GHz.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-max-cpu-frequency
    """
    return mkl.__get_max_cpu_frequency()


def get_clocks_frequency():
    """
    Returns the frequency value in GHz based on constant-rate Time Stamp Counter.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-get-clocks-frequency
    """
    return mkl.__get_clocks_frequency()


# Memory Management. See the Intel MKL Developer Guide for more memory usage information.
def free_buffers():
    """
    Frees unused memory allocated by the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-free-buffers
    """
    mkl.__free_buffers()


def thread_free_buffers():
    """
    Frees unused memory allocated by the Intel MKL Memory Allocator in the current thread.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-thread-free-buffers
    """
    mkl.__thread_free_buffers()


def disable_fast_mm():
    """
    Turns off the Intel MKL Memory Allocator for Intel MKL functions to directly use the system malloc/free functions.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-disable-fast-mm
    """
    return mkl.__disable_fast_mm()


def mem_stat():
    """
    Reports the status of the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-mem-stat
    """
    return mkl.__mem_stat()


def peak_mem_usage(mem_const):
    """
    Reports the peak memory allocated by the Intel MKL Memory Allocator.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-peak-mem-usage
    """
    return mkl.__peak_mem_usage(mem_const)


def set_memory_limit(limit):
    """
    On Linux, sets the limit of memory that Intel MKL can allocate for a specified type of memory.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-memory-limit
    """
    return mkl.__set_memory_limit(limit)


# Conditional Numerical Reproducibility
def cbwr_set(branch=None):
    """
    Configures the CNR mode of Intel MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-set
    """
    return mkl.__cbwr_set(branch)


def cbwr_get(cnr_const=None):
    """
    Returns the current CNR settings.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get
    """
    return mkl.__cbwr_get(cnr_const)


def cbwr_get_auto_branch():
    """
    Automatically detects the CNR code branch for your platform.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-cbwr-get-auto-branch
    """
    return mkl.__cbwr_get_auto_branch()


# Miscellaneous
def enable_instructions(isa=None):
    """
    Enables dispatching for new Intel architectures or restricts the set of Intel instruction sets available for dispatching.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-enable-instructions
    """
    return mkl.__enable_instructions(isa)


def set_env_mode():
    """
    Sets up the mode that ignores environment settings specific to Intel MKL. See mkl_set_env_mode(1).
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-env-mode
    """
    return mkl.__set_env_mode()


def get_env_mode():
    """
    Query the current environment mode. See mkl_set_env_mode(0).
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-env-mode
    """
    return mkl.__get_env_mode()


def verbose(enable):
    """
    Enables or disables Intel MKL Verbose mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-verbose
    """
    return mkl.__verbose(enable)


def set_mpi(vendor, custom_library_name):
    """
    Sets the implementation of the message-passing interface to be used by Intel MKL.
    https://software.intel.com/en-us/mkl-developer-reference-c-mkl-set-mpi
    """
    return mkl.__set_mpi(vendor, custom_library_name)


# VM Service Functions
def vml_set_mode(accuracy, ftzdaz, errmode):
    """
    Sets a new mode for VM functions according to the mode parameter and stores the previous VM mode to oldmode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlsetmode
    """
    return mkl.__vml_set_mode(accuracy, ftzdaz, errmode)


def vml_get_mode():
    """
    Gets the VM mode.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgetmode
    """
    return mkl.__vml_get_mode()


def vml_set_err_status(status):
    """
    Sets the new VM Error Status according to err and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlseterrstatus
    """
    return mkl.__vml_set_err_status(status)


def vml_get_err_status():
    """
    Gets the VM Error Status.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlgeterrstatus
    """
    return mkl.__vml_get_err_status()


def vml_clear_err_status():
    """
    Sets the VM Error Status to VML_STATUS_OK and stores the previous VM Error Status to olderr.
    https://software.intel.com/en-us/mkl-developer-reference-c-vmlclearerrstatus
    """
    return mkl.__vml_clear_err_status()
