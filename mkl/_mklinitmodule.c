/* -*- c -*- */

/*
 * This is a dummy module whose purpose is to get distutils to generate the
 * configuration files before the libraries are made.
 */

#if (defined(USING_MKL_RT) && defined(__linux__))
#define FORCE_PRELOADING 1
#define _GNU_SOURCE 1
#include <dlfcn.h>
#include <pthread.h>
#include <string.h>
#undef _GNU_SOURCE
#endif

#include <Python.h>
#if PY_MAJOR_VERSION >= 3
#define IS_PY3K
#endif
#include "mkl.h"

static struct PyMethodDef methods[] = {{NULL, NULL, 0, NULL}};

#if defined(_MSC_VER) && (_MSC_VER <= 1500)
#define MKL_SERVICE_INLINE
#else
#define MKL_SERVICE_INLINE inline
#endif

static MKL_SERVICE_INLINE void _set_mkl_ilp64(void);
static MKL_SERVICE_INLINE void _set_mkl_lp64(void);
static MKL_SERVICE_INLINE void _set_mkl_interface(void);

static const char *mtlayer;
static const char *verbose;

#if FORCE_PRELOADING
#define VERBOSE(...)                                                           \
  if (verbose)                                                                 \
  printf("mkl-service + Intel(R) MKL: " __VA_ARGS__)

static void restore_mtlayer(void) {
  if (mtlayer) {
    VERBOSE(
        "Re-setting Intel(R) MKL_THREADING_LAYER=%s for the forked process\n",
        mtlayer);
    setenv("MKL_THREADING_LAYER", mtlayer, 1);
  } else {
    VERBOSE("Unsetting Intel(R) MKL_THREADING_LAYER variable for the forked "
            "process \n");
    unsetenv("MKL_THREADING_LAYER");
  }
}
#endif

static void _preload_threading_layer(void) {
#if FORCE_PRELOADING
#define SET_MTLAYER(L)                                                         \
  do {                                                                         \
    VERBOSE("setting Intel(R) MKL to use " #L " OpenMP runtime\n");            \
    mkl_set_threading_layer(MKL_THREADING_##L);                                \
    setenv("MKL_THREADING_LAYER", #L, 0);                                      \
    pthread_atfork(NULL, NULL, &restore_mtlayer);                              \
  } while (0)
#define PRELOAD(lib)                                                           \
  do {                                                                         \
    VERBOSE("preloading %s runtime\n", lib);                                   \
    dlopen(lib, RTLD_LAZY | RTLD_GLOBAL);                                      \
  } while (0)
  /*
   * The following is the pseudo-code skeleton for reinterpreting unset
   * MKL_THREADING_LAYER
   *
   *       if MKL_THREADING_LAYER is empty
   *            if kmp_calloc (or a suitable symbol identified by Terry) is
   * loaded, we are using Intel(R) OpenMP, i.e. reinterpret as implicit value of
   * INTEL otherwise check if other Open MP is loaded by checking
   * get_omp_num_threads symbol if not loaded: assume INTEL, and force loading
   * of IOMP5 if loaded: if Gnu OMP, set MKL_THREADING_LAYER=GNU, and call
   * set_mkl_threading_layer(MKL_THREADING_GNU) if other vendors? if
   * MKL_THREADING_LAYER is INTEL force loading of iomp, to preempt possibility
   * of other modules loading other OMP library before MKL is actually used
   *
   *       should we treat other possible values of MKL_THREADING_LAYER
   * specially?
   *
   */

  const char *libiomp = "libiomp5.so";
  verbose = getenv("MKL_VERBOSE");
  mtlayer = getenv("MKL_THREADING_LAYER");

  /* Use of RTLD_DEFAULT handler is to indicate that symbol is being lookup-up
   * among symbols presently known to this process.
   *
   * See:  https://pubs.opengroup.org/onlinepubs/9699919799/functions/dlsym.html
   */
  void *omp = dlsym(RTLD_DEFAULT, "omp_get_num_threads");
  const char *omp_name = "(unidentified)";
  const char *iomp = NULL; /* non-zero indicates Intel(R) OpenMP is loaded */
  Dl_info omp_info;

  if (verbose && (verbose[0] == 0 || atoi(verbose) == 0))
    verbose = NULL;

  VERBOSE("THREADING LAYER: %s\n", mtlayer);

  if (omp) {
    if (dladdr(omp, &omp_info)) {
      omp_name = basename(
          omp_info.dli_fname); /* GNU version doesn't modify argument */
      iomp = strstr(omp_name, libiomp);
    }
    VERBOSE("%s OpenMP runtime %s is already loaded\n",
            iomp ? "Intel(R)" : "Other vendor", omp_name);
  }
  if (!mtlayer || mtlayer[0] == 0) { /* unset or empty */
    if (omp) {                       /* if OpenMP runtime is loaded */
      if (iomp)                      /* if Intel runtime is loaded */
        SET_MTLAYER(INTEL);
      else /* otherwise, assume it is GNU OpenMP */
        SET_MTLAYER(GNU);
    } else { /* nothing is loaded */
      SET_MTLAYER(INTEL);
      PRELOAD(libiomp);
    }
  } else if (strcasecmp(mtlayer, "intel") ==
             0) { /* Intel runtime is requested */
    if (omp && !iomp) {
      fprintf(stderr,
              "Error: mkl-service + Intel(R) MKL: MKL_THREADING_LAYER=INTEL is "
              "incompatible with %s library."
              "\n\tTry to import numpy first or set the threading layer "
              "accordingly. "
              "Set MKL_SERVICE_FORCE_INTEL to force it.\n",
              omp_name);
      if (!getenv("MKL_SERVICE_FORCE_INTEL"))
        exit(1);
    } else
      PRELOAD(libiomp);
  }
#endif
  return;
}

static MKL_SERVICE_INLINE void _set_mkl_ilp64(void) {
#ifdef USING_MKL_RT
  mkl_set_interface_layer(MKL_INTERFACE_ILP64);
#endif
  return;
}

static MKL_SERVICE_INLINE void _set_mkl_lp64(void) {
#ifdef USING_MKL_RT
  mkl_set_interface_layer(MKL_INTERFACE_LP64);
#endif
  return;
}

static MKL_SERVICE_INLINE void _set_mkl_interface(void) {
  _set_mkl_lp64();
  _preload_threading_layer();
}

#if defined(IS_PY3K)
static struct PyModuleDef moduledef = {PyModuleDef_HEAD_INIT,
                                       "mklinit",
                                       NULL,
                                       -1,
                                       methods,
                                       NULL,
                                       NULL,
                                       NULL,
                                       NULL};
#endif

/* Initialization function for the module */
#if defined(IS_PY3K)
PyMODINIT_FUNC PyInit__mklinit(void) {
  PyObject *m;

  _set_mkl_interface();
  m = PyModule_Create(&moduledef);
  if (!m) {
    return NULL;
  }

  return m;
}
#else
PyMODINIT_FUNC init_mklinit(void) {
  _set_mkl_interface();
  Py_InitModule("_mklinit", methods);
}
#endif
