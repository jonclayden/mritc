// RegisteringDynamic Symbols

#include <R.h>
#include <Rinternals.h>
#include <R_ext/Rdynload.h>

#ifdef _OPENMP
#include <omp.h>
#endif

void R_init_mritc(DllInfo* info) {
    R_registerRoutines(info, NULL, NULL, NULL, NULL);
    R_useDynamicSymbols(info, TRUE);
    
#ifdef _OPENMP
    // The OpenMP runtime may not pick up OMP_THREAD_LIMIT/OMP_NUM_THREADS
    // reliably if they're set after the runtime has initialised, so cap the
    // thread count explicitly here instead, at package load time
    const char *limit = getenv("OMP_THREAD_LIMIT");
    if (limit == NULL)
        limit = getenv("OMP_NUM_THREADS");
    if (limit != NULL) {
        int nthreads = atoi(limit);
        if (nthreads > 0)
            omp_set_num_threads(nthreads);
  }
#endif
}
