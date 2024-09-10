
@rem Remember to activate compiler, if needed

set MKLROOT=%CONDA_PREFIX%
%PYTHON% setup.py install
if errorlevel 1 exit 1
