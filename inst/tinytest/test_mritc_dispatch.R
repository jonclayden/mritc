# mritc() is the top-level convenience wrapper: given a raw intensity array
# and a mask, it derives initial parameter estimates and spatial structures
# automatically and dispatches to the appropriate fitting function.

set.seed(41)
mask <- array(0, dim=c(8,8,8))
mask[2:7,2:7,2:7] <- 1
intarr <- array(rnorm(8^3, 100, 10), dim=c(8,8,8))
intarr[mask==1] <- intarr[mask==1] + rep(c(0,20,40), length.out=sum(mask==1))
nvox <- sum(mask)

for (m in c("EM", "ICM", "HMRFEM", "PVHMRFEM", "MCMC", "MCMCsub")) {
    out <- mritc(intarr, mask, method=m, verbose=FALSE)
    expect_inherits(out, "mritc")
    expect_equal(out$method, m)
    expect_equal(nrow(out$prob), nvox)
    expect_equal(rowSums(out$prob), rep(1, nvox), tolerance=1e-6)
    expect_identical(out$mask, mask)
}

# PVHMRFEM alone produces 5 columns (3 pure + 2 partial-volume classes)
outpv <- mritc(intarr, mask, method="PVHMRFEM", verbose=FALSE)
expect_equal(ncol(outpv$prob), 5)

# MCMCsubbias combines the sub-voxel and bias-field-correction models
outbias <- mritc(intarr, mask, method="MCMCsubbias", verbose=FALSE)
expect_inherits(outbias, "mritc")
expect_equal(nrow(outbias$prob), nvox)
expect_equal(rowSums(outbias$prob), rep(1, nvox), tolerance=1e-6)

# default method is "EM"
outdef <- mritc(intarr, mask, verbose=FALSE)
expect_equal(outdef$method, "EM")

# method can be abbreviated
outabbr <- mritc(intarr, mask, method="IC", verbose=FALSE)
expect_equal(outabbr$method, "ICM")

# verbose defaults to TRUE, and can be silenced
expect_true(length(capture.output(mritc(intarr, mask, method="EM"))) > 0)
expect_silent(mritc(intarr, mask, method="EM", verbose=FALSE))

# input validation
expect_error(mritc(intarr[,,1], mask, method="EM"))
expect_error(mritc(intarr, mask[,,1], method="EM"))
expect_error(mritc(intarr, mask * 0, method="EM"))
expect_error(mritc(intarr, mask * 2, method="EM"))
expect_error(mritc(intarr, mask, method="nonexistent"))
