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


import mkl
import re


def enable_best_instructions_set():
    for instructions_set in ['avx512', 'avx2', 'avx', 'sse4_2']:
        if mkl.enable_instructions(instructions_set) == 'success':
            result = instructions_set
            break
    else:
        result = 'error'

    return result


def is_max_supported_instructions_set(instructions_set):
    result = False
    if re.search(instructions_set.replace('4_2', '4.2'), mkl.get_version()['Processor'].decode(), re.IGNORECASE):
        result = True

    return result


if __name__ == '__main__':
    time_begin = mkl.dsecnd()
    print(mkl.get_version_string())

    instructions_set = enable_best_instructions_set()
    print('Enable snstructions set: ' + str(instructions_set))

    is_max = is_max_supported_instructions_set(instructions_set)
    print('Is the best supported instructions set: ' + str(is_max))

    time_end = mkl.dsecnd()
    print('Execution time: ' + str(time_end - time_begin))
