# Copyright (c) 2026, Intel Corporation
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
# cython: freethreading_compatible=True

import numbers

from cpython cimport Py_buffer
from libc.limits cimport INT_MAX
from libc.string cimport memcpy

from mkl._mkl_service cimport mkl_calloc, mkl_free, mkl_malloc, mkl_realloc


cdef extern from "stdatomic.h" nogil:
    ctypedef int atomic_int "_Atomic int"
    void atomic_init(atomic_int *obj, int value)
    int atomic_fetch_add(atomic_int *obj, int value)
    int atomic_fetch_sub(atomic_int *obj, int value)
    int atomic_load(atomic_int *obj)


cdef extern from *:
    """
    // Check whether a MKLMemory object may be safely reallocated.
    // Mirrors NumPy's PyArray_Resize_int logic.
    static int _MKLMemory_MayBeShared(PyObject *op) {
    #if PY_VERSION_HEX >= 0x030e00b0
        if (PyUnstable_Object_IsUniquelyReferenced(op)) {
            return 0; // not shared
        }
        if (Py_REFCNT(op) == 2) {
            return 1;  // may be shared
        }
        return 2;  // definitely shared
    #else
        return (Py_REFCNT(op) > 2) ? 2 : 0;
    #endif
    }
    """
    int _MKLMemory_MayBeShared(object obj)


cdef int _check_alignment(Py_ssize_t alignment) except -1:
    if alignment <= 0:
        raise ValueError("Alignment of requested allocation must be positive.")
    if alignment > <Py_ssize_t>INT_MAX:
        raise ValueError(
            f"Alignment of requested allocation must not exceed {INT_MAX}."
        )
    return <int>alignment


def _mkl_memory_from_bytes(bytes data, Py_ssize_t alignment):
    cdef Py_ssize_t nbytes = len(data)
    cdef MKLMemory mem = MKLMemory(nbytes, alignment=alignment)

    cdef void *dst = mem._memory_ptr
    cdef char *src = data

    with nogil:
        memcpy(dst, src, nbytes)

    return mem


cdef class MKLMemory:
    """MKL-backed memory object that exposes Python buffer protocol."""
    cdef void *_memory_ptr
    cdef Py_ssize_t _nbytes
    cdef Py_ssize_t _alignment
    cdef atomic_int exported_buffers

    cdef _cinit_empty(self):
        self._memory_ptr = NULL
        self._nbytes = 0
        self._alignment = 0
        atomic_init(&self.exported_buffers, 0)

    cdef _cinit_malloc(self, Py_ssize_t nbytes, Py_ssize_t alignment):
        cdef int c_alignment = _check_alignment(alignment)
        cdef void *p

        self._cinit_empty()

        if (nbytes > 0):
            with nogil:
                p = mkl_malloc(nbytes, c_alignment)

            if (p):
                self._memory_ptr = p
                self._nbytes = nbytes
                self._alignment = alignment
            else:
                raise MemoryError(
                    "MKL memory allocation failed."
                )
        else:
            raise ValueError(
                "Number of bytes of requested allocation must be positive."
            )

    cdef _cinit_calloc(self, Py_ssize_t num, Py_ssize_t size, Py_ssize_t alignment):
        cdef int c_alignment = _check_alignment(alignment)
        cdef void *p

        self._cinit_empty()

        if (num > 0 and size > 0):
            with nogil:
                p = mkl_calloc(num, size, c_alignment)

            if (p):
                self._memory_ptr = p
                self._nbytes = num * size
                self._alignment = alignment
            else:
                raise MemoryError(
                    "MKL memory allocation failed."
                )
        else:
            raise ValueError(
                "Number of elements and size of requested allocation must be "
                "positive."
            )

    cdef _cinit_mklmemory(self, object other, Py_ssize_t alignment):
        cdef MKLMemory other_mem = <MKLMemory> other

        self._cinit_malloc(other_mem._nbytes, alignment)
        with nogil:
            memcpy(self._memory_ptr, other_mem._memory_ptr, self._nbytes)

    def __cinit__(self, *args, **kwargs):
        cdef Py_ssize_t alignment

        n_args = len(args)
        if not (0 < n_args < 3):
            raise TypeError(
                "MKLMemory constructor takes 1 or 2 arguments, but "
                f"{n_args} were given"
            )
        if n_args == 1:
            arg = args[0]
            if isinstance(arg, numbers.Integral):
                alignment = kwargs.get("alignment", 64)
                self._cinit_malloc(arg, alignment)
            elif isinstance(arg, MKLMemory):
                alignment = kwargs.get("alignment", (<MKLMemory>arg)._alignment)
                self._cinit_mklmemory(arg, alignment)
            else:
                raise TypeError(
                    "MKLMemory single argument constructor expects an integer "
                    f"or MKLMemory instance, but got {type(arg)}"
                )

        elif n_args == 2:
            arg0, arg1 = args[0], args[1]
            alignment = kwargs.get("alignment", 64)
            if not isinstance(arg0, numbers.Integral):
                raise TypeError(
                    "MKLMemory constructor expects first argument "
                    f"to be an integer, but got {type(arg0)}"
                )
            if not isinstance(arg1, numbers.Integral):
                raise TypeError(
                    "MKLMemory constructor expects second argument "
                    f"to be an integer, but got {type(arg1)}"
                )
            self._cinit_calloc(arg0, arg1, alignment)

    def __dealloc__(self):
        if not (self._memory_ptr is NULL):
            mkl_free(self._memory_ptr)
        self._cinit_empty()

    cdef void *get_data_ptr(self):
        return self._memory_ptr

    def __getbuffer__(self, Py_buffer *buffer, int flags):
        buffer.buf = <void *>self._memory_ptr
        buffer.format = "B"
        buffer.internal = NULL
        buffer.itemsize = 1
        buffer.len = self._nbytes
        buffer.ndim = 1
        buffer.obj = self
        buffer.readonly = 0
        buffer.shape = &self._nbytes
        buffer.strides = &buffer.itemsize
        buffer.suboffsets = NULL

        atomic_fetch_add(&self.exported_buffers, 1)

    def __releasebuffer__(self, Py_buffer *buffer):
        atomic_fetch_sub(&self.exported_buffers, 1)

    def realloc(self, Py_ssize_t new_nbytes):
        cdef void *p
        cdef int shared

        if atomic_load(&self.exported_buffers) > 0:
            raise BufferError(
                "Cannot realloc memory while there are exported buffers."
            )
        shared = _MKLMemory_MayBeShared(self)
        if shared == 1:
            raise ValueError(
                "Cannot realloc MKLMemory that may be referenced by another "
                "object. It is possible that this is a false positive."
            )
        elif shared == 2:
            raise ValueError(
                "Cannot realloc MKLMemory that is referenced by other objects."
            )
        if new_nbytes <= 0:
            raise ValueError("New number of bytes must be positive.")

        with nogil:
            p = mkl_realloc(self._memory_ptr, new_nbytes)

        if not p:
            raise MemoryError("MKL memory reallocation failed.")

        self._memory_ptr = p
        self._nbytes = new_nbytes

    def tobytes(self):
        cdef char* data_ptr = <char*>self._memory_ptr
        return data_ptr[:self._nbytes]

    @property
    def nbytes(self):
        return self._nbytes

    @property
    def size(self):
        return self._nbytes

    @property
    def alignment(self):
        return self._alignment

    @property
    def _pointer(self):
        return <size_t>(self._memory_ptr)

    def __repr__(self):
        return (
            f"<MKL memory allocation of {self._nbytes} bytes at "
            f"{hex(<object>(<size_t>self._memory_ptr))}>"
        )

    def __len__(self):
        return self._nbytes

    def __sizeof__(self):
        return self._nbytes

    def __reduce__(self):
        return (_mkl_memory_from_bytes, (self.tobytes(), self._alignment))
