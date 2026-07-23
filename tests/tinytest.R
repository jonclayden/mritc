Sys.setenv(OMP_THREAD_LIMIT=2)

if (requireNamespace("tinytest", quietly=TRUE))
    tinytest::test_package("mritc")
