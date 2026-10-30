"""
Intel Python CI (gh-ci) test for mkl-service.

GitHub Actions, through ci/hooks.py, and Intel's Jenkins both run this with one
built conda package installed in a clean conda-forge environment, from an empty
working directory, so the tests import the installed mkl module rather than the
source tree. The test requirements come from ci/config.yml. Writes a JUnit
report for Jenkins.
"""

import os
import pathlib
import sys
import sysconfig

import pytest

PACKAGE = "mkl-service"
MODULE = "mkl"


def running_python() -> str:
    """This interpreter's version as gh-ci spells it, such as 3.14t."""
    version = f"{sys.version_info.major}.{sys.version_info.minor}"
    threaded = sysconfig.get_config_var("Py_GIL_DISABLED")
    return version + ("t" if threaded else "")


def main() -> int:
    """Runs the installed package's test suite."""
    expected = os.environ["GH_CI_PYTHON"]
    if running_python() != expected:
        print(f"running Python {running_python()}, the cell is {expected}")
        return 1
    # Cells share one Jenkins build, so each names its own suite
    cell = f"{os.environ.get('GH_CI_PLATFORM', 'linux')}.py{expected}"
    report = pathlib.Path(os.environ["GH_CI_RESULTS"]) / f"{PACKAGE}.xml"
    return pytest.main(
        [
            "-v",
            "-p",
            "no:cacheprovider",
            f"--junitxml={report}",
            "-o",
            f"junit_suite_name={PACKAGE} {cell}",
            "--pyargs",
            MODULE,
        ]
    )


if __name__ == "__main__":
    sys.exit(main())
