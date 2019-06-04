
@rem Remember to activate compiler, if needed

set MKLROOT=%CONDA_PREFIX%
%PYTHON% setup.py build --force install --old-and-unmanageable
if errorlevel 1 exit 1
