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
from cpython.buffer cimport PyBuffer_FillInfo
from libc.limits cimport INT_MAX
from libc.string cimport memcpy

from mkl._mkl_service cimport mkl_calloc, mkl_free, mkl_malloc, mkl_realloc


cdef extern from "Python.h":
    const Py_ssize_t PY_SSIZE_T_MAX


cdef extern from "stdatomic.h" nogil:
    ctypedef int atomic_int "_Atomic int"
    void atomic_init(atomic_int *obj, int value)
    int atomic_fetch_add(atomic_int *obj, int value)
    int atomic_fetch_sub(atomic_int *obj, int value)
    int atomic_load(atomic_int *obj)
    void atomic_store(atomic_int *obj, int value)
    bint atomic_compare_exchange_strong(
        atomic_int *obj, int *expected, int desired
    )


cdef extern from *:
    """
    // Check whether a MKLMemory object may be safely reallocated
    // Mirrors NumPy's PyArray_Resize_int logic
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


cdef _extract_alignment(dict kwargs, object default):
    """
    Return the ``alignment`` keyword, or `default` when it was not given.
    """
    for name in kwargs:
        if name != "alignment":
            raise TypeError(
                "MKLMemory constructor got an unexpected keyword argument "
                f"'{name}'"
            )

    return kwargs.get("alignment", default)


cdef int _check_alignment(object alignment) except -1:
    cdef int c_alignment

    if not isinstance(alignment, numbers.Integral):
        raise TypeError(
            "Alignment of requested allocation must be an integer, but got "
            f"{type(alignment)}"
        )
    if alignment <= 0:
        raise ValueError("Alignment of requested allocation must be positive.")
    if alignment > INT_MAX:
        raise ValueError(
            f"Alignment of requested allocation must not exceed {INT_MAX}."
        )

    c_alignment = <int>alignment
    if c_alignment & (c_alignment - 1):
        raise ValueError(
            "Alignment of requested allocation must be a power of two, but got "
            f"{c_alignment}."
        )

    return c_alignment


def _mkl_memory_from_bytes(bytes data, Py_ssize_t alignment, cls=None):
    cdef Py_ssize_t nbytes = len(data)
    cdef MKLMemory mem
    cdef void *dst
    cdef char *src = data

    if cls is None:
        cls = MKLMemory
    elif not (isinstance(cls, type) and issubclass(cls, MKLMemory)):
        raise TypeError(f"{cls} is not a subclass of MKLMemory")

    mem = cls(nbytes, alignment=alignment)
    dst = mem._memory_ptr

    with nogil:
        memcpy(dst, src, nbytes)

    return mem


cdef class MKLMemory:
    """
    MKLMemory(nbytes, alignment=64)
    MKLMemory(num, elem_size, alignment=64)
    MKLMemory(other, alignment=other.alignment)

    An object representing an aligned allocation made by oneMKL's allocator,
    exposed through the Python buffer protocol.

    The first form allocates ``nbytes`` uninitialized bytes with
    ``mkl_malloc``, the second ``num * elem_size`` zeroed bytes with
    ``mkl_calloc``, and the third a copy of the content of another
    :class:`MKLMemory`.

    Args:
        nbytes (int):
            number of bytes to allocate.
            Expected to be positive.
        num (int):
            number of elements to allocate.
            Expected to be positive.
        elem_size (int):
            size of a single element in bytes.
            Expected to be positive.
        other (:class:`MKLMemory`):
            allocation whose size and content the new allocation takes.
        alignment (Optional[int]):
            address alignment of the allocation in bytes. Expected to be a
            power of two and to not exceed ``INT_MAX``. Defaults to the
            alignment of ``other`` in the copy form, and to `64` otherwise.
    """
    cdef void *_memory_ptr
    cdef Py_ssize_t _nbytes
    cdef Py_ssize_t _alignment
    cdef atomic_int exported_buffers
    # prevents simultaneous reallocs
    cdef atomic_int realloc_in_progress

    cdef _cinit_empty(self):
        self._memory_ptr = NULL
        self._nbytes = 0
        self._alignment = 0
        atomic_init(&self.exported_buffers, 0)
        atomic_init(&self.realloc_in_progress, 0)

    cdef _cinit_malloc(self, Py_ssize_t nbytes, object alignment):
        cdef int c_alignment = _check_alignment(alignment)
        cdef void *p

        self._cinit_empty()

        if (nbytes > 0):
            with nogil:
                p = mkl_malloc(nbytes, c_alignment)

            if (p):
                self._memory_ptr = p
                self._nbytes = nbytes
                self._alignment = c_alignment
            else:
                raise MemoryError(
                    "MKL memory allocation failed."
                )
        else:
            raise ValueError(
                "Number of bytes of requested allocation must be positive."
            )

    cdef _cinit_calloc(
        self, Py_ssize_t num, Py_ssize_t elem_size, object alignment
    ):
        cdef int c_alignment = _check_alignment(alignment)
        cdef Py_ssize_t nbytes
        cdef void *p

        self._cinit_empty()

        if (num > 0 and elem_size > 0):
            if num > PY_SSIZE_T_MAX // elem_size:
                raise ValueError(
                    "Total size of requested allocation must not exceed "
                    f"{PY_SSIZE_T_MAX} bytes."
                )
            nbytes = num * elem_size

            with nogil:
                p = mkl_calloc(num, elem_size, c_alignment)

            if (p):
                self._memory_ptr = p
                self._nbytes = nbytes
                self._alignment = c_alignment
            else:
                raise MemoryError(
                    "MKL memory allocation failed."
                )
        else:
            raise ValueError(
                "Number of elements and element size of requested allocation "
                "must be positive."
            )

    cdef _cinit_mklmemory(self, object other, object alignment):
        cdef MKLMemory other_mem = <MKLMemory> other

        atomic_fetch_add(&other_mem.exported_buffers, 1)
        try:
            self._cinit_malloc(other_mem._nbytes, alignment)
            with nogil:
                memcpy(self._memory_ptr, other_mem._memory_ptr, self._nbytes)
        finally:
            atomic_fetch_sub(&other_mem.exported_buffers, 1)

    def __cinit__(self, *args, **kwargs):
        n_args = len(args)
        if not (0 < n_args < 3):
            raise TypeError(
                "MKLMemory constructor takes 1 or 2 arguments, but "
                f"{n_args} were given"
            )
        if n_args == 1:
            arg = args[0]
            if isinstance(arg, numbers.Integral):
                alignment = _extract_alignment(kwargs, 64)
                self._cinit_malloc(arg, alignment)
            elif isinstance(arg, MKLMemory):
                alignment = _extract_alignment(
                    kwargs, (<MKLMemory>arg)._alignment
                )
                self._cinit_mklmemory(arg, alignment)
            else:
                raise TypeError(
                    "MKLMemory single argument constructor expects an integer "
                    f"or MKLMemory instance, but got {type(arg)}"
                )

        elif n_args == 2:
            arg0, arg1 = args[0], args[1]
            alignment = _extract_alignment(kwargs, 64)
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
        atomic_fetch_add(&self.exported_buffers, 1)
        try:
            PyBuffer_FillInfo(
                buffer, self, self._memory_ptr, self._nbytes, 0, flags
            )
        except BaseException:
            atomic_fetch_sub(&self.exported_buffers, 1)
            raise

    def __releasebuffer__(self, Py_buffer *buffer):
        atomic_fetch_sub(&self.exported_buffers, 1)

    def realloc(self, Py_ssize_t new_nbytes, *, bint refcheck=True):
        """
        realloc(new_nbytes, refcheck=True)

        Resizes this allocation in place, keeping the content that fits.

        Args:
            new_nbytes (int):
                new size of the allocation in bytes.
                Expected to be positive.
            refcheck (Optional[bool]):
                whether to refuse the resize when this object appears to be
                referenced from elsewhere.
                Default: `True`.

        Resizing moves the underlying memory, so any other reference to this
        object would be left pointing at freed memory. The check for such
        references is a heuristic based on the reference count and can refuse a
        resize that would have been safe, especially in the case of a reference
        reachable from more than one thread.

        Passing ``refcheck=False`` skips that check, and it is the caller's
        responsibility to ensure that nothing else refers to this object and
        that no other thread can reach it until the call returns.

        Neither the check nor its absence is a substitute for locking. Under the
        GIL, and on free-threaded builds from Python 3.14 where the object can
        be asked whether it is uniquely referenced, nothing else can reach the
        object between the check and the resize. On a free-threaded build before
        3.14 there is neither, and a reference the caller holds cannot be told
        apart from one another thread holds: resizing an allocation another
        thread can reach may leave that thread reading freed memory whatever
        ``refcheck`` is set to, so arrange for exclusive access.
        """
        cdef void *p
        cdef int shared
        cdef int unclaimed = 0

        if new_nbytes <= 0:
            raise ValueError("New number of bytes must be positive.")

        # claim the exclusive right to reallocate before doing anything else
        if not atomic_compare_exchange_strong(
            &self.realloc_in_progress, &unclaimed, 1
        ):
            raise BufferError(
                "Cannot realloc memory while another thread is reallocating it."
            )
        try:
            if atomic_load(&self.exported_buffers) > 0:
                raise BufferError(
                    "Cannot realloc memory while there are exported buffers."
                )
            if refcheck:
                shared = _MKLMemory_MayBeShared(self)
                if shared == 1:
                    raise ValueError(
                        "Cannot realloc MKLMemory that may be referenced by "
                        "another object. It is possible that this is a false "
                        "positive. If you are sure that this MKLMemory is "
                        "uniquely referenced, pass refcheck=False."
                    )
                elif shared == 2:
                    raise ValueError(
                        "Cannot realloc MKLMemory that is referenced by other "
                        "objects. Pass refcheck=False to realloc anyway, at the "
                        "risk of leaving those references pointing at freed "
                        "memory."
                    )
            # do not release the GIL here, as that can allow another thread to
            # read from or export a buffer with the old pointer before
            # mkl_realloc frees it
            p = mkl_realloc(self._memory_ptr, new_nbytes)

            if not p:
                raise MemoryError("MKL memory reallocation failed.")

            self._memory_ptr = p
            self._nbytes = new_nbytes
        finally:
            atomic_store(&self.realloc_in_progress, 0)

    def tobytes(self):
        """
        Constructs bytes object populated with copy of this allocation.
        """
        cdef char* data_ptr = <char*>self._memory_ptr
        return data_ptr[:self._nbytes]

    @property
    def nbytes(self):
        """Extent of this allocation in bytes."""
        return self._nbytes

    @property
    def alignment(self):
        """Address alignment of this allocation in bytes, as requested."""
        return self._alignment

    @property
    def _pointer(self):
        """
        Pointer to the start of this allocation
        represented as Python integer.
        """
        return <size_t>(self._memory_ptr)

    def __repr__(self):
        return (
            f"<MKL memory allocation of {self._nbytes} bytes at "
            f"{hex(self._pointer)}>"
        )

    def __len__(self):
        return self._nbytes

    def __sizeof__(self):
        return object.__sizeof__(self) + self._nbytes

    def __reduce__(self):
        cdef type cls = type(self)

        # a subclass should come back as itself
        if cls is MKLMemory:
            args = (self.tobytes(), self._alignment)
        else:
            args = (self.tobytes(), self._alignment, cls)

        return (_mkl_memory_from_bytes, args, getattr(self, "__dict__", None))
