@rem Remember to activate Intel Compiler, or remove these two lines to use Microsoft Visual Studio compiler

%PYTHON% -m pip install --no-deps --no-build-isolation .
if errorlevel 1 exit 1
