echo on
rem set CFLAGS=-I%PREFIX%\Library\include %CFLAGS%
rem set LDFLAGS=/LIBPATH:%PREFIX% %LDFLAGS%

set MKLROOT=%CONDA_PREFIX%

"%PYTHON%" setup.py clean --all

:: Make CMake verbose
set "VERBOSE=1"

:: -wnx flags mean: --wheel --no-isolation --skip-dependency-check
%PYTHON% -m build -w -n -x
if %ERRORLEVEL% neq 0 exit 1

:: `pip install dist\numpy*.whl` does not work on windows,
:: so use a loop; there's only one wheel in dist/ anyway
for /f %%f in ('dir /b /S .\dist') do (
  %PYTHON% -m wheel tags --remove %%f
  if %ERRORLEVEL% neq 0 exit 1
)

:: wheel file was renamed
for /f %%f in ('dir /b /S .\dist') do (
  %PYTHON% -m pip install %%f ^
    --no-build-isolation ^
    --no-deps ^
    --only-binary :all: ^
    --no-index ^
    --prefix %PREFIX% ^
    -vv
  if %ERRORLEVEL% neq 0 exit 1
)

:: Copy wheel package
if NOT "%WHEELS_OUTPUT_FOLDER%"=="" (
  copy dist\mkl_service*.whl %WHEELS_OUTPUT_FOLDER%
  if %ERRORLEVEL% neq 0 exit 1
)
