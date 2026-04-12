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

# distutils: language = c
# cython: language_level=3

import numbers

from cpython cimport Py_buffer
from libc.string cimport memcpy

from mkl._mkl_service cimport mkl_malloc, mkl_realloc, mkl_free

cdef extern from "stdatomic.h" nogil:
    ctypedef int atomic_int "_Atomic int"
    void atomic_init(atomic_int *obj, int value)
    int atomic_fetch_add(atomic_int *obj, int value)
    int atomic_fetch_sub(atomic_int *obj, int value)
    int atomic_load(atomic_int *obj)


cdef class MKLMemory:
    cdef void *_memory_ptr
    cdef Py_ssize_t nbytes
    cdef atomic_int exported_buffers

    cdef _cinit_empty(self):
        self._memory_ptr = NULL
        self.nbytes = 0
        atomic_init(&self.exported_buffers, 0)

    cdef _cinit_alloc(self, Py_ssize_t nbytes, Py_ssize_t alignment):
        self._cinit_empty()

        if (nbytes > 0):
            with nogil:
                p = mkl_malloc(nbytes, alignment)

            if (p):
                self._memory_ptr = p
                self.nbytes = nbytes
            else:
                raise MemoryError(
                    "MKL memory allocation failed."
                )
        else:
            raise ValueError(
                "Number of bytes of request allocation must be positive."
            )

    cdef _cinit_other(self, object other, Py_ssize_t alignment):
        cdef MKLMemory other_mem
        if isinstance(other, MKLMemory):
            other_mem = <MKLMemory> other
        else:
            raise ValueError(
                f"Argument {other} is not of type MKLMemory."
            )
        self._cinit_alloc(other_mem.nbytes, alignment)
        with nogil:
            memcpy(self._memory_ptr, other_mem._memory_ptr, self.nbytes)

    def __cinit__(self, other, *, Py_ssize_t alignment=64):
        if isinstance(other, numbers.Integral):
            self._cinit_alloc(other, alignment)
        else:
            self._cinit_other(other, alignment)

    def __dealloc__(self):
        if not (self._memory_ptr is NULL):
            mkl_free(self._memory_ptr)
        self._cinit_empty()

    cdef void *get_data_ptr(self):
        return self._memory_ptr

    def __getbuffer__(self, Py_buffer *buffer, int flags):
        buffer.buf = <void *>self._memory_ptr
        buffer.format = "B"                     # byte
        buffer.internal = NULL                  # see References
        buffer.itemsize = 1
        buffer.len = self.nbytes
        buffer.ndim = 1
        buffer.obj = self
        buffer.readonly = 0
        buffer.shape = &self.nbytes
        buffer.strides = &buffer.itemsize
        buffer.suboffsets = NULL                # for pointer arrays only

        atomic_fetch_add(&self.exported_buffers, 1)

    def __releasebuffer__(self, Py_buffer *buffer):
        atomic_fetch_sub(&self.exported_buffers, 1)

    def realloc(self, Py_ssize_t new_nbytes):
        if atomic_load(&self.exported_buffers) > 0:
            raise BufferError("Cannot realloc memory while there are exported buffers.")
        if new_nbytes <= 0:
            raise ValueError("New number of bytes must be positive.")

        cdef void *p
        with nogil:
            p = mkl_realloc(self._memory_ptr, new_nbytes)

        if not p:
            raise MemoryError("MKL memory reallocation failed.")

        self._memory_ptr = p
        self.nbytes = new_nbytes
