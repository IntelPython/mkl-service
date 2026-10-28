"""Build the conda CI matrix from the python list of a conda_build_config.yaml.

Usage:
  python conda_python_matrix.py RECIPE_DIR/conda_build_config.yaml

Prints the matrix entries and, when $GITHUB_OUTPUT is set, writes
matrix=<JSON> to it for strategy.matrix of later jobs. Standard library only,
so it runs on any runner without conda.

The python: key must hold full specs, one per line and without selectors,
such as "3.12.* *_cpython", "3.13.* *_cp313" or "3.14.* *_cp314t", quoted or
not, so that every job gets an explicit ABI. Each entry becomes one matrix
entry with:
- python: the version, e.g. "3.14"
- python_spec: the entry itself, for conda build --python
- python_tag: the version, with a "t" suffix for free-threaded builds, for
  artifact names
- label: the check name suffix. A version with a single build shows only the
  version ("3.12"); a version with GIL and free-threaded builds shows the
  version, spec and tag ("3.14, 3.14.* *_cp314t, 3.14t"). These are the
  names of the former static matrix, which branch rulesets may require.
"""

import argparse
import collections
import json
import os
import re
import sys

SPEC_RE = re.compile(r"(\d+\.\d+)\.\* \*_(cpython|cp\d+t?)")


class DeclarationError(Exception):
    """The python: list cannot be turned into a matrix."""


def read_specs(path):
    """Return the entries of the python: key of a conda_build_config.yaml."""
    specs, in_list = [], False
    with open(path, encoding="utf-8") as f:
        for line in f:
            if line.startswith("python:"):
                if specs or line.strip() != "python:":
                    raise DeclarationError(
                        "expected a single 'python:' key without selectors"
                    )
                in_list = True
            elif in_list and re.match(r"\s+-", line):
                if "#" in line:
                    raise DeclarationError(
                        "selectors on python entries are not supported: "
                        + line.strip()
                    )
                spec = line.split("-", 1)[1].strip()
                if len(spec) > 1 and spec[0] == spec[-1] and spec[0] in "'\"":
                    spec = spec[1:-1]
                specs.append(spec)
            elif in_list and line.strip() and not line[0].isspace():
                in_list = False
    if not specs:
        raise DeclarationError("no python entries found")
    return specs


def build_matrix(specs):
    """Return the strategy.matrix for the given python entries."""
    parsed = []
    for spec in specs:
        m = SPEC_RE.fullmatch(spec)
        if not m:
            raise DeclarationError(
                f"unsupported python entry '{spec}', "
                "expected e.g. '3.14.* *_cp314t'"
            )
        parsed.append((spec, m.group(1), m.group(2)))

    builds = collections.Counter(version for _, version, _ in parsed)
    include = []
    for spec, version, abi in parsed:
        tag = version + ("t" if abi.endswith("t") else "")
        if builds[version] == 1:
            label = version
        else:
            label = f"{version}, {spec}, {tag}"
        include.append(
            {
                "python": version,
                "python_spec": spec,
                "python_tag": tag,
                "label": label,
            }
        )
    return {"include": include}


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("cbc", help="path to conda_build_config.yaml")
    args = parser.parse_args(argv)

    try:
        matrix = build_matrix(read_specs(args.cbc))
    except DeclarationError as e:
        print(f"{args.cbc}: {e}", file=sys.stderr)
        return 1

    print(json.dumps(matrix["include"], indent=2))
    output = os.environ.get("GITHUB_OUTPUT")
    if output:
        with open(output, "a", encoding="utf-8") as f:
            f.write("matrix=" + json.dumps(matrix) + "\n")
    return 0


if __name__ == "__main__":
    sys.exit(main())
