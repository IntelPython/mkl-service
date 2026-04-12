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

import sys

import mkl


def test_mkl_memory_create_malloc():
    nbytes = 1024
    mem = mkl.MKLMemory(nbytes)
    assert mem.nbytes == nbytes
    # default alignment is 64 bytes
    assert mem.alignment == 64


def test_mkl_memory_create_calloc():
    size = 32
    num = 32
    nbytes = num * size
    # test creating with mkl_calloc
    mem = mkl.MKLMemory(num, size)
    assert mem.nbytes == nbytes
    # default alignment is 64 bytes
    assert mem.alignment == 64


def test_mkl_memory_create_with_malloc_and_alignment():
    size = 32
    num = 32
    nbytes = num * size
    alignment = 128
    mem = mkl.MKLMemory(nbytes, alignment=alignment)
    assert mem.nbytes == nbytes
    assert mem.alignment == alignment


def test_mkl_memory_create_with_calloc_and_alignment():
    size = 32
    num = 32
    nbytes = num * size
    alignment = 128
    mem = mkl.MKLMemory(num, size, alignment=alignment)
    assert mem.nbytes == nbytes


def test_mkl_memory_create_from_mkl_memory():
    mem1 = mkl.MKLMemory(1024)
    mem2 = mkl.MKLMemory(mem1)
    assert mem2.nbytes == mem1.nbytes


def test_mkl_memory_create_from_mkl_memory_with_alignment():
    mem1 = mkl.MKLMemory(1024)
    alignment = 128
    mem2 = mkl.MKLMemory(mem1, alignment=alignment)
    assert mem2.nbytes == mem1.nbytes
    assert mem2.alignment == alignment


def test_mkl_memory_propagates_alignment():
    mem1 = mkl.MKLMemory(1024, alignment=128)
    mem2 = mkl.MKLMemory(mem1)
    assert mem2.nbytes == mem1.nbytes
    assert mem2.alignment == mem1.alignment


def test_mkl_memory_properties():
    nbytes = 1024
    mem = mkl.MKLMemory(nbytes)
    assert len(mem) == nbytes
    assert type(repr(mem)) is str
    assert type(bytes(mem)) is bytes
    assert sys.getsizeof(mem) >= nbytes


def test_buffer_protocol():
    mem = mkl.MKLMemory(1024)
    mv1 = memoryview(mem)
    assert mv1.nbytes == mem.nbytes
    mv2 = memoryview(mem)
    assert mv1 == mv2


def test_pickling():
    import pickle

    mem = mkl.MKLMemory(1024)
    mv = memoryview(mem)
    for i in range(len(mem)):
        mv[i] = (i % 32) + ord("a")

    mem_reconstructed = pickle.loads(pickle.dumps(mem))
    assert type(mem) is type(mem_reconstructed), "Pickling should preserve type"
    assert (
        mem.tobytes() == mem_reconstructed.tobytes()
    ), "Pickling should preserve buffer content"
    assert (
        mem._pointer != mem_reconstructed._pointer
    ), "Pickling/unpickling should be changing pointer"


def test_pickling_with_alignment():
    import pickle

    mem = mkl.MKLMemory(1024, alignment=128)
    mem_reconstructed = pickle.loads(pickle.dumps(mem))
    assert type(mem) is type(mem_reconstructed), "Pickling should preserve type"
    assert (
        mem.tobytes() == mem_reconstructed.tobytes()
    ), "Pickling should preserve buffer content"
    assert (
        mem._pointer != mem_reconstructed._pointer
    ), "Pickling/unpickling should be changing pointer"
    assert (
        mem.alignment == mem_reconstructed.alignment
    ), "Pickling should preserve alignment"
