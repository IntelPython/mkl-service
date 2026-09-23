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

import numbers
import sys
import threading

import pytest

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
    # mkl_calloc hands back zeroed memory
    assert mem.tobytes() == bytes(nbytes)


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
    assert mem.alignment == alignment


def test_mkl_memory_create_from_mkl_memory():
    mem1 = mkl.MKLMemory(1024)
    mv = memoryview(mem1)
    for i in range(len(mem1)):
        mv[i] = (i * 5 + 1) % 256
    mv.release()

    mem2 = mkl.MKLMemory(mem1)
    assert mem2.nbytes == mem1.nbytes
    assert mem2.tobytes() == mem1.tobytes()
    assert mem2._pointer != mem1._pointer

    mv = memoryview(mem2)
    mv[0] = mem1.tobytes()[0] ^ 0xFF
    mv.release()
    assert mem2.tobytes()[0] != mem1.tobytes()[0]
    assert mem1.tobytes()[0] == (0 * 5 + 1) % 256


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


class _AlignmentProbe:
    def __init__(self, value, callback):
        self._value = value
        self._callback = callback
        self._fired = False

    def __le__(self, other):
        return self._value <= other

    def __gt__(self, other):
        return self._value > other

    def _convert(self):
        if not self._fired:
            self._fired = True
            self._callback()
        return self._value

    def __int__(self):
        return self._convert()

    def __index__(self):
        return self._convert()


numbers.Integral.register(_AlignmentProbe)


def test_realloc_refused_while_copy_reads_source():
    source = mkl.MKLMemory(1024)
    mv = memoryview(source)
    for i in range(len(source)):
        mv[i] = (i * 7 + 3) % 256
    mv.release()
    pattern = source.tobytes()

    outcome = []

    def probe():
        try:
            source.realloc(256, refcheck=False)
            outcome.append("resized")
        except BufferError:
            outcome.append("refused")

    copy = mkl.MKLMemory(source, alignment=_AlignmentProbe(64, probe))

    assert outcome == ["refused"], f"resize was not refused: {outcome}"
    assert source.nbytes == 1024
    assert copy.nbytes == 1024
    assert copy.alignment == 64
    assert copy.tobytes() == pattern


def test_copy_constructor_releases_source_claim():
    mem = mkl.MKLMemory(1024)
    copy = mkl.MKLMemory(mem)
    assert copy.nbytes == mem.nbytes
    mem.realloc(2048, refcheck=False)
    assert mem.nbytes == 2048


def test_copy_constructor_releases_source_claim_on_failure():
    mem = mkl.MKLMemory(1024)
    with pytest.raises(ValueError, match="Alignment"):
        mkl.MKLMemory(mem, alignment=-1)
    mem.realloc(2048, refcheck=False)
    assert mem.nbytes == 2048


def test_sizeof_accounts_for_object_too():
    small, large = 1024, 1 << 20
    mem, big = mkl.MKLMemory(small), mkl.MKLMemory(large)

    assert big.__sizeof__() - mem.__sizeof__() == large - small
    overhead = mem.__sizeof__() - small
    assert overhead > 0
    assert big.__sizeof__() - large == overhead

    assert sys.getsizeof(mem) >= mem.__sizeof__()

    mem.realloc(large)
    assert mem.__sizeof__() == big.__sizeof__()


def test_buffer_protocol():
    mem = mkl.MKLMemory(1024)
    mv1 = memoryview(mem)
    mv2 = memoryview(mem)
    try:
        assert mv1.nbytes == mem.nbytes
        mv1[0] = 7
        assert mv2[0] == 7
        mv2[1] = 9
        assert mv1[1] == 9

        with pytest.raises(BufferError, match="exported buffers"):
            mem.realloc(2048, refcheck=False)
        mv1.release()
        with pytest.raises(BufferError, match="exported buffers"):
            mem.realloc(2048, refcheck=False)
    finally:
        mv2.release()

    mem.realloc(2048, refcheck=False)
    assert mem.nbytes == 2048


def test_exported_buffer_describes_a_flat_writable_block():
    mem = mkl.MKLMemory(1024)
    mv = memoryview(mem)
    try:
        assert mv.obj is mem
        assert mv.format == "B"
        assert mv.itemsize == 1
        assert mv.ndim == 1
        assert mv.shape == (mem.nbytes,)
        assert mv.strides == (1,)
        assert mv.suboffsets == ()
        assert not mv.readonly
        assert mv.c_contiguous and mv.f_contiguous
        mv[0] = 7
        assert mem.tobytes()[0] == 7
    finally:
        mv.release()


def test_each_export_gives_back_its_reference():
    mem = mkl.MKLMemory(64)
    before = sys.getrefcount(mem)
    for _ in range(200):
        memoryview(mem).release()

    assert sys.getrefcount(mem) == before
    mem.realloc(128, refcheck=False)
    assert mem.nbytes == 128


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


class _MKLMemorySubclass(mkl.MKLMemory):
    pass


def test_pickling_preserves_subclass():
    import pickle

    mem = _MKLMemorySubclass(1024, alignment=128)
    mv = memoryview(mem)
    mv[:] = bytes((i * 3 + 1) % 256 for i in range(len(mem)))
    mv.release()

    reconstructed = pickle.loads(pickle.dumps(mem))
    assert type(reconstructed) is _MKLMemorySubclass
    assert reconstructed.nbytes == mem.nbytes
    assert reconstructed.alignment == 128
    assert reconstructed.tobytes() == mem.tobytes()


def test_pickling_preserves_subclass_attributes():
    import pickle

    mem = _MKLMemorySubclass(256)
    mem.label = "kept"
    reconstructed = pickle.loads(pickle.dumps(mem))
    assert reconstructed.label == "kept"


def test_reconstruct_rejects_foreign_class():
    # pylint: disable-next=no-name-in-module
    from mkl._mkl_memory import _mkl_memory_from_bytes

    with pytest.raises(TypeError, match="not a subclass of MKLMemory"):
        _mkl_memory_from_bytes(b"abcd", 64, bytearray)
    with pytest.raises(TypeError, match="not a subclass of MKLMemory"):
        _mkl_memory_from_bytes(b"abcd", 64, "not a class")

    mem = _mkl_memory_from_bytes(b"abcd", 64)
    assert type(mem) is mkl.MKLMemory
    assert mem.tobytes() == b"abcd"


def test_realloc_grow_and_shrink_preserves_data():
    mem = mkl.MKLMemory(1024)
    mv = memoryview(mem)
    for i in range(len(mem)):
        mv[i] = i % 256
    mv.release()
    original = mem.tobytes()

    grown = 1 << 20
    mem.realloc(grown)
    assert mem.nbytes == grown
    assert len(mem) == grown
    assert len(mem.tobytes()) == grown
    assert mem.tobytes()[:1024] == original

    mem.realloc(256)
    assert mem.nbytes == 256
    assert len(mem) == 256
    # shrinking keeps the surviving prefix
    assert mem.tobytes() == original[:256]

    mv = memoryview(mem)
    try:
        mv[0] = 7
        mv[len(mem) - 1] = 9
    finally:
        mv.release()
    assert mem.tobytes()[0] == 7
    assert mem.tobytes()[-1] == 9


@pytest.mark.parametrize("alignment", [64, 128, 4096])
def test_realloc_preserves_alignment(alignment):
    # test that alignment is preserved by realloc
    mem = mkl.MKLMemory(1024, alignment=alignment)
    assert mem._pointer % alignment == 0
    for nbytes in (1 << 20, 256):
        mem.realloc(nbytes)
        assert mem.alignment == alignment
        assert mem._pointer % alignment == 0


def test_realloc_refcheck_shared():
    mem = mkl.MKLMemory(1024)
    alias = mem  # noqa: F841
    with pytest.raises(ValueError, match="referenced by"):
        mem.realloc(2048)
    del alias


def test_realloc_refcheck_false_allows_shared():
    mem = mkl.MKLMemory(1024)
    mv = memoryview(mem)
    for i in range(len(mem)):
        mv[i] = i % 256
    del mv

    alias = mem  # noqa: F841
    with pytest.raises(ValueError, match="refcheck=False"):
        mem.realloc(2048)
    mem.realloc(2048, refcheck=False)
    assert mem.nbytes == 2048
    assert len(mem) == 2048
    # the leading bytes must be preserved
    assert mem.tobytes()[:256] == bytes(range(256))
    del alias


def test_realloc_refcheck_false_still_refuses_exported_buffer():
    mem = mkl.MKLMemory(1024)
    mv = memoryview(mem)
    try:
        with pytest.raises(BufferError):
            mem.realloc(2048, refcheck=False)
        assert mem.nbytes == 1024
    finally:
        mv.release()
    mem.realloc(2048, refcheck=False)
    assert mem.nbytes == 2048


@pytest.mark.parametrize("new_nbytes", [0, -1])
def test_realloc_validates_size_before_state(new_nbytes):
    match = "New number of bytes must be positive"
    mem = mkl.MKLMemory(1024)
    mv = memoryview(mem)
    try:
        with pytest.raises(ValueError, match=match):
            mem.realloc(new_nbytes)
        with pytest.raises(ValueError, match=match):
            mem.realloc(new_nbytes, refcheck=False)
    finally:
        mv.release()

    held = mem
    with pytest.raises(ValueError, match=match):
        held.realloc(new_nbytes)

    assert mem.nbytes == 1024
    mem.realloc(2048, refcheck=False)
    assert mem.nbytes == 2048


def test_realloc_refcheck_is_keyword_only():
    mem = mkl.MKLMemory(1024)
    with pytest.raises(TypeError):
        mem.realloc(2048, False)
    assert mem.nbytes == 1024


def test_failed_realloc_leaves_the_allocation_untouched():
    mem = mkl.MKLMemory(1024, alignment=128)
    mv = memoryview(mem)
    mv[:] = bytes((i * 11 + 5) % 256 for i in range(len(mem)))
    mv.release()

    pointer, nbytes = mem._pointer, mem.nbytes
    alignment, pattern = mem.alignment, mem.tobytes()

    def assert_untouched():
        assert mem._pointer == pointer
        assert mem.nbytes == nbytes
        assert len(mem) == nbytes
        assert mem.alignment == alignment
        assert mem.tobytes() == pattern

    with pytest.raises(ValueError, match="must be positive"):
        mem.realloc(0, refcheck=False)
    assert_untouched()

    mv = memoryview(mem)
    try:
        with pytest.raises(BufferError, match="exported buffers"):
            mem.realloc(2048, refcheck=False)
    finally:
        mv.release()
    assert_untouched()

    held = mem  # noqa: F841
    with pytest.raises(ValueError, match="Cannot realloc MKLMemory"):
        mem.realloc(2048)
    assert_untouched()

    with pytest.raises(TypeError):
        mem.realloc(2048, False)
    assert_untouched()

    mem.realloc(4096, refcheck=False)
    assert mem.nbytes == 4096
    assert mem.alignment == alignment
    assert mem.tobytes()[:nbytes] == pattern


def test_constructor_argument_count():
    with pytest.raises(TypeError, match="takes 1 or 2 arguments"):
        mkl.MKLMemory()
    with pytest.raises(TypeError, match="takes 1 or 2 arguments"):
        mkl.MKLMemory(32, 32, 32)


@pytest.mark.parametrize("arg", ["1024", 1024.0, None, 1024j, [1024], {}])
def test_constructor_single_argument_type(arg):
    with pytest.raises(TypeError, match="expects an integer or MKLMemory"):
        mkl.MKLMemory(arg)


@pytest.mark.parametrize("arg", ["32", 32.0, None, 32j, [32]])
def test_constructor_two_argument_types(arg):
    with pytest.raises(TypeError, match="first argument"):
        mkl.MKLMemory(arg, 32)
    with pytest.raises(TypeError, match="second argument"):
        mkl.MKLMemory(32, arg)


@pytest.mark.parametrize("nbytes", [0, -1])
def test_malloc_rejects_non_positive_size(nbytes):
    with pytest.raises(ValueError, match="must be positive"):
        mkl.MKLMemory(nbytes)


@pytest.mark.parametrize(
    "num,elem_size", [(0, 32), (32, 0), (0, 0), (-1, 32), (32, -1), (-1, -1)]
)
def test_calloc_rejects_non_positive_size(num, elem_size):
    with pytest.raises(ValueError, match="must be positive"):
        mkl.MKLMemory(num, elem_size)


def test_calloc_total_size_overflow_validation():
    with pytest.raises(ValueError, match="must not exceed"):
        mkl.MKLMemory(2**32, 2**32)
    with pytest.raises(ValueError, match="must not exceed"):
        mkl.MKLMemory(sys.maxsize, 2)
    with pytest.raises(ValueError, match="must not exceed"):
        mkl.MKLMemory(2, sys.maxsize)
    with pytest.raises(ValueError, match="must not exceed"):
        mkl.MKLMemory(sys.maxsize // 2 + 1, 2)


@pytest.mark.parametrize(
    "construct",
    [
        lambda alignment: mkl.MKLMemory(1024, alignment=alignment),
        lambda alignment: mkl.MKLMemory(32, 32, alignment=alignment),
        lambda alignment: mkl.MKLMemory(mkl.MKLMemory(64), alignment=alignment),
    ],
    ids=["malloc", "calloc", "copy"],
)
def test_alignment_validation(construct):
    with pytest.raises(ValueError, match="positive"):
        construct(0)
    with pytest.raises(ValueError, match="positive"):
        construct(-1)
    with pytest.raises(ValueError, match="must not exceed"):
        construct(2**40)
    with pytest.raises(ValueError, match="must not exceed"):
        construct(2**100)


@pytest.mark.parametrize("alignment", [3, 5, 12, 24, 96, 100, 129, 1000])
@pytest.mark.parametrize(
    "construct",
    [
        lambda alignment: mkl.MKLMemory(1024, alignment=alignment),
        lambda alignment: mkl.MKLMemory(32, 32, alignment=alignment),
        lambda alignment: mkl.MKLMemory(mkl.MKLMemory(64), alignment=alignment),
    ],
    ids=["malloc", "calloc", "copy"],
)
def test_alignment_must_be_a_power_of_two(construct, alignment):
    with pytest.raises(ValueError, match="must be a power of two"):
        construct(alignment)


@pytest.mark.parametrize(
    "alignment", [1, 2, 4, 8, 16, 32, 64, 128, 256, 4096, 1 << 20]
)
def test_powers_of_two_are_honored(alignment):
    for mem in (
        mkl.MKLMemory(1024, alignment=alignment),
        mkl.MKLMemory(32, 32, alignment=alignment),
        mkl.MKLMemory(mkl.MKLMemory(64), alignment=alignment),
    ):
        assert mem.alignment == alignment
        assert mem._pointer % alignment == 0


@pytest.mark.parametrize("alignment", ["64", 64.0, None, 64j, [64]])
def test_alignment_type_validation(alignment):
    with pytest.raises(TypeError, match="must be an integer"):
        mkl.MKLMemory(1024, alignment=alignment)
    with pytest.raises(TypeError, match="must be an integer"):
        mkl.MKLMemory(32, 32, alignment=alignment)
    with pytest.raises(TypeError, match="must be an integer"):
        mkl.MKLMemory(mkl.MKLMemory(64), alignment=alignment)


def test_unexpected_keyword_argument():
    keyword = "align"
    match = f"unexpected keyword argument '{keyword}'"
    with pytest.raises(TypeError, match=match):
        mkl.MKLMemory(1024, **{keyword: 128})
    with pytest.raises(TypeError, match=match):
        mkl.MKLMemory(32, 32, **{keyword: 128})
    with pytest.raises(TypeError, match=match):
        mkl.MKLMemory(mkl.MKLMemory(64, alignment=128), **{keyword: 256})


def test_concurrent_reads():
    mem = mkl.MKLMemory(1024)
    mv = memoryview(mem)
    for i in range(len(mem)):
        mv[i] = i % 256
    del mv

    errors = []

    def reader():
        try:
            for _ in range(500):
                assert len(mem) == 1024
                data = mem.tobytes()
                assert len(data) == 1024
                v = memoryview(mem)
                assert v[0] == 0
                v.release()
        except Exception as e:
            errors.append(e)

    ts = [threading.Thread(target=reader) for _ in range(4)]
    for t in ts:
        t.start()
    for t in ts:
        t.join()
    assert not errors, f"Concurrent read errors: {errors}"


def _concurrent_realloc_round(initial, sizes):
    mem = mkl.MKLMemory(initial)
    barrier = threading.Barrier(len(sizes))
    results = [None] * len(sizes)

    def worker(idx, size):
        barrier.wait()
        try:
            mem.realloc(size, refcheck=False)
            results[idx] = "ok"
        except BufferError:
            results[idx] = "refused"

    ts = [
        threading.Thread(target=worker, args=(idx, size))
        for idx, size in enumerate(sizes)
    ]
    for t in ts:
        t.start()
    for t in ts:
        t.join()

    return mem, results


def test_concurrent_realloc_leaves_a_consistent_allocation():
    initial = 64
    sizes = (1 << 16, 1 << 17)

    for _ in range(50):
        mem, results = _concurrent_realloc_round(initial, sizes)

        assert all(
            r in ("ok", "refused") for r in results
        ), f"realloc raised an unexpected error: {results}"
        assert "ok" in results, f"no realloc completed: {results}"
        assert len(mem) in sizes, f"Inconsistent size {len(mem)} from {results}"
        assert mem.nbytes == len(mem)
        assert len(mem.tobytes()) == len(mem)

        mv = memoryview(mem)
        try:
            mv[0] = 1
            mv[len(mem) - 1] = 2
        finally:
            mv.release()


def test_concurrent_reads_across_reallocs():
    sizes = [1 << 12, 1 << 13, 1 << 12, 1 << 14, 1 << 12]
    n_readers = 3
    reads_per_round = 50
    mem = mkl.MKLMemory(sizes[0])
    errors = []
    resizes = 0

    def fill(value):
        mv = memoryview(mem)
        try:
            mv[:] = bytes([value]) * len(mv)
        finally:
            mv.release()

    quiesce = threading.Barrier(n_readers + 1, timeout=60)
    fill(0xA5)

    def reader():
        try:
            for _ in sizes:
                for _ in range(reads_per_round):
                    mv = memoryview(mem)
                    try:
                        n = mv.nbytes
                        assert n == mem.nbytes
                        data = bytes(mv)
                    finally:
                        mv.release()
                    assert data == data[:1] * n, "view spans two blocks"

                    copy = mem.tobytes()
                    assert len(copy) == n
                    assert copy == data
                quiesce.wait()  # no reader is inside `mem` past this point
                quiesce.wait()  # the resize is done
        except threading.BrokenBarrierError:  # pragma: no cover - on failure
            pass
        except Exception as e:  # pragma: no cover - only on failure
            errors.append(e)
            quiesce.abort()

    def resizer():
        nonlocal resizes
        try:
            for round_ in range(len(sizes)):
                quiesce.wait()
                if round_ + 1 < len(sizes):
                    mem.realloc(sizes[round_ + 1], refcheck=False)
                    resizes += 1
                    fill(round_ + 1)
                quiesce.wait()
        except threading.BrokenBarrierError:  # pragma: no cover - on failure
            pass
        except Exception as e:  # pragma: no cover - only on failure
            errors.append(e)
            quiesce.abort()

    ts = [threading.Thread(target=reader) for _ in range(n_readers)]
    ts.append(threading.Thread(target=resizer))
    for t in ts:
        t.start()
    for t in ts:
        t.join()

    assert not errors, f"Concurrent realloc/read errors: {errors}"
    assert resizes == len(sizes) - 1
    assert mem.nbytes == sizes[-1] == len(mem)
