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

import sys
import threading

import pytest

import mkl

# on free-threaded Python prior to 3.14, only the caller can ensure exclusive
# access during realloc
_GIL_ENABLED = getattr(sys, "_is_gil_enabled", lambda: True)()
REALLOC_RACE_IS_CONTAINED = _GIL_ENABLED or sys.version_info >= (3, 14)


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
    assert mem.alignment == alignment


@pytest.mark.parametrize("alignment", [64, 128, 256])
def test_allocation_is_actually_aligned(alignment):
    assert mkl.MKLMemory(1024, alignment=alignment)._pointer % alignment == 0
    assert mkl.MKLMemory(32, 32, alignment=alignment)._pointer % alignment == 0
    source = mkl.MKLMemory(1024, alignment=alignment)
    assert mkl.MKLMemory(source)._pointer % alignment == 0


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
    # growing keeps every byte that was there
    assert mem.tobytes()[:1024] == original

    mem.realloc(256)
    assert mem.nbytes == 256
    assert len(mem) == 256
    # shrinking keeps the surviving prefix
    assert mem.tobytes() == original[:256]

    # and the resized buffer is still writable through the buffer protocol
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
    # test that alignment is preserved by realloc, which is undocumented in MKL
    # but holds experimentally
    mem = mkl.MKLMemory(1024, alignment=alignment)
    assert mem._pointer % alignment == 0
    for nbytes in (1 << 20, 256):
        mem.realloc(nbytes)
        assert mem.alignment == alignment
        assert mem._pointer % alignment == 0


def test_realloc_exported_buffer():
    mem = mkl.MKLMemory(1024)
    mv = memoryview(mem)
    with pytest.raises(BufferError):
        mem.realloc(2048)
    del mv


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
    # the leading bytes must have survived the move
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


def test_realloc_validates_size():
    mem = mkl.MKLMemory(1024)
    with pytest.raises(ValueError, match="positive"):
        mem.realloc(0, refcheck=False)
    with pytest.raises(ValueError, match="positive"):
        mem.realloc(-1, refcheck=False)
    assert mem.nbytes == 1024


def test_realloc_refcheck_is_keyword_only():
    mem = mkl.MKLMemory(1024)
    with pytest.raises(TypeError):
        mem.realloc(2048, False)
    assert mem.nbytes == 1024


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


def test_alignment_keyword_still_accepted():
    assert mkl.MKLMemory(1024, alignment=128).alignment == 128
    assert mkl.MKLMemory(32, 32, alignment=128).alignment == 128
    source = mkl.MKLMemory(64, alignment=128)
    assert mkl.MKLMemory(source).alignment == 128
    assert mkl.MKLMemory(source, alignment=256).alignment == 256


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


def test_concurrent_realloc_never_overlaps():
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


@pytest.mark.skipif(
    not REALLOC_RACE_IS_CONTAINED,
    reason=(
        "before 3.14 a free-threaded build cannot establish unique ownership, "
        "so keeping readers off a resized allocation is the caller's job"
    ),
)
def test_concurrent_realloc_and_reads():
    mem = mkl.MKLMemory(64)
    stop = threading.Event()
    errors = []

    def reader():
        try:
            while not stop.is_set():
                mv = memoryview(mem)
                try:
                    n = mv.nbytes
                    assert n > 0
                    # touch both ends of whatever block was handed out
                    mv[0] = 1
                    mv[n - 1] = 2
                finally:
                    mv.release()
                assert len(mem.tobytes()) == mem.nbytes
        except Exception as e:  # pragma: no cover - only on failure
            errors.append(e)

    def reallocer():
        try:
            for i in range(200):
                try:
                    mem.realloc(1 << 12 if i % 2 == 0 else 1 << 13)
                except (ValueError, BufferError):
                    pass
        except Exception as e:  # pragma: no cover - only on failure
            errors.append(e)
        finally:
            stop.set()

    ts = [threading.Thread(target=reader) for _ in range(3)]
    ts.append(threading.Thread(target=reallocer))
    for t in ts:
        t.start()
    for t in ts:
        t.join()

    assert not errors, f"Concurrent realloc/read errors: {errors}"
    assert mem.nbytes == len(mem)


def test_realloc_refused_while_another_thread_holds_reference():
    mem = mkl.MKLMemory(64)
    holder_ready = threading.Event()
    release_holder = threading.Event()
    outcome = []
    shared_refcount = []

    def holder():
        # keep reference alive
        alias = mem  # noqa: F841
        holder_ready.set()
        release_holder.wait(timeout=30)

    base_refcount = sys.getrefcount(mem)

    t = threading.Thread(target=holder)
    t.start()
    try:
        assert holder_ready.wait(timeout=30)
        shared_refcount.append(sys.getrefcount(mem))
        try:
            mem.realloc(1 << 16)
            outcome.append("ok")
        except ValueError:
            outcome.append("refused")
    finally:
        release_holder.set()
        t.join()

    assert shared_refcount[0] > base_refcount, (
        "Holder's reference was not visible here: "
        f"{base_refcount} -> {shared_refcount[0]}"
    )
    assert outcome == [
        "refused"
    ], f"Expected refusal while shared, got {outcome}"
    assert len(mem) == 64, "Refused realloc must not change the buffer"
