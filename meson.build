project(
    'mkl-service',
    ['c', 'cython'],
    version: run_command(
        'python', '-c',
        'import os; exec(open("mkl/_version.py").read()); print(__version__)',
        check: true
    ).stdout().strip(),
    default_options: [
        'buildtype=release',
    ]
)

py = import('python').find_installation(pure: false)

c_args = ['-DNDEBUG']

thread_dep = dependency('threads')

cc = meson.get_compiler('c')
mkl_dep = dependency('MKL', method: 'cmake',
    modules: ['MKL::MKL'],
    cmake_args: [
        '-DMKL_ARCH=intel64',
        '-DMKL_LINK=sdl',
    ],
    required: true
)

rpath = ''
if host_machine.system() != 'windows'
    rpath = '$ORIGIN/../..:$ORIGIN/../../..'
endif

# C extension
py.extension_module(
    '_mklinit',
    sources: ['mkl/_mklinitmodule.c'],
    dependencies: [mkl_dep, thread_dep],
    c_args: c_args + ['-DUSING_MKL_RT'],
    install_rpath: rpath,
    install: true,
    subdir: 'mkl'
)

# Cython extensions
py.extension_module(
    '_py_mkl_service',
    sources: ['mkl/_py_mkl_service.pyx'],
    dependencies: [mkl_dep],
    c_args: c_args,
    install_rpath: rpath,
    install: true,
    subdir: 'mkl'
)

py.extension_module(
    '_mkl_memory',
    sources: ['mkl/_mkl_memory.pyx'],
    dependencies: [mkl_dep],
    c_args: c_args,
    install_rpath: rpath,
    install: true,
    subdir: 'mkl'
)


# Python sources
py.install_sources(
    [
        'mkl/__init__.py',
        'mkl/_init_helper.py',
        'mkl/_version.py',
    ],
    subdir: 'mkl'
)

install_subdir(
    'mkl/tests',
    install_dir: py.get_install_dir() / 'mkl'
)
