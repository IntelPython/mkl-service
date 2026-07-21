project(
    'mkl-service',
    ['c', 'cython'],
    version: run_command(
        find_program('python3', 'python'),
        ['-c', 'exec(open("mkl/_version.py").read()); print(__version__)'],
        check: true
    ).stdout().strip(),
    meson_version: '>=1.8.3',
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

rpath_link_args = []
if host_machine.system() != 'windows'
    if host_machine.system() == 'darwin'
        origin = '@loader_path'
    else
        origin = '$ORIGIN'
    endif
    rpath = origin / '../..' + ':' + origin / '../../..'
    rpath_link_args = ['-Wl,-rpath,' + rpath]
endif

# C extension
py.extension_module(
    '_mklinit',
    sources: ['mkl/_mklinitmodule.c'],
    dependencies: [mkl_dep, thread_dep],
    c_args: c_args + ['-DUSING_MKL_RT'],
    link_args: rpath_link_args,
    install: true,
    subdir: 'mkl'
)

# Cython extension
py.extension_module(
    '_py_mkl_service',
    sources: ['mkl/_py_mkl_service.pyx'],
    dependencies: [mkl_dep],
    c_args: c_args,
    link_args: rpath_link_args,
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

py.install_sources(
    ['mkl/tests/test_mkl_service.py'],
    subdir: 'mkl/tests'
)
