"""
Builds this repository's packages for one Python version.

For the intel-ci.yml GitHub Actions workflow.

This file and ci/matrix.py work out the build system from the files present,
and the Python versions from that build system's own declaration:

  rattler-build    .conda  recipe.yaml or recipe/recipe.yaml, versions in
                           variants.yaml
  conda-build      .conda  conda-recipe/meta.yaml or meta.yaml, versions in
                           conda_build_config.yaml
  cibuildwheel     .whl    pyproject.toml, versions from its classifiers

Usage:
  python ci/build.py --python 3.14 --output OUT [--system rattler-build]
                     [--channel conda-forge]

--python must be one of the declared versions; `python ci/matrix.py` lists them.

Packages land directly in OUT, ready for actions/upload-artifact. A conda
recipe's own tests run during the build. Needs only the Python standard library.
rattler-build is used from PATH, or downloaded at a pinned version for Linux or
Windows and checked against its published sha256; conda-build, or cibuildwheel
for wheels, must already be installed for this interpreter, so run it with the
conda base install's Python to build with conda-build.

Wheels build with cibuildwheel, in a manylinux container on Linux, as
pyproject.toml's [tool.cibuildwheel] says. Run-time requirements that
pyproject.toml cannot declare, because the conda package gets them from its
recipe instead, such as MKL's libraries, go in [tool.gh-ci] wheel-requires:
build.py adds them to each wheel's metadata. [tool.gh-ci] pin-compatible maps a
run-time requirement to the build requirement it follows, like conda's
pin_compatible: build.py requires >= the version python -m build installed for
the build, < its next major. It also cuts the RPATH and
RUNPATH of each ELF file in a wheel to their $ORIGIN entries, dropping absolute
ones such as the isolated build environment's lib directory, which meson-python
keeps, and refuses a file that would have none left, or that is not linked
with full RELRO.
"""

import argparse
import base64
import hashlib
import os
import platform
import re
import shlex
import shutil
import struct
import subprocess
import sys
import tempfile
import urllib.request
import zipfile
from pathlib import Path

import matrix

ROOT = matrix.ROOT
PACKAGE_SUFFIXES = (".conda", ".tar.bz2", ".whl")
# cibuildwheel's platform part of a build identifier, per system.
WHEEL_PLATFORMS = {
    "Linux": "manylinux_x86_64",
    "Windows": "win_amd64",
    "Darwin": "macosx_x86_64",
}
# The ELF program header and dynamic section values the RUNPATH check reads.
PT_LOAD, PT_DYNAMIC, PT_GNU_RELRO = 1, 2, 0x6474E552
DT_NULL, DT_STRTAB, DT_RPATH, DT_RUNPATH = 0, 5, 15, 29
DT_BIND_NOW, DT_FLAGS, DT_FLAGS_1 = 24, 30, 0x6FFFFFFB
DF_BIND_NOW, DF_1_NOW = 0x8, 0x1
ORIGIN = ("$ORIGIN", "${ORIGIN}")
ANSI_RE = re.compile(r"\x1b\[[0-9;]*m")

# The rattler-build release fetched when none is on PATH, per system, with the
# file name it goes under and the sha256 its release publishes.
RATTLER_BUILD_VERSION = "v0.77.0"
RATTLER_BUILD_RELEASES = {
    "Linux": (
        "rattler-build-x86_64-unknown-linux-musl",
        "rattler-build",
        "5a5e8150c703b21e88a01f9130ea49a7a680198e9ac9414170c0a293fed7e5af",
    ),
    "Windows": (
        "rattler-build-x86_64-pc-windows-msvc.exe",
        "rattler-build.exe",
        "e144334f782cee9aa23e26eb8d095c143e1696fbbec7ba7534a156663d4abb2c",
    ),
}


class BuildError(Exception):
    """Raised when the build cannot start or produced nothing."""


def ensure_rattler_build(tools: Path) -> None:
    """
    Puts rattler-build on PATH, downloading the pinned release when none is
    there.
    """
    if shutil.which("rattler-build"):
        return
    release = RATTLER_BUILD_RELEASES.get(platform.system())
    if release is None or platform.machine().lower() not in ("x86_64", "amd64"):
        raise BuildError(
            "no rattler-build on PATH, and only the Linux and Windows x86_64 "
            "releases are pinned here"
        )
    asset, name, sha256 = release
    print(f"build: fetching rattler-build {RATTLER_BUILD_VERSION}", flush=True)
    url = (
        "https://github.com/prefix-dev/rattler-build/releases/download/"
        f"{RATTLER_BUILD_VERSION}/{asset}"
    )
    with urllib.request.urlopen(url, timeout=300) as reply:
        binary = reply.read()
    if hashlib.sha256(binary).hexdigest() != sha256:
        raise BuildError(
            f"rattler-build {RATTLER_BUILD_VERSION} does not match its pinned "
            "sha256"
        )
    tools.mkdir(parents=True, exist_ok=True)
    target = tools / name
    target.write_bytes(binary)
    target.chmod(0o755)
    os.environ["PATH"] = f'{tools}{os.pathsep}{os.environ.get("PATH", "")}'


def cibuildwheel_identifier(python: matrix.Python) -> str:
    """The one build cibuildwheel runs, such as cp314t-manylinux_x86_64."""
    tag = WHEEL_PLATFORMS.get(platform.system())
    if tag is None:
        raise BuildError(
            f"wheels build on Linux, Windows or macOS, not {platform.system()}"
        )
    minor, threaded = matrix.version_key(python.version)
    return f'cp3{minor}{"t" if threaded else ""}-{tag}'


def wheel_settings() -> tuple[list[str], dict[str, str]]:
    """[tool.gh-ci] wheel-requires and pin-compatible from pyproject.toml."""
    if matrix.TOMLLIB is None:
        raise BuildError("reading pyproject.toml needs Python 3.11 or newer")
    text = (ROOT / "pyproject.toml").read_text(encoding="utf-8")
    tool = matrix.TOMLLIB.loads(text).get("tool", {}).get("gh-ci", {})
    requires = tool.get("wheel-requires", [])
    if not isinstance(requires, list) or not all(
        isinstance(r, str) for r in requires
    ):
        raise BuildError("[tool.gh-ci] wheel-requires must be a list of specs")
    pins = tool.get("pin-compatible", {})
    if not isinstance(pins, dict) or not all(
        isinstance(k, str) and isinstance(v, str) for k, v in pins.items()
    ):
        raise BuildError(
            "[tool.gh-ci] pin-compatible must map a run-time requirement to "
            "a build requirement"
        )
    return requires, pins


def canonical(name: str) -> str:
    """A distribution name as PEP 503 compares it."""
    return re.sub(r"[-_.]+", "-", name).lower()


def build_versions(log: list[str]) -> dict[str, str]:
    """
    The version of each build requirement the isolated build environment
    installed, from the list python -m build logs.
    """
    versions, listing = {}, False
    for line in log:
        text = ANSI_RE.sub("", line).strip()
        if text.endswith("Installed build dependency versions:"):
            listing = True
        elif listing and (match := re.fullmatch(r"- ([\w.-]+)==(\S+)", text)):
            versions[canonical(match[1])] = match[2]
        else:
            listing = False
    return versions


def pinned(pins: dict[str, str], versions: dict[str, str]) -> list[str]:
    """Each pinned run-time requirement: >= its build version, < next major."""
    specs = []
    for runtime, build in pins.items():
        version = versions.get(canonical(build))
        major = version.split(".")[0] if version else ""
        if not major.isdigit():
            raise BuildError(
                f"the build logged no installed {build} version, which "
                f"[tool.gh-ci] pin-compatible pins {runtime} to"
            )
        specs.append(f"{runtime} >={version},<{int(major) + 1}")
    return specs


def run_logged(command: list[str]) -> list[str]:
    """Runs a command, passing its output through, and returns that output."""
    lines = []
    sys.stdout.flush()
    with subprocess.Popen(
        command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT
    ) as process:
        for line in process.stdout:
            sys.stdout.buffer.write(line)
            sys.stdout.buffer.flush()
            lines.append(line.decode("utf-8", "replace"))
    if process.returncode:
        raise subprocess.CalledProcessError(process.returncode, command)
    return lines


def record_hash(data: bytes) -> str:
    """A file's hash as a wheel's RECORD spells it."""
    digest = base64.urlsafe_b64encode(hashlib.sha256(data).digest())
    return "sha256=" + digest.rstrip(b"=").decode("ascii")


def elf_dynamic(
    data: bytes, name: str
) -> tuple[list[tuple[int, int, int, int]], list[tuple[int, int]]] | None:
    """
    The program headers, as (p_type, p_offset, p_vaddr, p_filesz), and the
    dynamic entries of an ELF file; None for a file that is not ELF.
    """
    if data[:4] != b"\x7fELF":
        return None
    if data[4:6] != b"\x02\x01":
        raise BuildError(f"{name}: only 64-bit little-endian ELF is read")
    (phoff,) = struct.unpack_from("<Q", data, 0x20)
    phentsize, phnum = struct.unpack_from("<HH", data, 0x36)
    # p_type, p_offset, p_vaddr and p_filesz of each program header
    segments = [
        struct.unpack_from("<I4xQQ8xQ", data, phoff + index * phentsize)
        for index in range(phnum)
    ]
    entries = []
    for kind, offset, _, size in segments:
        if kind == PT_DYNAMIC:
            for position in range(offset, offset + size, 16):
                tag, value = struct.unpack_from("<qQ", data, position)
                if tag == DT_NULL:
                    break
                entries.append((tag, value))
    return segments, entries


def elf_search_paths(data: bytes, name: str) -> list[tuple[str, int, int, str]]:
    """
    The RPATH and RUNPATH strings of an ELF file, as (RPATH or RUNPATH, file
    offset, length, value); none for a file that is not ELF.
    """
    if (parsed := elf_dynamic(data, name)) is None:
        return []
    segments, entries = parsed
    strtab = dict(entries).get(DT_STRTAB)
    if strtab is None:
        return []
    base = next(
        offset + strtab - vaddr
        for kind, offset, vaddr, size in segments
        if kind == PT_LOAD and vaddr <= strtab < vaddr + size
    )
    found = []
    for tag, value in entries:
        if tag in (DT_RPATH, DT_RUNPATH):
            start = base + value
            end = data.index(b"\0", start)
            kind = "RPATH" if tag == DT_RPATH else "RUNPATH"
            found.append((kind, start, end - start, data[start:end].decode()))
    return found


def full_relro(data: bytes, name: str) -> bool:
    """Whether an ELF file has full RELRO; True for a file that is not ELF."""
    if (parsed := elf_dynamic(data, name)) is None:
        return True
    segments, entries = parsed
    flags = dict(entries)
    return any(kind == PT_GNU_RELRO for kind, *_ in segments) and (
        DT_BIND_NOW in flags
        or bool(flags.get(DT_FLAGS, 0) & DF_BIND_NOW)
        or bool(flags.get(DT_FLAGS_1, 0) & DF_1_NOW)
    )


def origin_relative(path: str) -> bool:
    """Whether a search path entry is $ORIGIN or a directory under it."""
    return any(
        path == token or path.startswith(token + "/") for token in ORIGIN
    )


def origin_only(data: bytes, name: str) -> tuple[bytes, list[str]]:
    """
    An ELF file with its RPATH and RUNPATH cut to their $ORIGIN entries, in
    place as patchelf does, and the entries it dropped.
    """
    edited, dropped = bytearray(data), []
    for kind, start, length, value in elf_search_paths(data, name):
        paths = value.split(":")
        kept = [path for path in paths if origin_relative(path)]
        if kept == paths:
            continue
        # An empty search path would mean the working directory
        if not kept:
            raise BuildError(f"{name}: no $ORIGIN entry in {kind} {value!r}")
        edited[start : start + length] = (
            ":".join(kept).encode().ljust(length, b"\0")
        )
        dropped += [
            f"{kind} entry {path}" for path in paths if path not in kept
        ]
    return bytes(edited), dropped


def with_requirements(metadata: bytes, requirements: list[str]) -> bytes:
    """A wheel's METADATA with Requires-Dist lines added."""
    text = metadata.decode("utf-8")
    # Some Windows build backends write the metadata with CRLF. Take the line
    # ending from the headers, as the description can keep the README's.
    headers = re.split(r"\r?\n\r?\n", text, maxsplit=1)[0]
    eol = "\r\n" if "\r\n" in headers else "\n"
    head, blank, body = text.partition(eol * 2)
    head = head.rstrip("\r\n") + "".join(
        f"{eol}Requires-Dist: {r}" for r in requirements
    )
    return (head + (eol * 2 + body if blank else eol)).encode("utf-8")


def rewrite_wheel(wheel: Path, requirements: list[str]) -> list[str]:
    """
    Adds Requires-Dist lines to a built wheel and cuts its ELF files' RPATH
    and RUNPATH to their $ORIGIN entries, updating its RECORD; lists the
    entries it dropped. Refuses an ELF file without full RELRO.
    """
    with zipfile.ZipFile(wheel) as source:
        members = [(info, source.read(info)) for info in source.infolist()]
    names = [info.filename for info, _ in members]
    metadata = next(n for n in names if n.endswith(".dist-info/METADATA"))
    record = metadata.removesuffix("METADATA") + "RECORD"
    changed, dropped = {}, []
    for index, (info, data) in enumerate(members):
        if info.filename == metadata and requirements:
            new = with_requirements(data, requirements)
        else:
            new, paths = origin_only(data, info.filename)
            dropped += [f"{path} from {info.filename}" for path in paths]
            if not full_relro(new, info.filename):
                raise BuildError(
                    f"{info.filename} has no full RELRO; link it with "
                    "-Wl,-z,relro -Wl,-z,now"
                )
        if new != data:
            members[index] = (info, new)
            changed[info.filename] = new
    if not changed:
        return dropped
    for index, (info, data) in enumerate(members):
        if info.filename == record:
            lines = [
                (
                    f"{name},{record_hash(changed[name])},{len(changed[name])}"
                    if (name := line.split(",")[0]) in changed
                    else line
                )
                for line in data.decode("utf-8").splitlines()
            ]
            members[index] = (info, ("\n".join(lines) + "\n").encode())
    rewritten = wheel.with_suffix(".tmp")
    with zipfile.ZipFile(rewritten, "w", zipfile.ZIP_DEFLATED) as target:
        for info, data in members:
            target.writestr(info, data)
    rewritten.replace(wheel)
    return dropped


def commands(
    system: str,
    selector: Path,
    python: matrix.Python,
    channels: list[str],
    scratch: Path,
) -> list[list[str]]:
    """
    The commands that build one Python version's packages into scratch.

    Each build system gets the version back exactly as its own file declares it,
    and keeps every other variant setting from that file.
    """
    channel_args = [arg for channel in channels for arg in ("-c", channel)]
    # The commit a conda package came from, in its info/about.json
    github = [
        os.environ.get(name, "")
        for name in ("GITHUB_SERVER_URL", "GITHUB_REPOSITORY", "GITHUB_SHA")
    ]
    extra_meta = (
        [
            "--extra-meta",
            f"remote_url={github[0]}/{github[1]}",
            f"sha={github[2]}",
        ]
        if all(github)
        else []
    )
    if system == "rattler-build":
        return [
            [
                "rattler-build",
                "build",
                "-r",
                str(selector),
                "--variant",
                f"python={python.spec}",
                "--output-dir",
                str(scratch / "conda"),
                *channel_args,
            ]
        ]
    if system == "conda-build":
        # conda runs as a module of this interpreter, so Windows needs no
        # conda.bat on PATH.
        return [
            [
                sys.executable,
                "-m",
                "conda",
                "build",
                str(selector.parent),
                "--python",
                python.spec,
                "--no-anaconda-upload",
                "--output-folder",
                str(scratch / "conda"),
                *extra_meta,
                "--override-channels",
                *channel_args,
            ]
        ]
    return [
        [
            sys.executable,
            "-m",
            "cibuildwheel",
            "--only",
            cibuildwheel_identifier(python),
            "--output-dir",
            str(scratch / "wheel"),
            str(ROOT),
        ]
    ]


def collect(scratch: Path, output: Path) -> list[Path]:
    """
    Moves built packages into output, flat, and lists the ones it moved.
    Two packages of one name are an error: flat, one would overwrite the other.
    """
    output.mkdir(parents=True, exist_ok=True)
    built = []
    sources: dict[str, Path] = {}
    for package in sorted(scratch.rglob("*")):
        if (
            package.is_file()
            and package.name.endswith(PACKAGE_SUFFIXES)
            and "broken" not in package.parts
        ):
            if package.name in sources:
                raise BuildError(
                    f"two packages named {package.name}: "
                    f"{sources[package.name]} and {package}"
                )
            sources[package.name] = package
            built.append(output / package.name)
            shutil.move(str(package), built[-1])
    if not built:
        raise BuildError(f"the build left no package in {output}")
    return built


def main(argv: list[str] | None = None) -> int:
    """Builds one Python version."""
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[1])
    parser.add_argument(
        "--python", required=True, help="a declared version, such as 3.14t"
    )
    parser.add_argument(
        "--output", required=True, type=Path, help="where the packages go"
    )
    parser.add_argument(
        "--system",
        default="",
        choices=("", *matrix.SYSTEMS),
        help="build system to use instead of the detected one",
    )
    parser.add_argument(
        "--channel",
        action="append",
        default=None,
        help="conda channel to build against, repeatable; default conda-forge",
    )
    default_tools = (
        Path(os.environ.get("RUNNER_TEMP", tempfile.gettempdir())) / "ci-tools"
    )
    parser.add_argument(
        "--tools",
        type=Path,
        default=default_tools,
        help="where a downloaded rattler-build goes",
    )
    args = parser.parse_args(argv)

    system, selector = matrix.detect(ROOT, args.system)
    declared = {
        python.version: python for python in matrix.declared(system, selector)
    }
    if args.python not in declared:
        raise BuildError(
            f"Python {args.python} is not declared for {system}; "
            f'declared: {", ".join(declared)}'
        )
    python = declared[args.python]
    print(
        f"build: {system} from {selector.relative_to(ROOT)} "
        f"for Python {python.version} ({python.spec})",
        flush=True,
    )
    if system == "rattler-build":
        ensure_rattler_build(args.tools)
    requires, pins = wheel_settings() if system == "wheel" else ([], {})
    output = args.output.resolve()
    log: list[str] = []
    with tempfile.TemporaryDirectory() as scratch:
        for command in commands(
            system,
            selector,
            python,
            args.channel or ["conda-forge"],
            Path(scratch),
        ):
            print(f"+ {shlex.join(command)}", flush=True)
            log += run_logged(command)
        # Rewritten in scratch, so a refused wheel never reaches the output
        if system == "wheel":
            requires = requires + pinned(pins, build_versions(log))
            for wheel in sorted(Path(scratch).rglob("*.whl")):
                for dropped in rewrite_wheel(wheel, requires):
                    print(f"build: dropped {dropped}")
        built = collect(Path(scratch), output)
    if requires:
        print("build: added Requires-Dist " + ", ".join(requires))
    print("build: " + ", ".join(path.name for path in built))
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (
        BuildError,
        matrix.DeclarationError,
        subprocess.CalledProcessError,
    ) as error:
        print(f"build: {error}", file=sys.stderr)
        sys.exit(1)
